import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/components/dialog_utils.dart';
import 'package:grad_project/components/firebase_methods.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'handymen_profiles.dart';

class RequestScreen extends StatefulWidget {
  final String categoryName;
  const RequestScreen({required this.categoryName, super.key});

  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final TextEditingController _requestController = TextEditingController();
  bool isloading = false;
  File? _image;
  int imageNum = 0;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final savedImage = await _saveImageToLocal(File(pickedFile.path));
      setState(() {
        _image = savedImage;
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(86, 171, 148, 0.95),
            Color.fromRGBO(83, 99, 108, 0.95),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(86, 171, 148, 0.95),
            Color.fromRGBO(83, 99, 108, 0.95),
                ],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          title: FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: const Text(
              'Request',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
                letterSpacing: 1.0,
                shadows: [
                  Shadow(
                    color: Color.fromRGBO(0, 0, 0, 0.26),
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              tooltip: 'Back',
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Notifications feature coming soon!',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Color.fromRGBO(33, 150, 243, 0.7),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 1.0 + (value * 0.1),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                        size: 28,
                      ),
                    );
                  },
                ),
                tooltip: 'Notifications',
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 40),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    width: 300,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _requestController,
                      maxLines: 6,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        color: Color.fromRGBO(33, 33, 33, 0.9),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write your request...',
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          fontFamily: 'Nunito',
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: _image == null
                      ? const SizedBox.shrink()
                      : Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 240,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Color.fromRGBO(255, 61, 0, 0.9),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Upload Photo',
                            style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.9),
                              fontSize: 18,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.upload_file,
                            color: Color.fromRGBO(255, 255, 255, 0.9),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  duration: const Duration(milliseconds: 1200),
                  child: ElevatedButton(
                    onPressed: isloading
                        ? null
                        : () async {
                            setState(() {
                              isloading = true;
                            });
                            if (_requestController.text.isEmpty) {
                              await DialogUtils.buildShowDialog(
                                context,
                                title: "Empty Request",
                                content: 'Please fill your request',
                                titleColor: Colors.red,
                              );
                              setState(() {
                                isloading = false;
                              });
                              return;
                            }
                            try {
                              String downloadURL = '';
                              if (_image != null) {
                                downloadURL = await FirebaseMethods.uploadImage(_image!);
                              }
                              DateTime now = DateTime.now();
                              String docid = await FirebaseMethods.setRequestInformation(
                                uid: FirebaseAuth.instance.currentUser!.uid,
                                request: _requestController.text,
                                imageURL: downloadURL,
                                status: RequestStatus.notApproved,
                                timestamp: now,
                                category: widget.categoryName,
                                handyman: 'none',
                              );
                              await DialogUtils.buildShowDialog(
                                context,
                                title: "Done",
                                content: 'You can now send to handyman to do this work',
                                titleColor: Colors.green,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HandymenProfiles(
                                    categoryName: widget.categoryName,
                                    request: _requestController.text,
                                    docId: docid,
                                  ),
                                ),
                              );
                            } catch (e) {
                              print(e);
                              await DialogUtils.buildShowDialog(
                                context,
                                title: "Error",
                                content: 'An error occurred. Please try again.',
                                titleColor: Colors.red,
                              );
                            } finally {
                              _image = null;
                              _requestController.clear();
                              setState(() {
                                isloading = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(255, 61, 0, 0.9),
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 8,
                      shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                    ),
                    child: isloading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Send',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}