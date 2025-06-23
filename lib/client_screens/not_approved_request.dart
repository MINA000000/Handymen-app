import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/Providers/requests_provider_client.dart';
import 'package:grad_project/client_screens/done_request_client.dart';
import 'package:grad_project/client_screens/handymen_profiles.dart';
import 'package:grad_project/components/image_viewer_screen.dart';
import 'package:provider/provider.dart';
import '../components/collections.dart';

class NotApprovedRequest extends StatefulWidget {
  final QueryDocumentSnapshot request;

  const NotApprovedRequest({required this.request, super.key});

  @override
  State<NotApprovedRequest> createState() => _NotApprovedRequestState();
}

class _NotApprovedRequestState extends State<NotApprovedRequest> {
  bool _isDeleting = false;

  // Future<void> _deleteRequest(BuildContext context) async {
  //   setState(() {
  //     _isDeleting = true;
  //   });

  //   try {
  //     await FirebaseFirestore.instance
  //         .collection(CollectionsNames.requestInformation)
  //         .doc(widget.request.id)
  //         .delete();

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text(
  //           'Request deleted successfully!',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontFamily: 'Nunito',
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         backgroundColor: Color.fromRGBO(33, 150, 243, 0.7),
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         duration: const Duration(seconds: 2),
  //       ),
  //     );

  //     // Pop back to the previous screen after successful deletion
  //     Navigator.pop(context);
  //   } catch (e) {
  //     print('Error deleting request: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text(
  //           'Failed to delete request. Please try again.',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontFamily: 'Nunito',
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         backgroundColor: Color.fromRGBO(255, 61, 0, 0.7),
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         duration: const Duration(seconds: 2),
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       _isDeleting = false;
  //     });
  //   }
  // }
Future<void> _deleteRequest(BuildContext context) async {
  if (!mounted) return;

  setState(() {
    _isDeleting = true;
  });

  try {
    // Pop screen first
    Navigator.pop(context);

    // Small delay to ensure pop transition finishes before deletion
    await Future.delayed(const Duration(milliseconds: 300));

    // Delete from Firestore
    await FirebaseFirestore.instance
        .collection(CollectionsNames.requestInformation)
        .doc(widget.request.id)
        .delete();

    // Optionally, you can notify the previous screen via a result:
    // Navigator.pop(context, 'deleted'); and handle that there
  } catch (e) {
    print('Error deleting request: $e');

    // Can't show a snackbar on this screen anymore, but you can:
    // - Pass back an error
    // - Log it
    // - Or show a global error using a provider/snackbar manager
  } finally {
    if (mounted) {
      setState(() {
        _isDeleting = false;
      });
    }
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
              'Request Details',
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
                    width: 350,
                    padding: const EdgeInsets.all(16.0),
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
                    child: Text(
                      widget.request[RequestFieldsName.request] ??
                          'No request details',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(33, 33, 33, 0.9),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: widget.request[RequestFieldsName.imageURL]
                              ?.isNotEmpty ??
                          false
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewerScreen(
                                  imageUrl: widget
                                      .request[RequestFieldsName.imageURL],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 200,
                            height: 200,
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
                              child: Image.network(
                                widget.request[RequestFieldsName.imageURL],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Color.fromRGBO(255, 255, 255, 0.1),
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white70,
                                    size: 80,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.1),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white70,
                            size: 80,
                          ),
                        ),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HanymenProfiles(
                                categoryName: widget
                                        .request[RequestFieldsName.category] ??
                                    '',
                                docId: widget.request.id,
                                request:
                                    widget.request[RequestFieldsName.request] ??
                                        '',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(186, 209, 186, 0.894),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                          shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                        ),
                        child: const Text(
                          'Send to Handyman',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Nunito',
                            color: Color.fromARGB(255, 19, 1, 1),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _isDeleting
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor:
                                        Color.fromRGBO(255, 255, 255, 0.95),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: const Text(
                                      'Delete Request',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Color.fromRGBO(33, 33, 33, 0.9),
                                      ),
                                    ),
                                    content: const Text(
                                      'Are you sure you want to delete this request? This action cannot be undone.',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 16,
                                        color: Color.fromRGBO(33, 33, 33, 0.7),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromRGBO(
                                                33, 150, 243, 0.9),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteRequest(context);
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Color.fromRGBO(255, 61, 0, 0.9),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(255, 61, 0, 0.9),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                          shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                        ),
                        child: _isDeleting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Delete Request',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Nunito',
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ],
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

  Widget _buildSectionTitle(String title) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                blurRadius: 4,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(
      String category, String content, String handymanName) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Color.fromRGBO(255, 255, 255, 0.95),
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
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                'Category: $category',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color.fromRGBO(33, 33, 33, 0.9),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Request: $content',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      color: Color.fromRGBO(33, 33, 33, 0.7),
                    ),
                  ),
                  const Divider(color: Color.fromRGBO(0, 0, 0, 0.2)),
                  Text(
                    'Assigned to: $handymanName',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      color: Color.fromRGBO(33, 33, 33, 0.7),
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Color.fromRGBO(255, 61, 0, 0.9),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
