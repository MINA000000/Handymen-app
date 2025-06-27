import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/api_services/api_service_recommendation.dart';
import 'package:grad_project/client_screens/handyman_details.dart';
import 'package:grad_project/components/firebase_methods.dart';
import 'package:grad_project/components/collections.dart';

class HandymenProfiles extends StatefulWidget {
  final String categoryName;
  final String docId;
  final String request;

  const HandymenProfiles({
    required this.categoryName,
    required this.docId,
    required this.request,
    super.key,
  });

  @override
  State<HandymenProfiles> createState() => _HanymenProfilesState();
}

class _HanymenProfilesState extends State<HandymenProfiles> {
  bool masterLoading = true;
  List<Map<String, dynamic>> handymen = [];
  List<Map<String, dynamic>> filteredHandymen = [];
  List<String> handymenUID = [];
  // ApiServiceRecommendation _apiService = ApiServiceRecommendation();
  List<dynamic> recommendedHandymen = [];
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

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
      filteredHandymen.clear();

      for (var doc in querySnapshot.docs) {
        handymen.add(doc.data() as Map<String, dynamic>);
        handymenUID.add(doc.id);
      }

      filteredHandymen = List.from(handymen);

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

  void _filterHandymen(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredHandymen = List.from(handymen);
      } else {
        filteredHandymen = handymen.where((handyman) {
          final name = handyman[HandymanFieldsName.fullName]?.toString().toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchHandymenData(widget.categoryName);
    _searchController.addListener(() {
      _filterHandymen(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            child: Text(
              'Your Requested Handymen', // Updated title
              style: const TextStyle(
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
        body: masterLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(255, 255, 255, 0.7),
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 16),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
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
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search handymen by name...',
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(33, 33, 33, 0.5),
                              fontFamily: 'Nunito',
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color.fromRGBO(33, 33, 33, 0.7),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Color.fromRGBO(33, 33, 33, 0.7),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterHandymen('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            color: Color.fromRGBO(33, 33, 33, 0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: errorMessage.isNotEmpty
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
                        : filteredHandymen.isEmpty
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
                                      'No handymen found for "${_searchController.text}".',
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
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredHandymen.length,
                                itemBuilder: (context, index) {
                                  final handyman = filteredHandymen[index];
                                  return FadeInUp(
                                    duration: Duration(milliseconds: 700 + (index * 100)),
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
                                        color: Colors.transparent,
                                        elevation: 0,
                                        child: Container(
                                          width: screenWidth * 0.9,
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
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            leading: Container(
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
                                              padding: const EdgeInsets.all(2),
                                              child: CircleAvatar(
                                                radius: 30,
                                                backgroundColor: Color.fromRGBO(255, 255, 255, 0.1),
                                                backgroundImage: handyman[HandymanFieldsName.profilePicture] !=
                                                        null &&
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
                                            ),
                                            title: Text(
                                              handyman[HandymanFieldsName.fullName] ?? 'Unknown',
                                              style: const TextStyle(
                                                fontFamily: 'Nunito',
                                                fontWeight: FontWeight.w800,
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
                                                    fontWeight: FontWeight.w600,
                                                    color: Color.fromRGBO(33, 33, 33, 0.7),
                                                  ),
                                                ),
                                                Text(
                                                  'Completed ${handyman[HandymanFieldsName.projectsCount] ?? 0} projects',
                                                  style: const TextStyle(
                                                    fontFamily: 'Nunito',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
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
                                                          : (handyman[HandymanFieldsName.ratingAverage] ?? 0) >=
                                                                  i + 0.5
                                                              ? Icons.star_half
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