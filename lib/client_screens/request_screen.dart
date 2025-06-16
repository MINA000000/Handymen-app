import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/components/dialog_utils.dart';
import 'package:grad_project/components/firebase_methods.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'handymen_profiles.dart';

class RequestScreen extends StatefulWidget {
  String categoryName;
  RequestScreen({required this.categoryName});
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  TextEditingController _requestController = TextEditingController();
  bool isloading = false;
  File? _image;
  int imageNum = 0;
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery); // Use ImageSource.camera for camera

    if (pickedFile != null) {
      final savedImage = await _saveImageToLocal(File(pickedFile.path));
      setState(() {
        _image = savedImage; // Update the image when tapped again
      });
    }
  }

  Future<File> _saveImageToLocal(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/profile_image$imageNum.png';
    imageNum++;
    final savedImage = await image.copy(path);
    return savedImage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.71, -0.71),
          end: Alignment(-0.71, 0.71),
          colors: [Color(0xFF56AB94), Color(0xFF53636C)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Request',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications),
              color: Colors.white,
            )
          ],
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Container(
                  width: 269,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _requestController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'write your request',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                (_image == null)
                    ? SizedBox.shrink()
                    : Container(
                        width: 150,
                        height: 150,
                        child: Image.file(_image!, fit: BoxFit.cover)),
                SizedBox(
                  height: 15,
                ),
                // Upload Button
                GestureDetector(
                  onTap: () async {
                    await _pickImage();
                  },
                  child: Container(
                    width: 231,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFFFF3D00)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'upload photo',
                          style: TextStyle(
                            color: Color(0xFFF5F5F5),
                            fontSize: 20,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Icon(Icons.upload_file, color: Color(0xFFF5F5F5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Send Button
                ElevatedButton(
                  onPressed: isloading
                      ? null
                      : () async {
                          //TODO
                          setState(() {
                            isloading = true;
                          });
                          if (_requestController.text.isEmpty) {
                            await DialogUtils.buildShowDialog(context,
                                title: "Empty request",
                                content: 'Please fill your request',
                                titleColor: Colors.red);
                            setState(() {
                              isloading = false;
                            });
                            return;
                          }
                          try {
                            String downloadURL = '';
                            if (_image != null) {
                              downloadURL =
                                  await FirebaseMethods.uploadImage(_image!);
                            }
                            DateTime now = DateTime.now();
                            String docid =
                                await FirebaseMethods.setRequestInformation(
                                    uid: FirebaseAuth.instance.currentUser!.uid,
                                    request: _requestController.text,
                                    imageURL: downloadURL,
                                    status: RequestStatus.notApproved,
                                    timestamp: now,
                                    category: widget.categoryName,
                                    handyman: 'none');
                            await DialogUtils.buildShowDialog(context,
                                title: "Done",
                                content:
                                    'You can now send to handyman to do this work',
                                titleColor: Colors.green);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HanymenProfiles(
                                    categoryName: widget.categoryName,
                                    request: _requestController.text,
                                    docId: docid,
                                  ),
                                ));
                          } catch (e) {
                            print(e);
                          } finally {
                            _image = null;
                            _requestController.clear();
                            setState(() {
                              isloading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3D00),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isloading
                      ? CircularProgressIndicator(
                          color: Colors.grey,
                        )
                      : const Text(
                          'Send',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito',
                            color: Colors.white,
                          ),
                        ),
                ),
                // const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
