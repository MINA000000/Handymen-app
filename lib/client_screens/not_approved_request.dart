import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/client_screens/handyman_details_screen2.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/client_screens/handymen_profiles.dart';
import 'package:grad_project/components/image_viewer_screen.dart';
import '../components/collections.dart';
import 'handyman_details_screen1.dart';

class NotApprovedRequest extends StatefulWidget {
  final QueryDocumentSnapshot request;

  const NotApprovedRequest({required this.request, super.key});

  @override
  State<NotApprovedRequest> createState() => _NotApprovedRequestState();
}

class _NotApprovedRequestState extends State<NotApprovedRequest> {
  bool _isDeleting = false;

  Future<void> _deleteRequest(BuildContext context) async {
    if (!mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 300));
      await FirebaseFirestore.instance
          .collection(CollectionsNames.requestInformation)
          .doc(widget.request.id)
          .delete();
    } catch (e) {
      print('Error deleting request: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _fetchHandymanInfo(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(uid)
          .get();
      if (!doc.exists) return {};

      final data = doc.data() ?? {};
      return {
        'full_name': data['full_name'] ?? 'Unknown',
        'category': data['category'] ?? 'No Category',
        'profile_picture': data['profile_picture'] ?? '',
        'rating_average': data['rating_average']?.toString() ?? 'N/A',
        'rating_count': data['rating_count']?.toString() ?? '0',
      };
    } catch (e) {
      print('Error fetching handyman info for UID $uid: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.request.data() as Map<String, dynamic>;
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final formattedDate = timestamp != null
        ? DateFormat('dd MMMM yyyy, HH:mm').format(timestamp)
        : 'No date provided';
    final clientWantingHandymen =
        (data['client_wanting_handymen'] as List?) ?? [];
    final handymenWantingRequest =
        (data['handymen_wanting_request'] as List?) ?? [];

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
              'Request Details',
              style: TextStyle(
                color: Colors.white,
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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Request Image
                if (data['imageURL'] != null && data['imageURL'].isNotEmpty)
                  ZoomIn(
                    duration: const Duration(milliseconds: 800),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewerScreen(
                              imageUrl: data['imageURL'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            data['imageURL'],
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 220,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                    color: Colors.white70,
                                    strokeWidth: 4,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 220,
                              color: Colors.white12,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Request Card
                Card(
                  elevation: 6,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF56AB94),
                          Color(0xFF2E3B4E),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Text(
                            data['category'] ?? 'No Category',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Text(
                            data['request'] ?? 'No Request',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontFamily: 'Nunito',
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24, thickness: 1),
                          const SizedBox(height: 16),
                          Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Text(
                            'Not accepted yet',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Assigned Handyman',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Text(
                            data['assigned_handyman_name'] ?? 'Unassigned',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Created',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Client Wanting Handymen Section
                ExpansionTile(
                  title: Text(
                    'Your Requested Handymen',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  iconColor: Colors.white70,
                  collapsedIconColor: Colors.white70,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white12, width: 1),
                  ),
                  children: clientWantingHandymen.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No handymen selected by client.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                        ]
                      : clientWantingHandymen.map((uid) {
                          return FutureBuilder<Map<String, dynamic>>(
                            future: _fetchHandymanInfo(uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color:
                                          const Color.fromARGB(255, 12, 2, 2),
                                      strokeWidth: 4,
                                    ),
                                  ),
                                );
                              }
                              if (snapshot.hasError ||
                                  !snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Error loading handyman information.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          const Color.fromARGB(255, 12, 2, 2),
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                );
                              }
                              final handyman = snapshot.data!;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HandymanDetailsScreen2(
                                        handymanUid: uid,
                                        requestId: widget.request.id,
                                      ),
                                    ),
                                  );
                                },
                                child: TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 1.0, end: 1.0),
                                  duration: const Duration(milliseconds: 200),
                                  builder: (context, scale, child) {
                                    return Transform.scale(
                                      scale: scale,
                                      child: child,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    child: Card(
                                      elevation: 6,
                                      shadowColor:
                                          Colors.black.withValues(alpha: 0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF56AB94)
                                                  .withValues(alpha: 0.4),
                                              Color(0xFF2E3B4E)
                                                  .withValues(alpha: 0.4),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 12, 2, 2),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              // Profile Picture
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color.fromARGB(
                                                        255, 12, 2, 2),
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.2),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  child:
                                                      handyman['profile_picture']
                                                                  ?.isNotEmpty ??
                                                              false
                                                          ? Image.network(
                                                              handyman[
                                                                  'profile_picture'],
                                                              width: 50,
                                                              height: 50,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  const Icon(
                                                                Icons.person,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    12,
                                                                    2,
                                                                    2),
                                                                size: 50,
                                                              ),
                                                            )
                                                          : const Icon(
                                                              Icons.person,
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  12, 2, 2),
                                                              size: 50,
                                                            ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              // Handyman Info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      handyman['full_name'] ??
                                                          'Unknown',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 12, 2, 2),
                                                        fontFamily: 'Nunito',
                                                        letterSpacing: 0.3,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      handyman['category'] ??
                                                          'No Category',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 12, 2, 2),
                                                        fontFamily: 'Nunito',
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Rating: ${handyman['rating_average']}/5 (${handyman['rating_count']} reviews)',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 12, 2, 2),
                                                        fontFamily: 'Nunito',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Chevron Icon
                                              Icon(
                                                Icons.chevron_right,
                                                color: const Color.fromARGB(
                                                        255, 12, 2, 2)
                                                    .withValues(alpha: 0.7),
                                                size: 24,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                ),
                const SizedBox(height: 16),
                // Handymen Wanting Request Section
                ExpansionTile(
                  title: Text(
                    'Handymen Offering to Help',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  iconColor: Colors.white70,
                  collapsedIconColor: Colors.white70,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white12, width: 1),
                  ),
                  children: handymenWantingRequest.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No handymen have shown interest yet.',
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 12, 2, 2),
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                        ]
                      : handymenWantingRequest.map((uid) {
                          return FutureBuilder<Map<String, dynamic>>(
                            future: _fetchHandymanInfo(uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color:
                                          const Color.fromARGB(255, 12, 2, 2),
                                      strokeWidth: 4,
                                    ),
                                  ),
                                );
                              }
                              if (snapshot.hasError ||
                                  !snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Error loading handyman information.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          const Color.fromARGB(255, 12, 2, 2),
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                );
                              }
                              final handyman = snapshot.data!;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HandymanDetailsScreen1(
                                        handymanUid: uid,
                                        requestId: widget.request.id,
                                      ),
                                    ),
                                  );
                                },
                                child: TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 1.0, end: 1.0),
                                  duration: const Duration(milliseconds: 200),
                                  builder: (context, scale, child) {
                                    return Transform.scale(
                                      scale: scale,
                                      child: child,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    child: Card(
                                      elevation: 6,
                                      shadowColor:
                                          Colors.black.withValues(alpha: 0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF56AB94)
                                                  .withValues(alpha: 0.4),
                                              Color(0xFF2E3B4E)
                                                  .withValues(alpha: 0.4),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 12, 2, 2),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              // Profile Picture
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color.fromARGB(
                                                        255, 12, 2, 2),
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.2),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  child:
                                                      handyman['profile_picture']
                                                                  ?.isNotEmpty ??
                                                              false
                                                          ? Image.network(
                                                              handyman[
                                                                  'profile_picture'],
                                                              width: 50,
                                                              height: 50,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  const Icon(
                                                                Icons.person,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    12,
                                                                    2,
                                                                    2),
                                                                size: 50,
                                                              ),
                                                            )
                                                          : const Icon(
                                                              Icons.person,
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  12, 2, 2),
                                                              size: 50,
                                                            ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              // Handyman Info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      handyman['full_name'] ??
                                                          'Unknown',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 12, 2, 2),
                                                        fontFamily: 'Nunito',
                                                        letterSpacing: 0.3,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      handyman['category'] ??
                                                          'No Category',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 12, 2, 2),
                                                        fontFamily: 'Nunito',
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Rating: ${handyman['rating_average']}/5 (${handyman['rating_count']} reviews)',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 12, 2, 2),
                                                        fontFamily: 'Nunito',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Chevron Icon
                                              Icon(
                                                Icons.chevron_right,
                                                color: const Color.fromARGB(
                                                        255, 12, 2, 2)
                                                    .withValues(alpha: 0.7),
                                                size: 24,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                ),
                const SizedBox(height: 24),
                // Buttons
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HandymenProfiles(
                                  categoryName: data['category'] ?? '',
                                  docId: widget.request.id,
                                  request: data['request'] ?? '',
                                ),
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
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person_add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Send to Handyman',
                                  style: const TextStyle(
                                    color: Colors.white,
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
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _isDeleting
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor:
                                          Colors.white.withOpacity(0.95),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      title: const Text(
                                        'Delete Request',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete this request? This action cannot be undone.',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
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
                                              color: Color.fromRGBO(
                                                  255, 61, 0, 0.9),
                                            ),
                                          ),
                                        ),
                                      ],
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
                                  Color.fromRGBO(255, 61, 0, 0.9),
                                  Color.fromRGBO(200, 50, 0, 0.9),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
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
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Delete Request',
                                        style: const TextStyle(
                                          color: Colors.white,
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
