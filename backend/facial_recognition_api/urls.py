# # facial_recognition_api/urls.py

# from django.urls import path
# 

# urlpatterns = [
#     path('recognize/', views.recognize_face),
#     path('recognized-faces/', views.get_recognized_faces),
# ]
# urls.py
from django.urls import path
from recognition import views
urlpatterns = [
    path('recognize-image/', views.RecognizeImageView.as_view(), name='recognize_image'),
]
