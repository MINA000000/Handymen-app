import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/api_services/api_service_recommendation.dart';
import 'package:grad_project/client_screens/handyman_details.dart';
import 'package:grad_project/components/firebase_methods.dart';
import 'package:grad_project/components/collections.dart';

class HanymenProfiles extends StatefulWidget {
  String categoryName;
  String docId;
  String request;
  HanymenProfiles(
      {required this.categoryName, required this.docId, required this.request});

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

  //     for (var handymanId in recommendedHandymen) {
  //       if (handymanId['id'] is! String) continue; // Skip if ID is not a string

  //       DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //           .collection(CollectionsNames.handymenInformation)
  //           .doc(handymanId['id'])
  //           .get();

  //       if (documentSnapshot.exists) {
  //         handymen.add(documentSnapshot.data() as Map<String, dynamic>);
  //         handymenUID.add(handymanId['id']);
  //       }
  //     }

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
      // Query Firestore for handymen with the given category
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .where(HandymanFieldsName.category, isEqualTo: categoryName)
          .get();

      // Clear existing lists before populating
      handymen.clear();
      handymenUID.clear();

      for (var doc in querySnapshot.docs) {
        handymen.add(doc.data() as Map<String, dynamic>);
        handymenUID.add(doc.id); // The document ID is typically the UID
      }

      setState(() {
        masterLoading = false;
      });
    } catch (e) {
      print("Error fetching handymen by category: $e");
      setState(() {
        masterLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState(); // ✅ Always call super.initState() first
    fetchHandymenData(widget.categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No default AppBar – we use our custom top bar in the body.
      body: masterLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.71, -0.71),
                  end: Alignment(-0.71, 0.71),
                  colors: [Color(0xFF56AB94), Color(0xFF53636C)],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 80), // Top spacing
                  // Custom Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Text(
                          'Handymen',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const Icon(Icons.settings, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // List of Handymen
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: handymen.length,
                      itemBuilder: (context, index) {
                        final handyman = handymen[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HandymanDetailsPage(
                                    handyman: handyman,
                                    docid: widget.docId,
                                    handymanUId: handymenUID[index],
                                  ),
                                ));
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(handyman[
                                    HandymanFieldsName.profilePicture]),
                              ),
                              title: Text(
                                handyman[HandymanFieldsName.fullName],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(handyman[HandymanFieldsName.category]),
                                  Text(
                                      'He did ${handyman[HandymanFieldsName.projectsCount]} projects'),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i <
                                                handyman[HandymanFieldsName
                                                        .ratingAverage]
                                                    .floor()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
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
