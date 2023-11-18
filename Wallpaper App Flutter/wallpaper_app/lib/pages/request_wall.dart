import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uuid/uuid.dart';

class RequestWallpaper extends StatefulWidget {
  const RequestWallpaper({Key? key}) : super(key: key);

  @override
  State<RequestWallpaper> createState() => _RequestWallpaperState();
}

class _RequestWallpaperState extends State<RequestWallpaper> {
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController topicCtrl = TextEditingController();

  File? image;
  final picker = ImagePicker();
  var isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Custom Wallpaper'),
          backgroundColor: Colors.white,
        ),
        body: isLoading == true
            ? Center(
                child: CupertinoActivityIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(
                  children: [
                    const Text(
                      "Are you seeking for a specific wallpaper but can't seem to find it? Please email us if you have any wallpaper requests! In only a few days, we can design or locate practically any wallpaper you choose.",
                      style: TextStyle(fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    customTextField(topicCtrl, "Topic or description"),
                    const SizedBox(
                      height: 30,
                    ),

                    // ask user if he want to give some sample image
                    image == null
                        ? const Text(
                            "Do you want to send us a sample image?",
                            style: const TextStyle(fontSize: 16),
                          )
                        : GestureDetector(
                            onTap: () {
                              setState(() {
                                image = null;
                              });
                            },
                            child: const Text(
                              "Remove sample image",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: image != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(image!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 50,
                              decoration: BoxDecoration(
                                // border side color balck
                                border: Border.all(color: Colors.black),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('Select Image',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(FontAwesomeIcons.image,
                                      color: Colors.black, size: 16),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50,
                      // ignore: deprecated_member_use
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black
                        ),
                        onPressed: () {
                          saveDataToDB();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Submit',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(FontAwesomeIcons.longArrowAltRight,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }

  customTextField(controller, hint) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          label: Text(
            hint,
          ),
          fillColor: Colors.grey.withOpacity(0.2),
          filled: true,
          border: InputBorder.none,
        ),
      ),
    );
  }

  getImage() {
    final pickedfile = picker.pickImage(source: ImageSource.gallery);
    pickedfile.then((value) {
      setState(() {
        image = File(value!.path);
      });
    });
  }

  saveDataToDB() async {
    try {
      if (topicCtrl.text.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('Error'),
              content: const Text(
                'Please enter a topic or description',
              ),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          isLoading = true;
        });
        final id = Uuid().v1();
        final id2 = Uuid().v4();

        // Image Upload to Firebase Storage

        Reference reference =
            FirebaseStorage.instance.ref().child('sample_image/$id');
        UploadTask task = reference.putFile(image!.absolute);
        await Future.value(task);
        var url = await reference.getDownloadURL();

        // Generating user Token For Send Notification

        var status = await OneSignal.shared.getDeviceState();
        String? tokenId = status!.userId;

        // Save Data to Firebase Database
        FirebaseFirestore.instance
            .collection('request_wallpaper')
            .doc(id2)
            .set({
          'name': FirebaseAuth.instance.currentUser!.displayName,
          'email': FirebaseAuth.instance.currentUser!.email,
          'topic': topicCtrl.text,
          'image': url,
          'completed': false,
          'processed': false,
          "UserID": FirebaseAuth.instance.currentUser!.uid,
          'id': id2,
          'token': tokenId,
        }).then((value) {
          setState(() {
            isLoading = false;
            image = null;
            topicCtrl.clear();
          });
          showDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: const Text('Success'),
                content: const Text(
                  'Your request has been sent successfully',
                ),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          print('Data Saved');
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }
}
