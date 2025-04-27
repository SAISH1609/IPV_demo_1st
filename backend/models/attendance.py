from datetime import datetime
from .user import db

class Attendance(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    check_in_time = db.Column(db.DateTime, default=datetime.utcnow)
    check_out_time = db.Column(db.DateTime, nullable=True)
    status = db.Column(db.String(20), default='present')  # present, late, absent
    location = db.Column(db.String(100), nullable=True)
    image_path = db.Column(db.String(255), nullable=True)  # Path to stored face image
    confidence = db.Column(db.Float, nullable=True)  # Face recognition confidence score