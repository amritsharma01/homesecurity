# views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from PIL import Image
import cv2
from keras.models import load_model
import tensorflow as tf
import mediapipe as mp
import numpy as np
import os
from django.conf import settings
import tensorflow as tf
from tensorflow.keras.models import load_model
from keras import backend as K

model=load_model('../siamese/model/gedo.h5',custom_objects={"K":K})
        # Initialize MediaPipe Face Detection
mp_face_detection = mp.solutions.face_detection
face_detection = mp_face_detection.FaceDetection(min_detection_confidence=0.5)

class RecognizeImageView(APIView):
    parser_classes = (MultiPartParser, FormParser)
    def post(self, request):
        if 'image' in request.FILES:
            image_file = request.FILES['image']
            # Process the image (e.g., recognition)
            person = self.process_image(image_file)
            print(person)
            # Return the response
            return Response(person, status=200)
        else:
            return Response({'error': 'No image file provided'}, status=400)
        
    def load_and_preprocess_image(self, image_path):
        image = cv2.imread(image_path)
        image = cv2.resize(image,(224,224))
        image = image/255.0
        return image

    def make_pred(self, path1, path2):
        img1=path1/255.0
        img2=self.load_and_preprocess_image(path2)
        img1 = tf.expand_dims(img1, axis=0)
        img2 = tf.expand_dims(img2, axis=0)
        prediction = model.predict([img1, img2])
        print(prediction)
        return prediction

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
            pred_amrit=0
            pred_asm=0
            for i in range(3):
                pred_amrit+=self.make_pred(cropped_face, f'../siamese/testimages/Amrit/image{i}.jpg')  
                pred_asm+=self.make_pred(cropped_face, f'../siamese/testimages/Ashim/image{i}.jpg') 
            # predict_biraj=self.make_pred(cropped_face, '../siamese/testimages/Biraj.jpg')  
            avg_amr=pred_amrit/3.0
            avg_asm=pred_asm/3.0   
            name=''
            if (avg_amr>0.5  or avg_asm>0.5):
                greatest=max(avg_amr,avg_asm)
                # if(predict_biraj==greatest):
                #     name="Biraj"
                #     id="101103"
                if(avg_amr==greatest):
                    name="Amrit"
                    id="101101"
                else:
                    name="Ashim"
                    id="101102"
                return {"name":name,
                    "id":id
                    }
        return {"name":"unknown",
                "id":0000}

    