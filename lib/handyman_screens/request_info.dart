import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/Providers/requests_provider_handyman.dart';
import 'package:grad_project/components/collections.dart';
import 'package:grad_project/components/firebase_methods.dart';
import 'package:grad_project/components/image_viewer_screen.dart';
import 'package:provider/provider.dart';

// @immutable
class RequestInfo extends StatefulWidget {
  QueryDocumentSnapshot request;

  RequestInfo({required this.request});

  @override
  State<RequestInfo> createState() => _RequestInfoState();
}

class _RequestInfoState extends State<RequestInfo> {
  bool buttonLoading = false;
  bool sendCorrectly = false;
  @override
  @override
  void initState() {
    super.initState();

    final requestsProvider = Provider.of<RequestsProviderHandyman>(
      context,
      listen: false,
    );

    // Delay to wait for Firestore snapshot to arrive
    Future.delayed(Duration.zero, () {
      // Print all document IDs in the HandymanWant list
      // print("request id is ${widget.request.id}");
      // for (var doc in requestsProvider.HandymanWant) {
      //   print("📄 HandymanWant doc.id: ${doc.id}");
      // }
      bool exists = false;
      var data = widget.request.data() as Map<String, dynamic>;

      if ((data[RequestFieldsName.handymenWantingRequest] as List)
          .contains(FirebaseAuth.instance.currentUser!.uid)) {
        exists = true;
      }

      setState(() {
        sendCorrectly = exists;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
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
        body: SizedBox(
          width: double.infinity,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Name
                      Text(
                        'Category : ${widget.request['category']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Requestt body :',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        '${widget.request['request']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 20),
                      // Photos Section Title
                      Text(
                        'Photos',
                        style: TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // Horizontal scrollable row for images
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewerScreen(
                                    imageUrl: widget.request['imageURL']),
                              ));
                        },
                        child: SizedBox(
                            height: 200,
                            child: Image.network(
                              widget.request['imageURL'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // If the image fails to load, return an empty Container
                                return Container();
                              },
                            )),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                          onPressed: buttonLoading || sendCorrectly
                              ? null
                              : () async {
                                  setState(() {
                                    buttonLoading = true;
                                  });
                                  try {
                                    await FirebaseMethods
                                        .addToArrayRequestsCollection(
                                            widget.request.id,
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            RequestFieldsName
                                                .handymenWantingRequest);
                                    //TODO
                                    sendCorrectly = true;
                                  } catch (e) {
                                    print(e);
                                  } finally {
                                    setState(() {
                                      buttonLoading = false;
                                    });
                                  }
                                },
                          child: buttonLoading
                              ? CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : Text(
                                  sendCorrectly ? 'Done' : 'Ask?',
                                  style: TextStyle(
                                      color: sendCorrectly
                                          ? Colors.green
                                          : Colors.orange[700],
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for image containers
  Widget _buildImageContainer() {
    return Container(
      width: 106.54,
      height: 95,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/plumber.jpeg"),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // Helper method for action buttons
  Widget _buildActionIcon(IconData icon, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
