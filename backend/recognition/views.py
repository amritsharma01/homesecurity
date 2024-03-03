# views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from PIL import Image
import cv2
import mediapipe as mp
import numpy as np
import os
from django.conf import settings
import tensorflow as tf

prototype_model=tf.keras.models.load_model('Prototype1.keras')
      # Initialize MediaPipe Face Detection
mp_face_detection = mp.solutions.face_detection
face_detection = mp_face_detection.FaceDetection(min_detection_confidence=0.5)

class RecognizeImageView(APIView):
    parser_classes = (MultiPartParser, FormParser)
    def post(self, request, *args, **kwargs):
        if 'image' in request.FILES:
            image_file = request.FILES['image']
            # Process the image (e.g., recognition)
            person_name = self.process_image(image_file)
            # Return the response
            return Response({'person_name': person_name}, status=200)
        else:
            return Response({'error': 'No image file provided'}, status=400)

    def process_image(self, image_file):
        # Load the image
        image = np.array(Image.open(image_file))

  

        # Convert the image to RGB
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

        # Perform face detection
        results = face_detection.process(image_rgb)

        # If faces are detected, crop the image and save the cropped face
        if results.detections:
            # Extract the bounding box of the first detected face
            detection = results.detections[0]
            bboxC = detection.location_data.relative_bounding_box
            ih, iw, _ = image.shape
            ymin, xmin, height, width = int(bboxC.ymin * ih), int(bboxC.xmin * iw), int(bboxC.height * ih), int(bboxC.width * iw)

            # Crop the face from the original image
            cropped_face = image[ymin:ymin+height, xmin:xmin+width]
            cropped_face=cv2.resize(cropped_face,(224,224))

            feature=prototype_model.predict(np.array([cropped_face]))
            name=''
            if (feature.max()==feature[0,2]):
                name='Biraj'
            if (feature.max()==feature[0,1]):
                name='Ashim'
            if (feature.max()==feature[0,0]):
                name='Amrit'



            # Save the cropped face to a local directory
            cropped_face_filename = 'cropped_face.jpg'
            cropped_face_path = os.path.join(settings.BASE_DIR, 'cropped_faces', cropped_face_filename)
            Image.fromarray(cropped_face).save(cropped_face_path)

            # Return the detected person's name and the path to the cropped face
            return f'{name}'
        else:
            return 'Unknown'
