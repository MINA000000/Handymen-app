import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/chat_page.dart';
import 'package:grad_project/components/collections.dart';

class ApprovedRequestClient extends StatefulWidget {
  QueryDocumentSnapshot request;

  ApprovedRequestClient({required this.request});

  @override
  State<ApprovedRequestClient> createState() => _ApprovedRequestClientState();
}

class _ApprovedRequestClientState extends State<ApprovedRequestClient> {
  Future<void> iwant(requestId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference docRef = firestore
        .collection(CollectionsNames.requestInformation)
        .doc(requestId);
    await docRef.update({'status': 'done'});

    DocumentSnapshot snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;
    DocumentReference handymanRef = firestore
        .collection(CollectionsNames.handymenInformation)
        .doc(data['assigned_handyman']);
    await handymanRef.update({'projects_count': FieldValue.increment(1)});
  }

  Future<String?> getHandymanEmail(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('handymen_information')
          .doc(uid)
          .get();
      return userDoc.exists ? userDoc.get('email') as String? : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.request.data() as Map<String, dynamic>;
    String? handymanUid = data['assigned_handyman'];
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
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await iwant(widget.request.id);
                    } catch (error) {
                      print("There is error here $error");
                    } finally {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("This request Finished?"),
                ),
                FutureBuilder<String?>(
                  future: getHandymanEmail(handymanUid ?? ''),
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
                        print("handyman uid is : ${snapshot.data}");
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
