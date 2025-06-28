import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:grad_project/components/collections.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  bool isLoading = true;
  String? errorMessage;
  List<QueryDocumentSnapshot> workPictures = [];
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  Future<void> fetchWorkPictures() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('work_pictures')
          .orderBy(WorkPictures.timestamp, descending: true)
          .get();

      setState(() {
        workPictures = querySnapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching work pictures: $e");
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load work pictures. Please try again.';
      });
      _showSnackBar(errorMessage!, isError: true);
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      setState(() {
        isUploading = true;
      });

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        setState(() {
          isUploading = false;
        });
        return;
      }

      final file = File(image.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('work_pictures')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('work_pictures')
          .add({
        WorkPictures.imageUrl: downloadUrl,
        WorkPictures.timestamp: Timestamp.now(),
      });

      await fetchWorkPictures();
      setState(() {
        isUploading = false;
      });
      _showSnackBar('Image uploaded successfully!');
    } catch (e) {
      print("Error uploading image: $e");
      setState(() {
        isUploading = false;
        errorMessage = 'Failed to upload image. Please try again.';
      });
      _showSnackBar(errorMessage!, isError: true);
    }
  }

  Future<void> deleteImage(String docId, String imageUrl) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('work_pictures')
          .doc(docId)
          .delete();

      // Delete from Storage
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();

      await fetchWorkPictures();
      _showSnackBar('Image deleted successfully!');
    } catch (e) {
      print("Error deleting image: $e");
      setState(() {
        errorMessage = 'Failed to delete image. Please try again.';
      });
      _showSnackBar(errorMessage!, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError
            ? Color.fromRGBO(255, 61, 0, 0.7)
            : Color.fromRGBO(33, 150, 243, 0.7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(String docId, String imageUrl) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return ZoomIn(
          duration: const Duration(milliseconds: 400),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(86, 171, 148, 0.95),
                    Color.fromRGBO(83, 99, 108, 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color.fromRGBO(255, 255, 255, 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Delete Image',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 61, 0, 0.9),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Nunito',
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Are you sure you want to delete this image?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Nunito',
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ZoomIn(
                        duration: const Duration(milliseconds: 600),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(33, 150, 243, 0.9),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 8,
                            shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      ZoomIn(
                        duration: const Duration(milliseconds: 600),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            deleteImage(docId, imageUrl);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(255, 61, 0, 0.9),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 8,
                            shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    fetchWorkPictures();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      height: double.infinity,
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
              'My Work Pictures',
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
                  _showSnackBar('Notifications feature coming soon!');
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
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(255, 255, 255, 0.7),
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: errorMessage != null
                        ? Center(
                            child: FadeInUp(
                              duration: const Duration(milliseconds: 600),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromRGBO(255, 255, 255, 0.15),
                                      Color.fromRGBO(255, 255, 255, 0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color.fromRGBO(255, 255, 255, 0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Nunito',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        : workPictures.isEmpty
                            ? Center(
                                child: FadeInUp(
                                  duration: const Duration(milliseconds: 600),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color.fromRGBO(255, 255, 255, 0.15),
                                          Color.fromRGBO(255, 255, 255, 0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Color.fromRGBO(255, 255, 255, 0.2),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'No work pictures available. Add some using the button below!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Nunito',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: workPictures.length,
                                itemBuilder: (context, index) {
                                  final picture = workPictures[index];
                                  return FadeInUp(
                                    duration: Duration(milliseconds: 700 + (index * 100)),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      color: Colors.transparent,
                                      elevation: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color.fromRGBO(255, 255, 255, 0.95),
                                              Color.fromRGBO(245, 245, 245, 0.95),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Color.fromRGBO(255, 255, 255, 0.2),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromRGBO(0, 0, 0, 0.15),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: const BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                ),
                                                child: Image.network(
                                                  picture[WorkPictures.imageUrl] ?? '',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    color: Color.fromRGBO(255, 255, 255, 0.1),
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      color: Colors.white70,
                                                      size: 50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      _formatTimestamp(picture[WorkPictures.timestamp]),
                                                      style: const TextStyle(
                                                        fontFamily: 'Nunito',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color.fromRGBO(33, 33, 33, 0.7),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Color.fromRGBO(255, 61, 0, 0.9),
                                                      size: 24,
                                                    ),
                                                    onPressed: () => _showDeleteConfirmationDialog(
                                                      picture.id,
                                                      picture[WorkPictures.imageUrl],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
        floatingActionButton: ZoomIn(
          duration: const Duration(milliseconds: 800),
          child: FloatingActionButton(
            onPressed: isUploading ? null : pickAndUploadImage,
            backgroundColor: Color.fromRGBO(255, 61, 0, 0.9),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: isUploading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : const Icon(
                    Icons.add_photo_alternate,
                    color: Colors.white,
                    size: 30,
                  ),
          ),
        ),
      ),
    );
  }
}

class WorkPictures {
  static String get imageUrl => 'image_url';
  static String get timestamp => 'timestamp';
}