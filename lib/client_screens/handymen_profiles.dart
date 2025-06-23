import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/api_services/api_service_recommendation.dart';
import 'package:grad_project/client_screens/handyman_details.dart';
import 'package:grad_project/components/firebase_methods.dart';
import 'package:grad_project/components/collections.dart';

class HanymenProfiles extends StatefulWidget {
  final String categoryName;
  final String docId;
  final String request;

  const HanymenProfiles({
    required this.categoryName,
    required this.docId,
    required this.request,
    super.key,
  });

  @override
  State<HanymenProfiles> createState() => _HanymenProfilesState();
}

class _HanymenProfilesState extends State<HanymenProfiles> {
  bool masterLoading = true;
  List<Map<String, dynamic>> handymen = [];
  List<String> handymenUID = [];
  // ApiServiceRecommendation _apiService = ApiServiceRecommendation();
  List<dynamic> recommendedHandymen = [];
  String errorMessage = '';

  // Future<void> fetchRecommendations(String request, String category) async {
  //   try {
  //     final data = await _apiService.fetchRecommendations(request, category);
  //     print(data); // Debugging: Print entire response
  //
  //     setState(() {
  //       if (data['recommended_handymen'] is List) {
  //         recommendedHandymen = data['recommended_handymen'];
  //       } else {
  //         recommendedHandymen = []; // Fallback if the data isn't a list
  //       }
  //       errorMessage = '';
  //     });
  //   } catch (e) {
  //     print("Error here: $e");
  //   }
  // }

  // Future<void> fetchHandymenData() async {
  //   try {
  //     await fetchRecommendations(widget.request, widget.categoryName);
  //
  //     for (var handymanId in recommendedHandymen) {
  //       if (handymanId['id'] is! String) continue; // Skip if ID is not a string
  //
  //       DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //           .collection(CollectionsNames.handymenInformation)
  //           .doc(handymanId['id'])
  //           .get();
  //
  //       if (documentSnapshot.exists) {
  //         handymen.add(documentSnapshot.data() as Map<String, dynamic>);
  //         handymenUID.add(handymanId['id']);
  //       }
  //     }
  //
  //     setState(() {
  //       masterLoading = false;
  //     });
  //   } catch (e) {
  //     print("Error fetching data: $e");
  //     setState(() {
  //       masterLoading = false;
  //     });
  //   }
  // }

  Future<void> fetchHandymenData(String categoryName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .where(HandymanFieldsName.category, isEqualTo: categoryName)
          .get();

      handymen.clear();
      handymenUID.clear();

      for (var doc in querySnapshot.docs) {
        handymen.add(doc.data() as Map<String, dynamic>);
        handymenUID.add(doc.id);
      }

      setState(() {
        masterLoading = false;
      });
    } catch (e) {
      print("Error fetching handymen by category: $e");
      setState(() {
        masterLoading = false;
        errorMessage = 'Failed to load handymen. Please try again.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHandymenData(widget.categoryName);
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
              'Handymen',
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
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
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
            : errorMessage.isNotEmpty
                ? Center(
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.1),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          errorMessage,
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
                : Column(
                    children: [
                      const SizedBox(height: 40),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: handymen.length,
                          itemBuilder: (context, index) {
                            final handyman = handymen[index];
                            return FadeInUp(
                              duration: Duration(milliseconds: 600 + (index * 100)),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HandymanDetailsPage(
                                        handyman: handyman,
                                        docid: widget.docId,
                                        handymanUId: handymenUID[index],
                                      ),
                                    ),
                                  );
                                },
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
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      leading: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Color.fromRGBO(255, 255, 255, 0.1),
                                        backgroundImage: handyman[HandymanFieldsName.profilePicture] != null &&
                                                handyman[HandymanFieldsName.profilePicture].isNotEmpty
                                            ? NetworkImage(handyman[HandymanFieldsName.profilePicture])
                                            : null,
                                        child: handyman[HandymanFieldsName.profilePicture] == null ||
                                                handyman[HandymanFieldsName.profilePicture].isEmpty
                                            ? const Icon(
                                                Icons.person,
                                                color: Colors.white70,
                                                size: 30,
                                              )
                                            : null,
                                      ),
                                      title: Text(
                                        handyman[HandymanFieldsName.fullName] ?? 'Unknown',
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
                                            handyman[HandymanFieldsName.category] ?? 'No category',
                                            style: const TextStyle(
                                              fontFamily: 'Nunito',
                                              fontSize: 16,
                                              color: Color.fromRGBO(33, 33, 33, 0.7),
                                            ),
                                          ),
                                          Text(
                                            'Completed ${handyman[HandymanFieldsName.projectsCount] ?? 0} projects',
                                            style: const TextStyle(
                                              fontFamily: 'Nunito',
                                              fontSize: 16,
                                              color: Color.fromRGBO(33, 33, 33, 0.7),
                                            ),
                                          ),
                                          Row(
                                            children: List.generate(
                                              5,
                                              (i) => Icon(
                                                i <
                                                        (handyman[HandymanFieldsName.ratingAverage] ?? 0)
                                                            .floor()
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Color.fromRGBO(255, 61, 0, 0.9),
                                                size: 16,
                                              ),
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
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}