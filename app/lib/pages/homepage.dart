import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:minorprojapp/widgets/verifiedscreen.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/alert_dialogbox.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String? img;
  String? receivedName;
  bool tapped = false;
  Future getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        return;
      } else {
        final cropimage = await cropImage(image.path);
        final finalImage = await saveFilePermanently(cropimage!);
        setState(() {
          this._image = finalImage;
          img = finalImage.path;
          receivedName = null; // Reset received name when new image is selected
        });

        // Send the image to the server
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<String?> cropImage(String imageFile) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: imageFile,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));
    if (croppedImage == null) {
      return null;
    } else {
      return croppedImage.path;
    }
  }

  Future<File> saveFilePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = Path.basename(imagePath);
    final image = File('${directory.path}/$name');
    return File(imagePath).copy(image.path);
  }

  Future<void> sendImageToServer(File imageFile) async {
    try {
      final url = Uri.parse('http://192.168.1.120:8000/recognize-image/');
      final request = http.MultipartRequest('POST', url);
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final personName = jsonResponse['person_name'];
        setState(() {
          receivedName = personName;
        });
      } else {
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialogBox(
                  alertText:
                      'Failed to send image to server. Status code: ${response.statusCode}');
            });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialogBox(alertText: e.toString());
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Security System",
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: Colors.green.shade100,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            child: _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.file(_image!))
                : Image.asset("lib/assets/man.png"),
          ),
          const SizedBox(
            height: 20,
          ),
          if (receivedName != null) Text('Name: $receivedName'),
          const SizedBox(
            height: 50,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                getImage(ImageSource.camera);
              },
              child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                    child: tapped != true
                        ? const Text(
                            "CAPTURE",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        : const Text(
                            "RE-CAPTURE",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: GestureDetector(
              onTap: _image != null && tapped == false
                  ? () {
                      sendImageToServer(_image!);
                      setState(() {
                        tapped = true;
                      });
                    }
                  : null,
              // Only allow onTap if image is selected
              child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                    child: Text(
                  "VERIFY",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ),
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return VerifiedScreen(
                        name: "amrit",
                        imgpath: "lib/assets/amrit.jpg",
                      );
                    });
              },
              child: Text("PRESS ME"))
        ],
      ),
    );
  }
}
