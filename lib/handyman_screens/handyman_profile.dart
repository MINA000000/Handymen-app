import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/components/collections.dart';
import 'package:grad_project/main.dart';

// import 'client_edit_information.dart';

class HandymanProfile extends StatefulWidget {
  @override
  State<HandymanProfile> createState() => _HandymanProfileState();
}

class _HandymanProfileState extends State<HandymanProfile> {
  // Map<String,dynamic> clientData = <String,dynamic>{};
  bool masterloading = false;
  // Future<void> getClientData()async{
  //   try{
  //     DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //         .collection(CollectionsNames.clientsInformation)
  //         .doc(FirebaseAuth.instance.currentUser!.uid)
  //         .get();
  //     clientData = documentSnapshot.data() as Map<String, dynamic>;
  //     setState(() {
  //       masterloading = false;
  //     });
  //   }
  //   catch(e)
  //   {
  //     print("Error when fetching data : $e");
  //   }
  //   // print(documentSnapshot.data());
  // }
  // @override
  // void initState() {
  //   super.initState();
  //   getClientData();
  // }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF56AB94), Color(0xFF53636C)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(onPressed: (){}, icon: Icon(Icons.notifications),color: Colors.white,)
          ],
        ),
        body: masterloading?Center(child: CircularProgressIndicator(color: Colors.grey,),):Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                              radius: 50,
                              backgroundImage:
                              // NetworkImage("https://placehold.co/100x100"),
                              AssetImage('assets/avatar.png')
                          ),
                          const SizedBox(width: 10),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Text(
                          //       clientData[ClientFieldsName.fullName],
                          //       style: TextStyle(
                          //         color: Colors.white,
                          //         fontSize: 22,
                          //         fontWeight: FontWeight.w600,
                          //       ),
                          //     ),
                          //     SizedBox(height: 5),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Settings Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildButton(
                                context, Icons.person, 'Personal Information',
                                    () {
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ClientEditInformation(),));
                                }),
                            _buildButton(context, Icons.security,
                                'Password & Security', () {}),
                            _buildButton(context, Icons.notifications,
                                'Notifications', () {}),
                            _buildButton(
                                context, Icons.language, 'Language', () {}),
                            const Divider(color: Colors.white54),
                            _buildButton(
                                context, Icons.logout, 'Logout', ()async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ChooseScreen(),), (route)=>false);
                            }),
                            _buildButton(context, Icons.delete,
                                'Delete account', () {}),
                            _buildButton(context, Icons.bug_report,
                                'Report a bug', () {}),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 80), // Added space for bottom navbar
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String text,
      VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
