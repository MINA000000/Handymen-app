import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grad_project/components/build_field.dart';
import 'package:grad_project/components/firebase_methods.dart';
import 'package:grad_project/components/wrapper.dart';
import 'package:grad_project/rest.dart';
import "package:lottie/lottie.dart";
import 'package:provider/provider.dart';
import 'components/location_methods.dart';
import 'confirm_password.dart';
import 'login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ClientSignUpGoogle extends StatefulWidget {
  @override
  State<ClientSignUpGoogle> createState() => _ClientSignUpGoogleState();
}

class _ClientSignUpGoogleState extends State<ClientSignUpGoogle> {
  TextEditingController _first_name = TextEditingController();
  TextEditingController _last_name = TextEditingController();
  TextEditingController _phone_number = TextEditingController();
  bool firstSingUp = true;
  bool isEqualPassword = true;
  BoolWrapper passvis1 = BoolWrapper(false);
  BoolWrapper passvis2 = BoolWrapper(false);
  bool isloading = false;
  bool isloading2 = false;
  Position? _position;
  void updateState() {
    setState(() {});
  }

  bool validateEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool validatePhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^\+?[0-9]{8,15}$');
    return regex.hasMatch(phoneNumber);
  }

  bool validatePassword(String password) {
    return password.length >=
        6; // Example: Password must be at least 6 characters
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.71, -0.71),
              end: Alignment(-0.71, 0.71),
              colors: [
                Color.fromARGB(255, 86, 171, 148),
                Color.fromARGB(255, 83, 99, 108)
              ],
            ),
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // White Box (Sign Up Form)
                Container(
                  width: 320,
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.08),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),

                      // Title
                      const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name Fields (First & Last Name)
                      Row(
                        children: [
                          Expanded(
                            child: BuildField.buildTextField(
                              'First name',
                              Icons.person,
                              TextInputType.text,
                              _first_name,
                              updateState,
                              firstSingUp,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: BuildField.buildTextField(
                              'Last name',
                              Icons.person,
                              TextInputType.text,
                              _last_name,
                              updateState,
                              firstSingUp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF3C00),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(Icons.location_on, color: Colors.white),
                          label: isloading2
                              ? CircularProgressIndicator(
                                  color: Colors.grey,
                                )
                              : Text(
                                  (_position == null) ? 'Get Location' : 'Done',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w800,
                                    color: (_position == null)
                                        ? Colors.white
                                        : Colors.green,
                                  ),
                                ),
                          onPressed: (isloading2 || _position != null)
                              ? null
                              : () async {
                                  setState(() {
                                    isloading2 = true;
                                  });
                                  _position =
                                      await LocationMethods.getUserLocation();
                                  setState(() {
                                    isloading2 = false;
                                  });
                                },
                        ),
                      ),
                      const SizedBox(height: 8),
                      BuildField.buildTextField(
                        'Phone number',
                        Icons.phone,
                        TextInputType.phone,
                        _phone_number,
                        updateState,
                        firstSingUp,
                      ),

                      const SizedBox(height: 10),

                      // Sign Up Button
                      SizedBox(
                        //TODO  loading cursor
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: isloading
                              ? null
                              : () async {
                                  setState(() {
                                    isloading = true;
                                  });
                                  // print(FirebaseAuth.instance.currentUser);
                                  // return;
                                  firstSingUp = false;

                                  // Validate fields
                                  if (_first_name.text.isEmpty ||
                                      _last_name.text.isEmpty) {
                                    print('Please enter your full name');
                                    await buildShowDialog(
                                      context,
                                      title: 'Empty name',
                                      content:
                                          'First name, Last name cannot be empty',
                                      titleColor: Colors.red,
                                    );
                                    setState(() {
                                      isloading = false;
                                    });
                                    return;
                                  }

                                  if (_position == null) {
                                    print('Please enter your location');
                                    await buildShowDialog(
                                      context,
                                      title: 'Empty location',
                                      content: 'Press location button',
                                      titleColor: Colors.red,
                                    );
                                    setState(() {
                                      isloading = false;
                                    });
                                    return;
                                  }

                                  if (!validatePhoneNumber(
                                      _phone_number.text)) {
                                    print('Please enter a valid phone number');
                                    await buildShowDialog(
                                      context,
                                      title: 'Invalid phone number',
                                      content:
                                          'Please enter valid phone number',
                                      titleColor: Colors.red,
                                    );
                                    setState(() {
                                      isloading = false;
                                    });
                                    return;
                                  }

                                  try {
                                    DateTime now = DateTime.now();
                                    await FirebaseMethods.setClientInformation(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        email: FirebaseAuth
                                            .instance.currentUser!.email!,
                                        fullName:
                                            '${_first_name.text.trim()} ${_last_name.text.trim()}',
                                        latitude: _position!.latitude,
                                        longitude: _position!.longitude,
                                        phoneNumber: _phone_number.text,
                                        timestamp: now);
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Rest(),
                                        ),
                                        (route) => false);
                                    firstSingUp = true;
                                  } catch (e) {
                                    print('Error during sign-up: $e');
                                  } finally {
                                    setState(() {
                                      isloading = false;
                                    });
                                  }
                                },
                          child: isloading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "SignUp With",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Container(
                                        height: 30,
                                        child: Image.asset(
                                          'assets/google.png',
                                          fit: BoxFit.cover,
                                        )),
                                  ],
                                ),
                        ),
                      ),

                      // Already have an account? Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                color: Color(0xFFFF3C00),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Privacy Policy Button
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Privacy policy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lottie Animation (Above the Box)
                Positioned(
                  top: -35,
                  child: SizedBox(
                    height: 200,
                    width: 200,
                    child: Lottie.asset('assets/gear_loading.json'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> buildShowDialog(BuildContext context,
      {required String title,
      required String content,
      required Color titleColor}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: titleColor),
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
