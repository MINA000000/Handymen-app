import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/components/image_viewer_screen.dart';
import '../components/firebase_methods.dart';
import '../components/collections.dart';

class HandymanDetailsPage extends StatefulWidget {
  final Map<String,dynamic> handyman;
  final String handymanUId;
  String docid;
  HandymanDetailsPage({required this.handyman,required this.docid,required this.handymanUId});

  @override
  State<HandymanDetailsPage> createState() => _HandymanDetailsPageState();
}

class _HandymanDetailsPageState extends State<HandymanDetailsPage> {
  List<QueryDocumentSnapshot> workPictures = [];
  List<QueryDocumentSnapshot> comments = [];
  bool masterLoading = true;
  bool buttonLoading = false;
  bool sendCorrectly = false;
  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> fetchWorkPictures() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(widget.handymanUId)
          .collection(CollectionsNames.workPictures)
          .get();
      workPictures = querySnapshot.docs;
    } catch (e) {
      print("Error fetching data: $e");
    }
    setState(() {
      masterLoading = false;
    });
  }

  Future<void> fetchComments() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(widget.handymanUId)
          .collection(CollectionsNames.comments)
          .get();
      comments = querySnapshot.docs;
    } catch (e) {
      print("Error fetching data: $e");
    }
    setState(() {
      masterLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchWorkPictures();
    fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: masterLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : Container(
            height: double.infinity,
            decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.71, -0.71),
            end: Alignment(-0.71, 0.71),
            colors: [Color(0xFF56AB94), Color(0xFF53636C)],
          ),
                  ),
                  child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                      Text(
                        'Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      Icon(Icons.settings, color: Colors.white, size: 28),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ImageViewerScreen(imageUrl: widget.handyman[HandymanFieldsName.profilePicture]),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(widget.handyman[HandymanFieldsName.profilePicture]),
                    backgroundColor: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.handyman[HandymanFieldsName.fullName],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  widget.handyman[HandymanFieldsName.category],
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  child: Card(
                    margin: EdgeInsets.all(10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About Me',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text(widget.handyman[HandymanFieldsName.description]),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text('Photos', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                SizedBox(height: 10),
                workPictures.isEmpty?Text('There is no photos'):SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: workPictures.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImageViewerScreen(imageUrl: workPictures[index]['image_url']),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(workPictures[index]['image_url']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Text('Comments', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                _buildCommentsSection(),
                SizedBox(height: 10),
                ElevatedButton(
                  //TODO
                  onPressed:buttonLoading||sendCorrectly?null: () async{
                    setState(() {
                      buttonLoading = true;
                    });
                    try{
                      await FirebaseMethods.addToArrayRequestsCollection(widget.docid,widget.handymanUId,RequestFieldsName.clientWantingHandymen);
                      sendCorrectly = true;
                    }
                    catch(e)
                    {
                      print(e);
                    }
                    finally{
                      setState(() {
                        buttonLoading = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3D00),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: buttonLoading?CircularProgressIndicator(color: Colors.grey,): Text(
                    sendCorrectly?'Done':'Make my request',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: sendCorrectly?Colors.green:Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
                  ),
                ),
    );
  }
  Widget _buildCommentsSection() {
    return comments.isEmpty? Text('There is no comments'):SizedBox(
      height: 200, // Increase height
      child: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) {
          var comment = comments[index];
          return Card(
            margin: EdgeInsets.only(left: 10,top: 10,right: 10),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(comment[CommentsFieldsName.clientName][0].toUpperCase()),
              ),
              title: Text(comment[CommentsFieldsName.clientName]),
              subtitle: Text(comment[CommentsFieldsName.comment]),
              trailing: Text(
                comment[CommentsFieldsName.time] != null
                    ? formatDate(comment[CommentsFieldsName.time])
                    : "Just now",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    ); // Placeholder for comments section
  }
}
