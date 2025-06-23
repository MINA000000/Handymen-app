import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/Providers/requests_provider_client.dart';
import 'package:grad_project/components/image_viewer_screen.dart';
import 'package:provider/provider.dart';
import '../components/firebase_methods.dart';
import '../components/collections.dart';

class HandymanDetailsPage extends StatefulWidget {
  final Map<String, dynamic> handyman;
  final String handymanUId;
  final String docid;

  const HandymanDetailsPage({
    required this.handyman,
    required this.docid,
    required this.handymanUId,
    super.key,
  });

  @override
  State<HandymanDetailsPage> createState() => _HandymanDetailsPageState();
}

class _HandymanDetailsPageState extends State<HandymanDetailsPage> {
  List<QueryDocumentSnapshot> workPictures = [];
  List<QueryDocumentSnapshot> comments = [];
  bool masterLoading = true;
  bool buttonLoading = false;
  bool sendCorrectly = false;
  String? errorMessage;

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> fetchWorkPictures() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(widget.handymanUId)
          .collection(CollectionsNames.workPictures)
          .get();
      workPictures = querySnapshot.docs;
    } catch (e) {
      print("Error fetching work pictures: $e");
      errorMessage = 'Failed to load work pictures.';
    }
  }

  Future<void> fetchComments() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(widget.handymanUId)
          .collection(CollectionsNames.comments)
          .get();
      comments = querySnapshot.docs;
    } catch (e) {
      print("Error fetching comments: $e");
      errorMessage = 'Failed to load comments.';
    }
  }

  @override
  void initState() {
    super.initState();
    Future.wait([fetchWorkPictures(), fetchComments()]).then((_) {
      setState(() {
        masterLoading = false;
        if (errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Color.fromRGBO(255, 61, 0, 0.7),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    });
  }

  Future<void> _makeRequest(context) async {
    final requestsProvider = Provider.of<RequestsProviderClient>(context, listen: false);
    setState(() {
      buttonLoading = true;
    });
    try {
      await FirebaseMethods.addToArrayRequestsCollection(
        widget.docid,
        widget.handymanUId,
        RequestFieldsName.clientWantingHandymen,
      );
      setState(() {
        sendCorrectly = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Request sent successfully!',
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
    } catch (e) {
      print('Error sending request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to send request. Please try again.',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Color.fromRGBO(255, 61, 0, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        buttonLoading = false;
        requestsProvider.changeState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
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
              'Handyman Details',
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
                        'Settings feature coming soon!',
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
                        Icons.settings_outlined,
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                        size: 28,
                      ),
                    );
                  },
                ),
                tooltip: 'Settings',
              ),
            ),
          ],
        ),
        body: masterLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(255, 255, 255, 0.7),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: GestureDetector(
                        onTap: widget
                                    .handyman[HandymanFieldsName.profilePicture]
                                    ?.isNotEmpty ??
                                false
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewerScreen(
                                      imageUrl: widget.handyman[
                                          HandymanFieldsName.profilePicture],
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Color.fromRGBO(255, 255, 255, 0.1),
                          backgroundImage:
                              widget.handyman[HandymanFieldsName.profilePicture]
                                          ?.isNotEmpty ??
                                      false
                                  ? NetworkImage(widget.handyman[
                                      HandymanFieldsName.profilePicture])
                                  : null,
                          child:
                              widget.handyman[HandymanFieldsName.profilePicture]
                                          ?.isEmpty ??
                                      true
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white70,
                                      size: 80,
                                    )
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: Text(
                        widget.handyman[HandymanFieldsName.fullName] ??
                            'Unknown',
                        style: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.95),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Nunito',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        widget.handyman[HandymanFieldsName.category] ??
                            'No category',
                        style: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.7),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      duration: const Duration(milliseconds: 900),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          color: Color.fromRGBO(255, 255, 255, 0.95),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'About Me',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color.fromRGBO(33, 33, 33, 0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.handyman[
                                            HandymanFieldsName.description] ??
                                        'No description available.',
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 16,
                                      color: Color.fromRGBO(33, 33, 33, 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (workPictures.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Work Photos',
                            style: const TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.95),
                              fontSize: 22,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1100),
                        child: SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: workPictures.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ImageViewerScreen(
                                        imageUrl: workPictures[index]
                                                ['image_url'] ??
                                            '',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 12, right: 12),
                                  width: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage(workPictures[index]
                                              ['image_url'] ??
                                          ''),
                                      fit: BoxFit.cover,
                                      onError: (exception, stackTrace) =>
                                          const AssetImage(
                                              'assets/placeholder.png'),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    if (comments.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Client Comments',
                            style: const TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.95),
                              fontSize: 22,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1300),
                        child: SizedBox(
                          height: 220,
                          child: ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              var comment = comments[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                color: Color.fromRGBO(255, 255, 255, 0.95),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Color.fromRGBO(33, 150, 243, 0.9),
                                      child: Text(
                                        (comment[CommentsFieldsName
                                                    .clientName] ??
                                                '')[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      comment[CommentsFieldsName.clientName] ??
                                          'Anonymous',
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color.fromRGBO(33, 33, 33, 0.9),
                                      ),
                                    ),
                                    subtitle: Text(
                                      comment[CommentsFieldsName.comment] ??
                                          'No comment provided.',
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 14,
                                        color: Color.fromRGBO(33, 33, 33, 0.7),
                                      ),
                                    ),
                                    trailing: Text(
                                      formatDate(
                                          comment[CommentsFieldsName.time]),
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 12,
                                        color: Color.fromRGBO(33, 33, 33, 0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1400),
                      child: ElevatedButton(
                        onPressed: buttonLoading || sendCorrectly
                            ? null
                            : () {
                                _makeRequest(context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(255, 61, 0, 0.9),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                          shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                        ),
                        child: buttonLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                sendCorrectly
                                    ? 'Request Sent'
                                    : 'Make My Request',
                                style: const TextStyle(
                                  fontSize: 20,
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
    );
  }
}
