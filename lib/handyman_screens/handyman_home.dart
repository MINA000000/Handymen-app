import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/collections.dart';
import 'request_info.dart';

class HandymanHome extends StatefulWidget {
  @override
  _HandymanHomeState createState() => _HandymanHomeState();
}

class _HandymanHomeState extends State<HandymanHome> {
  DocumentSnapshot? handymanInformation;
  bool isLoading = true;

  Future<void> fetchHandymanInformation() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      setState(() {
        handymanInformation = documentSnapshot;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching handyman information: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHandymanInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.71, -0.71),
          end: Alignment(-0.71, 0.71),
          colors: [Color(0xFF56AB94), Color(0xFF53636C)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Requests',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications),
              color: Colors.white,
            )
          ],
        ),
        body: isLoading || handymanInformation == null
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(CollectionsNames.requestInformation)
                    .where('category',
                        isEqualTo: handymanInformation!.get('category'))
                    .where('status', isEqualTo: 'notApproved')
                    .snapshots(), // 🔥 Real-time updates here
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text("No requests available",
                            style: TextStyle(color: Colors.white)));
                  }

                  var requests = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RequestInfo(request: request)),
                            );
                          },
                          child: ListTile(
                            title: Text(
                              request['category'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(request['request']),
                            trailing: const Icon(Icons.arrow_forward_outlined),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
