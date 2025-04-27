# Flask main app

from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from config import Config
from models.user import db, User
from models.attendance import Attendance
from services.face_recognition_service import FaceRecognitionService
import os
from routes.auth import auth_bp
from routes.attendance import attendance_bp

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)
jwt = JWTManager(app)
db.init_app(app)

# Create database tables
with app.app_context():
    db.create_all()

app.register_blueprint(auth_bp)
app.register_blueprint(attendance_bp)

if __name__ == '__main__':
    app.run(debug=True)
