import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/chat_page.dart';
import 'package:grad_project/components/firebase_methods.dart';
import 'package:intl/intl.dart';
import '../components/collections.dart';
import '../components/image_viewer_screen.dart';

class HandymanDetailsScreen2 extends StatefulWidget {
  final String handymanUid;
  final String requestId;
  const HandymanDetailsScreen2(
      {required this.requestId, required this.handymanUid, super.key});

  @override
  State<HandymanDetailsScreen2> createState() => _HandymanDetailsScreen2State();
}

class _HandymanDetailsScreen2State extends State<HandymanDetailsScreen2> {
  bool _isLoading = false;

  Future<Map<String, dynamic>> _fetchHandymanDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(widget.handymanUid)
          .get();
      if (!doc.exists) return {};

      final data = doc.data() ?? {};
      // Fetch up to 10 comments
      final commentsSnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(widget.handymanUid)
          .collection('comments')
          .limit(10)
          .get();
      final comments = commentsSnapshot.docs.map((commentDoc) {
        final commentData = commentDoc.data();
        final time = (commentData['time'] as Timestamp?)?.toDate();
        return {
          'client_name': commentData['client_name'] ?? 'Unknown',
          'comment': commentData['comment'] ?? 'No comment',
          'rate': commentData['rate']?.toString() ?? 'N/A',
          'time': time != null
              ? DateFormat('dd MMMM yyyy, HH:mm').format(time)
              : 'No date',
        };
      }).toList();

      // Fetch up to 10 work pictures
      final workPicturesSnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(widget.handymanUid)
          .collection('work_pictures')
          .limit(10)
          .get();
      final workPictures = workPicturesSnapshot.docs
          .map((doc) => doc.data()['image_url']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList();

      return {
        'full_name': data['full_name'] ?? 'Unknown',
        'category': data['category'] ?? 'No Category',
        'description': data['description'] ?? 'No description available',
        'profile_picture': data['profile_picture'] ?? '',
        'rating_average': data['rating_average']?.toString() ?? 'N/A',
        'rating_count': data['rating_count']?.toString() ?? '0',
        'email': data['email'] ?? "Error",
        'uid': doc.id,
        'comments': comments,
        'work_pictures': workPictures,
      };
    } catch (e) {
      print(
          'Error fetching handyman details for UID ${widget.handymanUid}: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF56AB94),
            Color(0xFF2E3B4E),
          ],
          stops: [0.0, 1.0],
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
                  Color(0xFF56AB94),
                  Color(0xFF2E3B4E),
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
                color: Color.fromARGB(255, 240, 239, 239),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
                letterSpacing: 1.0,
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
                  color: Colors.black,
                  size: 24,
                ),
              ),
              tooltip: 'Back',
            ),
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _fetchHandymanDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.black.withValues(alpha: 0.8),
                  strokeWidth: 4,
                ),
              );
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Error loading handyman details.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black.withValues(alpha: 0.8),
                    fontFamily: 'Nunito',
                  ),
                ),
              );
            }
            final handyman = snapshot.data!;
            final hasComments = handyman['comments']?.isNotEmpty ?? false;
            final hasWorkPictures =
                handyman['work_pictures']?.isNotEmpty ?? false;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    Card(
                      elevation: 6,
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF56AB94).withValues(alpha: 0.4),
                              Color(0xFF2E3B4E).withValues(alpha: 0.4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: handyman['profile_picture']
                                                  ?.isNotEmpty ??
                                              false
                                          ? Image.network(
                                              handyman['profile_picture'],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(
                                                Icons.person,
                                                color: Colors.black,
                                                size: 80,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              color: Colors.black,
                                              size: 80,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          handyman['full_name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black,
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                        Text(
                                          handyman['category'] ?? 'No Category',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black
                                                .withValues(alpha: 0.8),
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Rating: ${handyman['rating_average']}/5 (${handyman['rating_count']} reviews)',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black
                                                .withValues(alpha: 0.8),
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              FadeInUp(
                                duration: const Duration(milliseconds: 700),
                                child: Text(
                                  'About Me',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black.withValues(alpha: 0.9),
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              FadeInUp(
                                duration: const Duration(milliseconds: 700),
                                child: Text(
                                  handyman['description'] ??
                                      'No description available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.7),
                                    fontFamily: 'Nunito',
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Comments Section (collapsible, only if comments exist)
                    if (hasComments)
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: ExpansionTile(
                          title: Text(
                            'Comments (${handyman['comments'].length})',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 230, 221, 221),
                              fontSize: 20,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          trailing: Icon(
                            Icons.expand_more,
                            color: Colors.black,
                          ),
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 0),
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          children: [
                            const SizedBox(height: 8),
                            ...handyman['comments'].map<Widget>((comment) {
                              return FadeInUp(
                                duration: const Duration(milliseconds: 800),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF56AB94)
                                              .withValues(alpha: 0.2),
                                          Color(0xFF2E3B4E)
                                              .withValues(alpha: 0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'From ${comment['client_name']}:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black
                                                  .withValues(alpha: 0.8),
                                              fontFamily: 'Nunito',
                                            ),
                                          ),
                                          Text(
                                            comment['comment'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black
                                                  .withValues(alpha: 0.7),
                                              fontFamily: 'Nunito',
                                            ),
                                          ),
                                          Text(
                                            'Rating: ${comment['rate']}/5 - ${comment['time']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black
                                                  .withValues(alpha: 0.6),
                                              fontFamily: 'Nunito',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    if (hasComments) const SizedBox(height: 24),
                    // Work Pictures Section (collapsible, only if pictures exist)
                    if (hasWorkPictures)
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: ExpansionTile(
                          title: Text(
                            'Work Pictures (${handyman['work_pictures'].length})',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          trailing: Icon(
                            Icons.expand_more,
                            color: Colors.black,
                          ),
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 0),
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          children: [
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: handyman['work_pictures'].length,
                                itemBuilder: (context, index) {
                                  final imageUrl =
                                      handyman['work_pictures'][index];
                                  return FadeInUp(
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ImageViewerScreen(
                                                imageUrl: imageUrl,
                                              ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            imageUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF56AB94)
                                                        .withValues(alpha: 0.2),
                                                    Color(0xFF2E3B4E)
                                                        .withValues(alpha: 0.2),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.black54,
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (hasWorkPictures) const SizedBox(height: 24),
                    // Buttons (Accept and Chat)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection(CollectionsNames
                                              .requestInformation)
                                          .doc(widget.requestId)
                                          .update({
                                        'client_wanting_handymen':
                                            FieldValue.arrayRemove(
                                                [handyman['uid']]),
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Request is Canceled Successfully',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor: Color.fromRGBO(
                                              45, 219, 118, 0.698),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );

                                      int count = 0;
                                      Navigator.popUntil(context, (route) {
                                        return count++ == 2;
                                      });
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to cancel request: $e',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor:
                                              Color.fromRGBO(255, 61, 0, 0.7),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    } finally {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 171, 113, 86),
                                    Color.fromARGB(255, 151, 30, 30),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 80,
                                      height: 24,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Color.fromARGB(
                                              255, 207, 201, 201),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.cancel,
                                          color: Color.fromARGB(
                                              255, 207, 201, 201),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Cancel',
                                          style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 218, 206, 206),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Nunito',
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1100),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                      email: handyman['email'] ?? "Error"),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF56AB94),
                                    Color(0xFF2E3B4E),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Color.fromARGB(255, 207, 200, 200),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Chat',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 223, 215, 215),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Nunito',
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
