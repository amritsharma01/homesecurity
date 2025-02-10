# Facial Recognition Based Security System

## Overview
The **Facial Recognition Based Security System** is an AI-driven security solution that uses facial recognition to verify users and grant access. This project integrates AI, hardware, and software to provide a secure, responsive, and efficient system for door access control.

## Features
- **AI-Powered Facial Recognition**: Trained a **Siamese network-based AI model** for accurate face verification.
- **Mobile Application**: Built with **Flutter** to allow users to scan their faces for authentication.
- **Backend Server**: Developed with **Django** and **Django Rest Framework** to handle requests and manage data.
- **Hardware Integration**: Used an **ESP module** to control a servo motor, unlocking the door upon successful verification.

## Tech Stack
- **AI Model**: TensorFlow (Siamese Network)
- **Frontend**: Flutter
- **Backend**: Django, Django Rest Framework
- **Hardware**: ESP8266, Servo Motor
- **Programming Languages**: Python, Dart, C++

## Installation & Setup
### Server Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/amritsharma01/homesecurity.git
   cd facial-recognition-security/backend
   ```
2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/macOS
   venv\Scripts\activate  # Windows
   ```
3. Install dependencies:
   ```bash
   pip install -r requirement.txt
   ```
4. Apply migrations and run the server:
   ```bash
   python manage.py migrate
   python manage.py runserver
   ```

### Mobile Application
1. Navigate to the **`app`** directory.
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the Flutter app:
   ```bash
   flutter run
   ```

### Hardware Setup
1. Upload the **ESP8266 code** from the `esp8266_code` directory to the ESP module.
2. Connect the servo motor to the ESP module as per the wiring diagram provided.

## Usage
1. Launch the server and mobile application.
2. Register a user by capturing their face via the mobile app.
3. For authentication, the user scans their face using the app.
4. If the face is verified, the server communicates with the ESP module to unlock the door.

## Future Enhancements
- **Multi-Face Recognition**: Extend to recognize multiple authorized users.
- **Cloud Integration**: Store user data and logs on the cloud for better scalability.
- **Additional Sensors**: Integrate motion sensors for enhanced security.


## Contributors
- **Amrit Sharma** - [amritsharma1027@gmail.com](mailto:amritsharma1027@gmail.com)


