from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.user import User
from models.attendance import Attendance
from services.face_recognition_service import FaceRecognitionService
from datetime import datetime

attendance_bp = Blueprint('attendance', __name__)

@attendance_bp.route('/api/attendance/check-in', methods=['POST'])
@jwt_required()
def check_in():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    if not user:
        return jsonify({'error': 'User not found'}), 404

    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    image_file = request.files['image']
    image_data = image_file.read()

    face_encoding, _ = FaceRecognitionService.process_image(image_data)
    if not face_encoding:
        return jsonify({'error': 'No face detected'}), 400

    if user.face_encoding:
        known_encoding = np.frombuffer(user.face_encoding, dtype=np.float64)
        match, confidence = FaceRecognitionService.compare_faces(known_encoding, face_encoding)
        if not match or confidence < 0.6:
            return jsonify({'error': 'Face not recognized'}), 400
    else:
        user.face_encoding = face_encoding.tobytes()
        db.session.commit()

    attendance = Attendance(user_id=user_id)
    db.session.add(attendance)
    db.session.commit()

    return jsonify({'message': 'Check-in successful'}), 200

@attendance_bp.route('/api/attendance/check-out', methods=['POST'])
@jwt_required()
def check_out():
    user_id = get_jwt_identity()
    attendance = Attendance.query.filter_by(user_id=user_id, check_out_time=None).first()

    if not attendance:
        return jsonify({'error': 'No active check-in found'}), 400

    attendance.check_out_time = datetime.utcnow()
    db.session.commit()

    return jsonify({'message': 'Check-out successful'}), 200
