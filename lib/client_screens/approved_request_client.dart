import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/Providers/requests_provider_client.dart';
import 'package:grad_project/chat_page.dart';
import 'package:grad_project/components/collections.dart';
import 'package:grad_project/components/image_viewer_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ApprovedRequestClient extends StatefulWidget {
  final QueryDocumentSnapshot request;

  const ApprovedRequestClient({required this.request, super.key});

  @override
  State<ApprovedRequestClient> createState() => _ApprovedRequestClientState();
}

class _ApprovedRequestClientState extends State<ApprovedRequestClient> {
  bool _isMarkingFinished = false;

  Future<void> _markRequestAsFinished(
      String requestId, BuildContext context) async {
    setState(() {
      _isMarkingFinished = true;
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference docRef = firestore
          .collection(CollectionsNames.requestInformation)
          .doc(requestId);

      await docRef.update({'status': 'done'});

      DocumentSnapshot snapshot = await docRef.get();
      final data = snapshot.data() as Map<String, dynamic>;
      String? handymanUid = data['assigned_handyman'];

      if (handymanUid != null && handymanUid.isNotEmpty) {
        DocumentReference handymanRef = firestore
            .collection(CollectionsNames.handymenInformation)
            .doc(handymanUid);
        await handymanRef.update({'projects_count': FieldValue.increment(1)});
      }

      // if (mounted) {
      //   Navigator.pop(context); // Navigate back to previous screen
      // }
    } catch (e) {
      print('Error marking request as finished: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingFinished = false;
        });
      }
    }
  }

  Future<String?> getHandymanEmail(String? uid) async {
    if (uid == null || uid.isEmpty) return null;
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(uid)
          .get();
      return userDoc.exists ? userDoc.get('email') as String? : null;
    } catch (e) {
      print('Error fetching handyman email: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchHandymanComments(
      String? handymanUid) async {
    if (handymanUid == null || handymanUid.isEmpty) return [];
    try {
      final commentsSnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(handymanUid)
          .collection('comments')
          .limit(10)
          .get();
      return commentsSnapshot.docs.map((commentDoc) {
        final commentData = commentDoc.data();
        final time = commentData['time'];
        return {
          'client_name': commentData['client_name'] ?? 'Anonymous',
          'comment': commentData['comment'] ?? 'No comment provided.',
          'rate': commentData['rate']?.toString() ?? 'N/A',
          'time': time,
        };
      }).toList();
    } catch (e) {
      print('Error fetching handyman comments: $e');
      return [];
    }
  }

  String formatDate(Timestamp? timestamp) {
    // return 'just now';
    if (timestamp == null) return 'Just now';
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.request.data() as Map<String, dynamic>;
    String? handymanUid = data['assigned_handyman'];
    String? imageUrl = data['imageURL'];

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
              'Approved Request',
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
                  if (mounted) {
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
                  }
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
                    padding: const EdgeInsets.all(20.0),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromRGBO(255, 255, 255, 0.95),
                          Color.fromRGBO(245, 245, 245, 0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
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
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 700),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Category: ${data['category'] ?? 'No category'}',
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color.fromRGBO(33, 33, 33, 0.9),
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: data['status'] == 'approved'
                                      ? Color.fromRGBO(33, 150, 243, 0.2)
                                      : Color.fromRGBO(255, 61, 0, 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: data['status'] == 'approved'
                                        ? Color.fromRGBO(33, 150, 243, 0.5)
                                        : Color.fromRGBO(255, 61, 0, 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  (data['status'] ?? 'Unknown')
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: data['status'] == 'approved'
                                        ? Color.fromRGBO(33, 150, 243, 1)
                                        : Color.fromRGBO(255, 61, 0, 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            'Request: ${data['request'] ?? 'No details provided'}',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(33, 33, 33, 0.8),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          thickness: 1,
                        ),
                        const SizedBox(height: 12),
                        FadeInUp(
                          duration: const Duration(milliseconds: 900),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Assigned to: ${data['assigned_hanyman_name'] ?? 'None'}',
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(33, 33, 33, 0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              FutureBuilder<String?>(
                                future: getHandymanEmail(handymanUid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color:
                                            Color.fromRGBO(33, 150, 243, 0.7),
                                        strokeWidth: 2,
                                      ),
                                    );
                                  }
                                  if (snapshot.hasError ||
                                      !snapshot.hasData ||
                                      snapshot.data == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return ZoomIn(
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChatPage(email: snapshot.data!),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color.fromRGBO(
                                                  214, 214, 214, 0.898),
                                              Color.fromRGBO(
                                                  240, 238, 237, 0.698),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                  153, 149, 147, 0.976),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                              2), // Padding for gradient border effect
                                          child: ClipOval(
                                            child: Image.network(
                                              data['handyman_image'] ?? '',
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 0.1),
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Color.fromRGBO(
                                                          33, 150, 243, 0.7),
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 0.1),
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 20,
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 0.7),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Created: ${formatDate(data['timestamp'])}',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(33, 33, 33, 0.7),
                                ),
                              ),
                              Icon(
                                Icons.access_time,
                                size: 18,
                                color: Color.fromRGBO(33, 33, 33, 0.5),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        FadeInUp(
                          duration: const Duration(milliseconds: 900),
                          child: FutureBuilder<String?>(
                            future: getHandymanEmail(handymanUid),
                            builder: (context, snapshot) {
                              bool isClickable =
                                  snapshot.hasData && snapshot.data != null;
                              return GestureDetector(
                                onTap: isClickable
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChatPage(email: snapshot.data!),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isClickable
                                            ? [
                                                Color.fromRGBO(
                                                    33, 150, 243, 0.25),
                                                Color.fromRGBO(
                                                    33, 150, 243, 0.15),
                                              ]
                                            : [
                                                Color.fromRGBO(
                                                    255, 255, 255, 0.1),
                                                Color.fromRGBO(
                                                    255, 255, 255, 0.05),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.2),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.15),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Row(
                                            children: [
                                              ZoomIn(
                                                duration: const Duration(
                                                    milliseconds: 1000),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: isClickable
                                                        ? Color.fromRGBO(
                                                            255, 61, 0, 0.9)
                                                        : Color.fromRGBO(
                                                            100, 100, 100, 0.5),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: isClickable
                                                            ? Color.fromRGBO(
                                                                255, 61, 0, 0.3)
                                                            : Color.fromRGBO(
                                                                0, 0, 0, 0.2),
                                                        blurRadius: 6,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.chat_rounded,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Flexible(
                                                child: Text(
                                                  isClickable
                                                      ? 'Chat with ${data['assigned_hanyman_name'] ?? 'Handyman'}'
                                                      : 'No handyman assigned',
                                                  style: TextStyle(
                                                    fontFamily: 'Nunito',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: isClickable
                                                        ? Color.fromRGBO(
                                                            255, 255, 255, 0.95)
                                                        : Color.fromRGBO(
                                                            255, 255, 255, 0.5),
                                                    letterSpacing: 0.5,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting)
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Color.fromRGBO(
                                                  33, 150, 243, 0.7),
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        if (isClickable)
                                          TweenAnimationBuilder(
                                            tween: Tween<double>(
                                                begin: 0.8, end: 1.0),
                                            duration: const Duration(
                                                milliseconds: 1200),
                                            curve: Curves.easeInOut,
                                            builder: (context, value, child) {
                                              return Transform.scale(
                                                scale: value,
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 16,
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 0.7),
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (imageUrl != null && imageUrl.isNotEmpty)
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ImageViewerScreen(imageUrl: imageUrl),
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
                            imageUrl,
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
                    ),
                  ),
                if (imageUrl != null && imageUrl.isNotEmpty)
                  const SizedBox(height: 30),
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: ElevatedButton(
                    onPressed: _isMarkingFinished
                        ? null
                        : () async {
                            await Future.delayed(
                                const Duration(milliseconds: 300));
                            _markRequestAsFinished(widget.request.id, context);
                            int count = 1;
                            Navigator.popUntil(context, (route) {
                              return count++ == 2;
                            });
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
                    child: _isMarkingFinished
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Mark as Finished',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
                if (handymanUid != null && handymanUid.isNotEmpty)
                  FadeInUp(
                    duration: const Duration(milliseconds: 1300),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchHandymanComments(handymanUid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color.fromRGBO(33, 150, 243, 0.7),
                              strokeWidth: 2,
                            ),
                          );
                        }
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final comments = snapshot.data!;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...comments.map<Widget>((comment) {
                              comment.forEach(
                                (key, value) {
                                  print('$key , $value');
                                },
                              );
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
                                        comment['client_name']?.isNotEmpty ==
                                                true
                                            ? comment['client_name'][0]
                                                .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      comment['client_name'] ?? 'Anonymous',
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color.fromRGBO(33, 33, 33, 0.9),
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${comment['comment'] ?? 'No comment provided.'}',
                                          style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 16,
                                            color:
                                                Color.fromRGBO(33, 33, 33, 0.7),
                                          ),
                                        ),
                                        Text(
                                          'Rating: ${comment['rate']}/5',
                                          style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 14,
                                            color:
                                                Color.fromRGBO(33, 33, 33, 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      formatDate(comment['time']),
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 12,
                                        color: Color.fromRGBO(33, 33, 33, 0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
