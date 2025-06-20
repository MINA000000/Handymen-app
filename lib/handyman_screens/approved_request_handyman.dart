import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/chat_page.dart';
import 'package:grad_project/components/collections.dart';

class ApprovedRequestHandyman extends StatefulWidget {
  QueryDocumentSnapshot request;

  ApprovedRequestHandyman({required this.request});

  @override
  State<ApprovedRequestHandyman> createState() => _ApprovedRequestHandymanState();
}

class _ApprovedRequestHandymanState extends State<ApprovedRequestHandyman> {
  Future<void> iwant(requestId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference docRef = firestore
        .collection(CollectionsNames.requestInformation)
        .doc(requestId);
    await docRef.update({'status': 'done'});
  }

  Future<String?> getClientEmail(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('client_information').doc(uid).get();
      return userDoc.exists ? userDoc.get('email') as String? : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.request.data() as Map<String, dynamic>;
    String? clientUid = data['uid'];
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              'Approved Requests',
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
          backgroundColor: Colors.transparent,
          body: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<String?>(
                  future: getClientEmail(clientUid ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      );
                    }
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data == null) {
                      print(snapshot.data);
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: () {
                        print("client uid is : ${snapshot.data}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatPage(email: snapshot.data!),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.blueAccent.withOpacity(0.15),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12, width: 1),
                          ),
                          child: const Icon(
                            Icons.chat_rounded,
                            size: 60,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          )),
    );
  }
}
