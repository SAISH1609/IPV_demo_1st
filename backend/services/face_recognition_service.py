import face_recognition
import numpy as np
import cv2
import os
from PIL import Image
import io
from datetime import datetime

class FaceRecognitionService:
    @staticmethod
    def process_image(image_data):
        image = face_recognition.load_image_file(image_data)
        encodings = face_recognition.face_encodings(image)
        if encodings:
            return encodings[0], face_recognition.face_locations(image)
        return None, None

    @staticmethod
    def compare_faces(known_encoding, unknown_encoding):
        results = face_recognition.compare_faces([known_encoding], unknown_encoding)
        confidence = face_recognition.face_distance([known_encoding], unknown_encoding)
        return results[0], 1 - confidence[0]

    @staticmethod
    def save_face_image(image_data, user_id):
        folder = 'uploads'
        os.makedirs(folder, exist_ok=True)
        file_path = os.path.join(folder, f'user_{user_id}.jpg')
        with open(file_path, 'wb') as f:
            f.write(image_data)
        return file_path