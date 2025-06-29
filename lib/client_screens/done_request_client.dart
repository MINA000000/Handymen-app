import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/api_services/api_service_sentiment_analysis.dart';
import 'package:grad_project/components/collections.dart';
import 'package:grad_project/components/dialog_utils.dart';
import 'package:grad_project/components/image_viewer_screen.dart';

class DoneRequestClient extends StatefulWidget {
  final QueryDocumentSnapshot request;

  const DoneRequestClient({required this.request, super.key});

  @override
  _DoneRequestClientState createState() => _DoneRequestClientState();
}

class _DoneRequestClientState extends State<DoneRequestClient> {
  bool showCommentBox = false;
  TextEditingController commentController = TextEditingController();
  int selectedRating = 0;
  DocumentSnapshot? handyman;
  DocumentSnapshot? client;
  bool isCommentExist = false;
  bool isLoading = true;
  bool isButtonLoading = false;

  Future<void> _fetchHandymanClient() async {
    try {
      await _checkCommentExisting();
      handyman = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(widget.request[RequestFieldsName.assignedHandyman])
          .get();
      client = await FirebaseFirestore.instance
          .collection(CollectionsNames.clientsInformation)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to load data. Please try again.',
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
    }
  }

  Future<void> _checkCommentExisting() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(widget.request[RequestFieldsName.assignedHandyman])
          .collection(CollectionsNames.comments)
          .where(CommentsFieldsName.clientId,
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where(CommentsFieldsName.requestId, isEqualTo: widget.request.id)
          .get();

      setState(() {
        isCommentExist = querySnapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print("Error checking comment: $e");
    }
  }

  Future<void> _submitComment() async {
    if (commentController.text.isEmpty) {
      DialogUtils.buildShowDialog(
        context,
        title: 'Empty Comment',
        content: 'Please write your comment first.',
        titleColor: Color.fromRGBO(255, 61, 0, 0.9),
      );
      setState(() {
        isButtonLoading = false;
      });
      return;
    }

    try {
      setState(() {
        isButtonLoading = true;
      });

      final commentRef = FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(widget.request[RequestFieldsName.assignedHandyman])
          .collection(CollectionsNames.comments)
          .doc();

      final handymanRef = FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(widget.request[RequestFieldsName.assignedHandyman]);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final handymanSnapshot = await transaction.get(handymanRef);

        if (!handymanSnapshot.exists) {
          throw Exception('Handyman document does not exist');
        }

        final handymanData = handymanSnapshot.data() as Map<String, dynamic>;
        final currentCount =
            (handymanData['rating_count'] as num?)?.toInt() ?? 0;
        final currentAverage =
            (handymanData['rating_average'] as num?)?.toDouble() ?? 0.0;

        final newCount = currentCount + 1;
        final newAverage =
            ((currentAverage * currentCount) + selectedRating) / newCount;

        transaction.set(commentRef, {
          CommentsFieldsName.clientName:
              client?.get(ClientFieldsName.fullName) ?? 'Unknown',
          CommentsFieldsName.comment: commentController.text,
          CommentsFieldsName.rate: selectedRating,
          CommentsFieldsName.time: DateTime.now(),
          CommentsFieldsName.clientId: FirebaseAuth.instance.currentUser!.uid,
          CommentsFieldsName.requestId: widget.request.id,
        });

        transaction.update(handymanRef, {
          'rating_count': newCount,
          'rating_average': newAverage,
        });
      });
      ApiServiceSentimentAnalysis api = ApiServiceSentimentAnalysis();
      await api.sendReview(commentController.text, widget.request[RequestFieldsName.assignedHandyman]);
      Navigator.of(context).pop();
    } catch (e) {
      print('Error submitting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to submit comment. Please try again.',
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
        isButtonLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHandymanClient();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double avatarRadius = screenWidth * 0.2; // Responsive avatar size

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
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(255, 255, 255, 0.7),
              ),
            )
          : Scaffold(
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
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
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
                    'Completed Request',
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
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromRGBO(255, 255, 255, 0.3),
                                Color.fromRGBO(255, 255, 255, 0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: Color.fromRGBO(255, 255, 255, 0.1),
                            backgroundImage: handyman?[HandymanFieldsName
                                            .profilePicture] !=
                                        null &&
                                    handyman![HandymanFieldsName.profilePicture]
                                        .isNotEmpty
                                ? NetworkImage(handyman![
                                    HandymanFieldsName.profilePicture])
                                : null,
                            child: handyman?[HandymanFieldsName
                                            .profilePicture] ==
                                        null ||
                                    handyman![HandymanFieldsName.profilePicture]
                                        .isEmpty
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white70,
                                    size: 90,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        duration: const Duration(milliseconds: 700),
                        child: Text(
                          handyman?[HandymanFieldsName.fullName] ?? 'Unknown',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.95),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Nunito',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          handyman?[HandymanFieldsName.category] ??
                              'No category',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.7),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 900),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(5, (index) {
                              final rating =
                                  (handyman?[HandymanFieldsName.ratingAverage]
                                              as num?)
                                          ?.toDouble() ??
                                      0.0;
                              final starValue = index + 0.5;
                              return Icon(
                                rating >= starValue
                                    ? Icons.star
                                    : rating >= starValue - 0.5
                                        ? Icons.star_half
                                        : Icons.star_border,
                                color: Color.fromRGBO(255, 61, 0, 0.9),
                                size: 24,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${(handyman?[HandymanFieldsName.ratingAverage] as num?)?.toDouble().toStringAsFixed(1) ?? '0.0'}/5',
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.95),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Request Completed',
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.95),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Nunito',
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(33, 150, 243, 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color.fromRGBO(33, 150, 243, 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'DONE',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color.fromRGBO(33, 150, 243, 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1100),
                        child: Container(
                          width: screenWidth * 0.9,
                          padding: const EdgeInsets.all(16),
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
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.request[RequestFieldsName.request] ??
                                'No details provided',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(33, 33, 33, 0.9),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1200),
                        child: Text(
                          'Photo',
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.95),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Nunito',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1300),
                        child: GestureDetector(
                          onTap: widget.request[RequestFieldsName.imageURL] !=
                                      null &&
                                  widget.request[RequestFieldsName.imageURL]
                                      .isNotEmpty
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageViewerScreen(
                                          imageUrl: widget.request[
                                              RequestFieldsName.imageURL]),
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            width: screenWidth * 0.5,
                            height: screenWidth * 0.5,
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: widget.request[
                                              RequestFieldsName.imageURL] !=
                                          null &&
                                      widget.request[RequestFieldsName.imageURL]
                                          .isNotEmpty
                                  ? Image.network(
                                      widget
                                          .request[RequestFieldsName.imageURL],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.1),
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.white70,
                                          size: 50,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Color.fromRGBO(255, 255, 255, 0.1),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white70,
                                        size: 50,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: GestureDetector(
                          onTap: isCommentExist
                              ? null
                              : () {
                                  setState(() {
                                    showCommentBox = !showCommentBox;
                                  });
                                },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: 32,
                                color: isCommentExist
                                    ? Color.fromRGBO(255, 255, 255, 0.5)
                                    : Color.fromRGBO(255, 255, 255, 0.95),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCommentExist
                                    ? 'Comment Submitted'
                                    : 'Add Comment',
                                style: TextStyle(
                                  color: isCommentExist
                                      ? Color.fromRGBO(255, 255, 255, 0.5)
                                      : Color.fromRGBO(255, 255, 255, 0.95),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Nunito',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (showCommentBox)
                        ZoomIn(
                          duration: const Duration(milliseconds: 1500),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 0.95),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color.fromRGBO(255, 255, 255, 0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: commentController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      hintText: 'Write your comment here...',
                                      hintStyle: TextStyle(
                                        color: Color.fromRGBO(33, 33, 33, 0.5),
                                        fontFamily: 'Nunito',
                                      ),
                                      filled: true,
                                      fillColor:
                                          Color.fromRGBO(255, 255, 255, 0.95),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 16,
                                      color: Color.fromRGBO(33, 33, 33, 0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      return IconButton(
                                        icon: Icon(
                                          index < selectedRating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color:
                                              Color.fromRGBO(255, 61, 0, 0.9),
                                          size: 32,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selectedRating = index + 1;
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 16),
                                  ZoomIn(
                                    duration:
                                        const Duration(milliseconds: 1600),
                                    child: ElevatedButton(
                                      onPressed:
                                          isButtonLoading || isCommentExist
                                              ? null
                                              : _submitComment,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromRGBO(255, 61, 0, 0.9),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 60, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        elevation: 8,
                                        shadowColor:
                                            Color.fromRGBO(0, 0, 0, 0.3),
                                      ),
                                      child: isButtonLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              isCommentExist
                                                  ? 'Done'
                                                  : 'Submit',
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
                                ],
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
