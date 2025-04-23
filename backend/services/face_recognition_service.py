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
        # Convert image data to numpy array
        nparr = np.frombuffer(image_data, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        # Convert BGR to RGB
        rgb_img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        
        # Find all face locations in the image
        face_locations = face_recognition.face_locations(rgb_img)
        
        if not face_locations:
            return None, None
        
        # Get face encodings
        face_encodings = face_recognition.face_encodings(rgb_img, face_locations)
        
        if not face_encodings:
            return None, None
            
        return face_encodings[0], face_locations[0]

    @staticmethod
    def compare_faces(known_encoding, unknown_encoding):
        if known_encoding is None or unknown_encoding is None:
            return False, 0.0
            
        # Compare faces
        results = face_recognition.compare_faces([known_encoding], unknown_encoding)
        face_distances = face_recognition.face_distance([known_encoding], unknown_encoding)
        
        return results[0], 1 - face_distances[0]  # Convert distance to confidence score

    @staticmethod
    def save_face_image(image_data, user_id):
        # Create uploads directory if it doesn't exist
        if not os.path.exists('uploads'):
            os.makedirs('uploads')
            
        # Save the image
        filename = f'uploads/face_{user_id}_{int(datetime.now().timestamp())}.jpg'
        with open(filename, 'wb') as f:
            f.write(image_data)
            
        return filename 