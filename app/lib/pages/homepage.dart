import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:minorprojapp/utils/animation.dart';
import 'package:minorprojapp/utils/verifiedscreen.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String? img;
  String? receivedName;
  String? userid;
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
        final personName = jsonResponse['name'];
        final id = jsonResponse['id'];
        setState(() {
          receivedName = personName;
          userid = id;
        });
      } else {
        if (kDebugMode) {
          print("failed");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> openLock(String id) async {
    try {
      final url = Uri.parse('http://192.168.1.125/openlock?id=$id');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        print(response.body);
      } else if (response.statusCode == 403) {
        print(response.body);
      } else if (response.statusCode == 401) {
        print(response.body);
      } else {
        print("ERROR !");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> Lock() async {
    try {
      final url = Uri.parse('http://192.168.1.125/lock?id=lock');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        print(response.body);
      } else {
        print("ERROR");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Security System",
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: Colors.green.shade200,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            child: _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.file(_image!))
                : Image.asset("lib/assets/images/man.png"),
          ),
          const SizedBox(
            height: 40,
          ),
          Center(
              child: GestureDetector(
            onTap: () {
              getImage(ImageSource.camera);
            },
            child: Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.green.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                  child: Text(
                "CAPTURE",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              )),
            ),
          )),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: GestureDetector(
              onTap: _image != null
                  ? () async {
                      // Show loading dialog immediately
                      showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Prevents the dialog from closing by touching outside
                          builder: (context) {
                            return const Center(
                                child: CircularProgressIndicator(
                              backgroundColor: Colors.black45,
                              color: Colors.green,
                            ));
                          });

                      await sendImageToServer(_image!);

                      Navigator.of(context).pop();
                      print(receivedName);
                      if (receivedName != null) {
                        if (receivedName!.toLowerCase() == "unknown") {
                          // ignore: use_build_context_synchronously
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return VerifiedScreen(
                                  ontap: () {
                                    Navigator.pop(context);
                                  },
                                  color: Colors.red.shade200,
                                  name: receivedName!,
                                  imgpath: "lib/assets/images/thief.jpg",
                                  verified: "lib/assets/logos/unverified.png",
                                  color2: Colors.red.shade300,
                                  text: "CLOSE",
                                );
                              });
                        } else {
                          // ignore: use_build_context_synchronously
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return VerifiedScreen(
                                  ontap: () {
                                    openLock(userid!);
                                    Navigator.pop(context);
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AnimationDialog(
                                              onTap: () {
                                                Lock();
                                                Navigator.pop(context);
                                                showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return AnimationDialog(
                                                          name:
                                                              "Succesfully Locked!",
                                                          text: "CLOSE",
                                                          animationpath:
                                                              "lib/assets/animations/lock.json",
                                                          color: Colors
                                                              .green.shade200,
                                                          color2: Colors
                                                              .green.shade300,
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                    });
                                              },
                                              name: "Succesfully Unlocked!",
                                              text: "LOCK",
                                              animationpath:
                                                  "lib/assets/animations/unlock.json",
                                              color: Colors.green.shade200,
                                              color2: Colors.green.shade400);
                                        });
                                  },
                                  color: Colors.green.shade200,
                                  name: receivedName!,
                                  imgpath:
                                      "lib/assets/images/${receivedName!.toLowerCase()}.jpg",
                                  verified: "lib/assets/logos/verified.png",
                                  text: "UNLOCK",
                                  color2: Colors.green.shade400,
                                );
                              });
                        }
                      }
                    }
                  : null,
              child: Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                    child: Text(
                  "VERIFY",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                )),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
              child: GestureDetector(
            onTap: () {
              Lock();
            },
            child: Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.green.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                  child: Text(
                "LOCK",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              )),
            ),
          )),
        ],
      ),
    );
  }
}
