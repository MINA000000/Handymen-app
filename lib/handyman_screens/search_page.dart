import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/components/collections.dart';
import 'package:grad_project/handyman_screens/request_info.dart';
import 'package:intl/intl.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isLoading = true;
  String? errorMessage;
  DocumentSnapshot? handymanInformation;
  List<QueryDocumentSnapshot> requests = [];
  List<QueryDocumentSnapshot> filteredRequests = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchHandymanInformationAndRequests() async {
    try {
      // Fetch handyman information
      final documentSnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (!documentSnapshot.exists) {
        throw Exception('Handyman information not found');
      }

      // Fetch requests matching handyman's category and status "notApproved"
      final category = documentSnapshot[HandymanFieldsName.category] ?? '';
      final querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.requestInformation)
          .where(RequestFieldsName.category, isEqualTo: category)
          .where(RequestFieldsName.status, isEqualTo: 'notApproved')
          .get();

      setState(() {
        handymanInformation = documentSnapshot;
        requests = querySnapshot.docs;
        filteredRequests = List.from(requests);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data. Please try again.';
      });
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
  }

  void _filterRequests(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRequests = List.from(requests);
      } else {
        filteredRequests = requests.where((request) {
          final requestText =
              request[RequestFieldsName.request]?.toString().toLowerCase() ??
                  '';
          return requestText.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    fetchHandymanInformationAndRequests();
    _searchController.addListener(() {
      _filterRequests(_searchController.text);
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
              'Handymen Offering to Help',
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
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(255, 255, 255, 0.7),
                  strokeWidth: 2,
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
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search requests...',
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(33, 33, 33, 0.5),
                              fontFamily: 'Nunito',
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color.fromRGBO(255, 61, 0, 0.7),
                              size: 24,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Color.fromRGBO(255, 61, 0, 0.7),
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterRequests('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(33, 33, 33, 0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: errorMessage != null
                        ? Center(
                            child: FadeInUp(
                              duration: const Duration(milliseconds: 600),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
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
                        : filteredRequests.isEmpty
                            ? Center(
                                child: FadeInUp(
                                  duration: const Duration(milliseconds: 600),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
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
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.2),
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
                                      'No requests found for "${_searchController.text}".',
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
                                itemCount: filteredRequests.length,
                                itemBuilder: (context, index) {
                                  final request = filteredRequests[index];
                                  return FadeInUp(
                                    duration: Duration(
                                        milliseconds: 700 + (index * 100)),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RequestInfo(request: request),
                                            ));
                                        // ScaffoldMessenger.of(context).showSnackBar(
                                        //   SnackBar(
                                        //     content: Text(
                                        //       'Request "${request[RequestFieldsName.request]}" clicked!',
                                        //       style: const TextStyle(
                                        //         color: Colors.white,
                                        //         fontFamily: 'Nunito',
                                        //         fontWeight: FontWeight.w600,
                                        //       ),
                                        //     ),
                                        //     backgroundColor: Color.fromRGBO(33, 150, 243, 0.7),
                                        //     behavior: SnackBarBehavior.floating,
                                        //     shape: RoundedRectangleBorder(
                                        //       borderRadius: BorderRadius.circular(12),
                                        //     ),
                                        //     duration: const Duration(seconds: 2),
                                        //   ),
                                        // );
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        color: Colors.transparent,
                                        elevation: 0,
                                        child: Container(
                                          width: screenWidth * 0.9,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color.fromRGBO(
                                                    255, 255, 255, 0.95),
                                                Color.fromRGBO(
                                                    245, 245, 245, 0.95),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.2),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.15),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Color.fromRGBO(
                                                          255, 255, 255, 0.3),
                                                      Color.fromRGBO(
                                                          255, 255, 255, 0.1),
                                                    ],
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 0.2),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                padding:
                                                    const EdgeInsets.all(2),
                                                child: CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor:
                                                      Color.fromRGBO(
                                                          255, 255, 255, 0.1),
                                                  child: Icon(
                                                    Icons.handyman,
                                                    color: Color.fromRGBO(
                                                        255, 61, 0, 0.9),
                                                    size: 30,
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
                                                      request[RequestFieldsName
                                                              .request] ??
                                                          'No request details',
                                                      style: const TextStyle(
                                                        fontFamily: 'Nunito',
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 18,
                                                        color: Color.fromRGBO(
                                                            33, 33, 33, 0.9),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      request[RequestFieldsName
                                                              .category] ??
                                                          'No category',
                                                      style: const TextStyle(
                                                        fontFamily: 'Nunito',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color.fromRGBO(
                                                            33, 33, 33, 0.7),
                                                      ),
                                                    ),
                                                    Text(
                                                      _formatTimestamp(request[
                                                          RequestFieldsName
                                                              .timestamp]),
                                                      style: const TextStyle(
                                                        fontFamily: 'Nunito',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color.fromRGBO(
                                                            33, 33, 33, 0.7),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Color.fromRGBO(
                                                    255, 61, 0, 0.9),
                                                size: 24,
                                              ),
                                            ],
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
