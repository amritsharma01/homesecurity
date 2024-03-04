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
from keras.models import load_model
from keras import backend as K
 
model=load_model('../siamese/model/combo.h5', custom_objects={"K":K})
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
            # Return the response
            return Response(person, status=200)
        else:
            return Response({'error': 'No image file provided'}, status=400)
        
    def load_and_preprocess_image(self, image_path):
        image = cv2.imread(image_path)
        image = tf.image.resize(image, size = (224,224))
        image = image/255.0
        return image

    def make_pred(self, path1, path2):
        img1=path1
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
            
            predict_amrit=self.make_pred(cropped_face, '../siamese/testimages/Amrit.jpg')  
            predict_ashim=self.make_pred(cropped_face, '../siamese/testimages/Ashim.jpg')  
            predict_Biraj=self.make_pred(cropped_face, '../siamese/testimages/Biraj.jpg')      
            name=''
            if (predict_amrit>0.5 or predict_Biraj>0.5 or predict_ashim>0.5):
                greatest=max(predict_ashim,predict_amrit,predict_Biraj)
                if(predict_Biraj==greatest):
                    name="Biraj"
                    id="101103"
                elif(predict_amrit==greatest):
                    name="Amrit"
                    id="101101"
                else:
                    name="Ashim"
                    id="101102"
                return {"name":name,
                    "id":id
                    }
            else:
                return {"name":"unknown",
                        "id":0000}

        # Save the cropped face to a local directory
        cropped_face_filename = 'cropped_face.jpg'
        cropped_face_path = os.path.join(settings.BASE_DIR, 'cropped_faces', cropped_face_filename)
        Image.fromarray(cropped_face).save(cropped_face_path)