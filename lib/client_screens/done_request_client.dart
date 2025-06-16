import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/api_services/api_service_sentiment_analysis.dart';
import 'package:grad_project/components/collections.dart';
import 'package:grad_project/components/dialog_utils.dart';
import 'package:grad_project/components/image_viewer_screen.dart';

class DoneRequestClient extends StatefulWidget {
  QueryDocumentSnapshot request;
  DoneRequestClient({required this.request});
  @override
  _DoneRequestClientState createState() => _DoneRequestClientState();
}

class _DoneRequestClientState extends State<DoneRequestClient> {
  bool showCommentBox = false;
  TextEditingController commentController = TextEditingController();
  int selectedRating = 0;
  DocumentSnapshot? handyman;
  DocumentSnapshot? client;
  bool isCommentExist = false;
  bool isloading = true;
  bool isButtonLoading = false;
  // ApiServiceSentimentAnalysis api = ApiServiceSentimentAnalysis();

  Future<void> _fetchHandymanClient() async {
    try {
      await _checkCommentExisting();
      handyman = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(widget.request[RequestFieldsName.assignedHandyman])
          .get();
      client = await FirebaseFirestore.instance
          .collection(CollectionsNames.clientsInformation)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      // print(handyman!.get(HandymanFieldsName.category));
      setState(() {
        isloading = false;
      });
    } catch (e) {
      print("Error here : $e");
      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> _checkCommentExisting() async {
    try {
      List<QueryDocumentSnapshot> queryDocumentSnapshot =
          (await FirebaseFirestore.instance
                  .collection(CollectionsNames.handymenInformation)
                  .doc(widget.request[RequestFieldsName.assignedHandyman])
                  .collection(CollectionsNames.comments)
                  .where(CommentsFieldsName.clientId,
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .where(CommentsFieldsName.requestId,isEqualTo: widget.request.id)
                  .get())
              .docs;

      if (queryDocumentSnapshot.isNotEmpty) isCommentExist = true;
      // print(queryDocumentSnapshot.isEmpty);
      // print(CommentsFieldsName.clientId+" "+"${FirebaseAuth.instance.currentUser!.uid}");
      // print('hello worold here');
    } catch (e) {
      print("Error here : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHandymanClient();
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
      child: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
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
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              width: 180,
                              height: 160,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(handyman!
                                      .get(HandymanFieldsName.profilePicture)),
                                  fit: BoxFit.fill,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              handyman!.get(HandymanFieldsName.fullName),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFF5F5F5),
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              handyman!.get(HandymanFieldsName.category),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFF5F5F5),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Request Done:',
                              style: TextStyle(
                                color: Color(0xFFF5F5F5),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Container(
                              width: 350,
                              height: 80,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                  widget.request[RequestFieldsName.request]),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Photos',
                              style: TextStyle(
                                color: Color(0xFFF5F5F5),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(
                              height: 80,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                children: List.generate(
                                  1,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ImageViewerScreen(
                                                    imageUrl: widget.request[
                                                        RequestFieldsName
                                                            .imageURL]),
                                          ));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      width: 106.54,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(widget.request[
                                              RequestFieldsName.imageURL]),
                                          fit: BoxFit.fill,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showCommentBox = !showCommentBox;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_circle_outline,
                                      size: 30, color: Colors.white),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Add comment',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (showCommentBox)
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: commentController,
                                      decoration: const InputDecoration(
                                        hintText: 'Write your comment here...',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        return IconButton(
                                          icon: Icon(
                                            index < selectedRating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              selectedRating = index + 1;
                                            });
                                          },
                                        );
                                      }),
                                    ),
                                    ElevatedButton(
                                        onPressed: isButtonLoading||isCommentExist
                                            ? null
                                            : () async {
                                          
                                                setState(() {
                                                  isButtonLoading = true;
                                                });

                                                if (commentController
                                                    .text.isEmpty) {
                                                  DialogUtils.buildShowDialog(
                                                      context,
                                                      title: 'Empty comment',
                                                      content:
                                                          'Please, write your comment first',
                                                      titleColor: Colors.red);
                                                  setState(() {
                                                    isButtonLoading = false;
                                                  });
                                                  return;
                                                }
                                                try {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(CollectionsNames
                                                          .handymenInformation)
                                                      .doc(widget.request[
                                                          RequestFieldsName
                                                              .assignedHandyman])
                                                      .collection(
                                                          CollectionsNames
                                                              .comments)
                                                      .add({
                                                    CommentsFieldsName
                                                            .clientName:
                                                        client!.get(
                                                            ClientFieldsName
                                                                .fullName),
                                                    CommentsFieldsName.comment:
                                                        commentController.text,
                                                    CommentsFieldsName.rate:
                                                        selectedRating,
                                                    CommentsFieldsName.time:
                                                        DateTime.now(),
                                                    CommentsFieldsName.clientId:
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                    CommentsFieldsName
                                                            .requestId:
                                                        widget.request.id
                                                  });
                                                  // await api.sendReview(commentController.text, widget.request[RequestFieldsName.assignedHandyman]);
                                                  //TODO
                                                  Navigator.of(context).pop();
                                                } catch (e) {
                                                  print('Error here : $e');
                                                } finally {
                                                  setState(() {
                                                    isButtonLoading = false;
                                                  });
                                                }
                                              },
                                        child: isButtonLoading
                                            ? CircularProgressIndicator()
                                            : Text(
                                                isCommentExist? 'Done':'Add',
                                                style: TextStyle(
                                                  color: isCommentExist?Colors.green:Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 80),
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
}
