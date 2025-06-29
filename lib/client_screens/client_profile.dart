import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/components/collections.dart';
import 'package:grad_project/main.dart';
import 'client_edit_information.dart';

class ClientProfile extends StatefulWidget {
  const ClientProfile({super.key});

  @override
  State<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> {
  Map<String, dynamic> clientData = <String, dynamic>{};
  bool masterloading = true;

  Future<void> getClientData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(CollectionsNames.clientsInformation)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    clientData = documentSnapshot.data() as Map<String, dynamic>;
    setState(() {
      masterloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getClientData();
  }

  @override
  Widget build(BuildContext context) {
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
              'Profile',
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
          // leading: Padding(
          //   padding: const EdgeInsets.only(left: 8.0),
          //   child: IconButton(
          //     onPressed: () => Navigator.pop(context),
          //     icon: Container(
          //       padding: const EdgeInsets.all(8),
          //       decoration: BoxDecoration(
          //         color: Color.fromRGBO(255, 255, 255, 0.1),
          //         shape: BoxShape.circle,
          //         boxShadow: [
          //           BoxShadow(
          //             color: Color.fromRGBO(0, 0, 0, 0.15),
          //             blurRadius: 6,
          //             offset: const Offset(0, 2),
          //           ),
          //         ],
          //       ),
          //       child: const Icon(
          //         Icons.arrow_back,
          //         color: Colors.white,
          //         size: 24,
          //       ),
          //     ),
          //     tooltip: 'Back',
          //   ),
          // ),
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
                      backgroundColor: Color.fromRGBO(243, 159, 33, 0.698),
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
        body: masterloading
            ? Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(255, 255, 255, 0.7),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage: const AssetImage(
                                          'assets/person.avif'),
                                      backgroundColor:
                                          Color.fromRGBO(255, 255, 255, 0.95),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        clientData[ClientFieldsName.fullName] ??
                                            'User',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Nunito',
                                          letterSpacing: 0.5,
                                          shadows: [
                                            Shadow(
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.2),
                                              blurRadius: 4,
                                              offset: const Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildButton(
                                      context,
                                      Icons.person,
                                      'Personal Information',
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ClientEditInformation(),
                                          ),
                                        );
                                      },
                                      0,
                                    ),
                                    _buildButton(
                                      context,
                                      Icons.security,
                                      'Password & Security',
                                      () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Feature coming soon!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Nunito',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor: Color.fromRGBO(
                                                33, 150, 243, 0.7),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      1,
                                    ),
                                    _buildButton(
                                      context,
                                      Icons.notifications,
                                      'Notifications',
                                      () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Feature coming soon!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Nunito',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor: Color.fromRGBO(
                                                33, 150, 243, 0.7),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      2,
                                    ),
                                    _buildButton(
                                      context,
                                      Icons.language,
                                      'Language',
                                      () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Feature coming soon!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Nunito',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor: Color.fromRGBO(
                                                33, 150, 243, 0.7),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      3,
                                    ),
                                    const Divider(
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.5)),
                                    _buildButton(
                                      context,
                                      Icons.logout,
                                      'Logout',
                                      () async {
                                        await FirebaseAuth.instance.signOut();
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChooseScreen()),
                                          (route) => false,
                                        );
                                      },
                                      4,
                                    ),
                                    _buildButton(
                                      context,
                                      Icons.delete,
                                      'Delete Account',
                                      () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Feature coming soon!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Nunito',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor: Color.fromRGBO(
                                                33, 150, 243, 0.7),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      5,
                                    ),
                                    _buildButton(
                                      context,
                                      Icons.bug_report,
                                      'Report a Bug',
                                      () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Feature coming soon!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Nunito',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor: Color.fromRGBO(
                                                33, 150, 243, 0.7),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      6,
                                    ),
                                  ],
                                ),
                              ),
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
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String text,
      VoidCallback onPressed, int index) {
    return FadeInUp(
      duration: Duration(milliseconds: 1000 + (index * 100)),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(255, 255, 255, 0.05),
            shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: Color.fromRGBO(255, 255, 255, 0.9), size: 24),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.9),
                  fontSize: 18,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
