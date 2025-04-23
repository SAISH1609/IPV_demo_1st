# Flask main app

from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from config import Config
from models.user import db, User
from models.attendance import Attendance
from services.face_recognition_service import FaceRecognitionService
import os

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)
jwt = JWTManager(app)
db.init_app(app)

# Create database tables
with app.app_context():
    db.create_all()

@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    if User.query.filter_by(username=data['username']).first():
        return jsonify({'error': 'Username already exists'}), 400
        
    user = User(
        username=data['username'],
        email=data['email']
    )
    user.set_password(data['password'])
    db.session.add(user)
    db.session.commit()
    
    return jsonify({'message': 'User registered successfully'}), 201

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    user = User.query.filter_by(username=data['username']).first()
    
    if user and user.check_password(data['password']):
        access_token = create_access_token(identity=user.id)
        return jsonify({
            'access_token': access_token,
            'user': {
                'id': user.id,
                'username': user.username,
                'role': user.role
            }
        }), 200
        
    return jsonify({'error': 'Invalid credentials'}), 401

@app.route('/api/attendance/check-in', methods=['POST'])
@jwt_required()
def check_in():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
        
    # Get image from request
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400
        
    image_file = request.files['image']
    image_data = image_file.read()
    
    # Process face
    face_encoding, face_location = FaceRecognitionService.process_image(image_data)
    if not face_encoding:
        return jsonify({'error': 'No face detected'}), 400
        
    # Compare with stored face
    if user.face_encoding:
        known_encoding = np.frombuffer(user.face_encoding, dtype=np.float64)
        match, confidence = FaceRecognitionService.compare_faces(known_encoding, face_encoding)
        if not match or confidence < 0.6:
            return jsonify({'error': 'Face not recognized'}), 400
    else:
        # First time setup - store face encoding
        user.face_encoding = face_encoding.tobytes()
        db.session.commit()
        
    # Save attendance image
    image_path = FaceRecognitionService.save_face_image(image_data, user_id)
    
    # Create attendance record
    attendance = Attendance(
        user_id=user_id,
        image_path=image_path,
        confidence=confidence if 'confidence' in locals() else 1.0
    )
    db.session.add(attendance)
    db.session.commit()
    
    return jsonify({
        'message': 'Check-in successful',
        'attendance_id': attendance.id
    }), 200

@app.route('/api/attendance/check-out', methods=['POST'])
@jwt_required()
def check_out():
    user_id = get_jwt_identity()
    attendance = Attendance.query.filter_by(
        user_id=user_id,
        check_out_time=None
    ).order_by(Attendance.check_in_time.desc()).first()
    
    if not attendance:
        return jsonify({'error': 'No active check-in found'}), 400
        
    attendance.check_out_time = datetime.utcnow()
    db.session.commit()
    
    return jsonify({'message': 'Check-out successful'}), 200

@app.route('/api/attendance/reports', methods=['GET'])
@jwt_required()
def get_reports():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
        
    # Get date range from query parameters
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    
    query = Attendance.query.filter_by(user_id=user_id)
    if start_date:
        query = query.filter(Attendance.check_in_time >= start_date)
    if end_date:
        query = query.filter(Attendance.check_in_time <= end_date)
        
    attendances = query.all()
    
    return jsonify({
        'attendances': [{
            'id': a.id,
            'check_in_time': a.check_in_time.isoformat(),
            'check_out_time': a.check_out_time.isoformat() if a.check_out_time else None,
            'status': a.status,
            'confidence': a.confidence
        } for a in attendances]
    }), 200

if __name__ == '__main__':
    app.run(debug=True)
