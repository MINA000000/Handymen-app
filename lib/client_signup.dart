
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grad_project/components/build_field.dart';
import 'package:grad_project/components/dialog_utils.dart';
import 'package:grad_project/components/firebase_methods.dart';
import 'package:grad_project/components/validate_inputs.dart';
import 'package:grad_project/components/wrapper.dart';
import 'package:grad_project/rest.dart';
import "package:lottie/lottie.dart";
import 'package:provider/provider.dart';
import 'client_signup_google.dart';
import 'components/collections.dart';
import 'components/location_methods.dart';
import 'confirm_password.dart';
import 'login.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();

}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _first_name = TextEditingController();
  TextEditingController _last_name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirm_password = TextEditingController();
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


  @override
  Widget build(BuildContext context) {
    if (_password.text == _confirm_password.text) {
      isEqualPassword = true;
    } else {
      isEqualPassword = false;
    }

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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                      const SizedBox(height: 8),

                      // Other Form Fields
                      BuildField.buildTextField(
                        'Email address',
                        Icons.email,
                        TextInputType.emailAddress,
                        _email,
                        updateState,
                        firstSingUp,
                      ),
                      const SizedBox(height: 8),
                      BuildField.buildPasswordField(
                        'Password',
                        _password,
                        updateState,
                        firstSingUp,
                        isEqualPassword,
                        passvis1
                      ),
                      const SizedBox(height: 8),
                      BuildField.buildPasswordField(
                        'Confirm password',
                        _confirm_password,
                        updateState,
                        firstSingUp,
                        isEqualPassword,
                        passvis2
                      ),
                      const SizedBox(height: 8),
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
                          label: isloading2?CircularProgressIndicator(color: Colors.grey,):Text(
                            (_position==null)?'Get Location':'Done',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              color: (_position==null)?Colors.white:Colors.green,
                            ),
                          ),

                          onPressed: (isloading2||_position!=null)?null:() async {
                            setState(() {
                              isloading2 = true;
                            });
                            _position = await LocationMethods.getUserLocation();
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
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF3C00),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: isloading ?null:() async {
                            setState(() {
                              isloading = true;
                            });
                            // print(FirebaseAuth.instance.currentUser);
                            // return;
                            firstSingUp = false;

                            // Validate fields
                            if (_first_name.text.isEmpty || _last_name.text.isEmpty) {
                              print('Please enter your full name');
                              await DialogUtils.buildShowDialog(context, title: 'Empty name', content: 'First name, Last name cannot be empty', titleColor: Colors.red,);
                              setState(() {
                                isloading = false;
                              });
                              return;
                            }

                            if (!ValidateInputs.validateEmail(_email.text)) {
                              print('Please enter a valid email address');
                              await DialogUtils.buildShowDialog(context, title: 'Invalid email', content: 'Please enter valid email', titleColor: Colors.red,);
                              setState(() {
                                isloading = false;
                              });
                              return;
                            }

                            if (!ValidateInputs.validatePassword(_password.text)) {
                              print('Password must be at least 6 characters');
                              await DialogUtils.buildShowDialog(context, title: 'Password length', content: 'Password must be at least 6 characters', titleColor: Colors.red,);
                              setState(() {
                                isloading = false;
                              });
                              return;
                            }

                            if (_password.text != _confirm_password.text) {
                              print('Passwords do not match');
                              await DialogUtils.buildShowDialog(context, title: 'Passwords do not match', content: 'password and confirm password do not match', titleColor: Colors.red,);
                              setState(() {
                                isloading = false;
                              });
                              return;
                            }

                            if (_position==null) {
                              print('Please enter your location');
                              await DialogUtils.buildShowDialog(context, title: 'Empty location', content: 'press on location button', titleColor: Colors.red,);
                              setState(() {
                                isloading = false;
                              });
                              return;
                            }

                            if (!ValidateInputs.validatePhoneNumber(_phone_number.text)) {
                              print('Please enter a valid phone number');
                              await DialogUtils.buildShowDialog(context, title: 'Invalid phone number', content: 'Please enter valid phone number', titleColor: Colors.red,);
                              setState(() {
                                isloading = false;
                              });
                              return;
                            }


                            try {
                              // Create user with email and password
                              // String phone_number = _phone_number.text;
                              // print(phone_number);
                              // await widget.verifyPhoneNumber(phone_number, context);
                              await FirebaseMethods.signInWithEmailPassword(_email.text, _password.text);
                              DateTime now = DateTime.now();
                              // Add user information to Firestore
                              FirebaseMethods.setClientInformation(uid: FirebaseAuth.instance.currentUser!.uid, email: _email.text, fullName: '${_first_name.text.trim()} ${_last_name.text.trim()}', latitude: _position!.latitude, longitude: _position!.longitude, phoneNumber: _phone_number.text, timestamp: now);
                              await FirebaseAuth.instance.currentUser!.sendEmailVerification();
                             await DialogUtils.buildShowDialog(context, title: 'Done', content: 'Now all you need it to verify your email , email send to you', titleColor: Colors.green,);
                              // Navigate to the confirmation screen
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                              // _first_name.clear();
                              // _last_name.clear();
                              // _email.clear();
                              // _password.clear();
                              // _confirm_password.clear();
                              // _location.clear();
                              // _phone_number.clear();
                              firstSingUp = true;
                              // Update the UI

                            } catch (e) {
                              print('Error during sign-up: $e');
                            }
                            finally {
                              setState(() {
                                isloading = false;
                              });
                            }
                          },
                          child: isloading?CircularProgressIndicator(color: Colors.white):Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // OR Text with Lines
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: Colors.white, thickness: 1),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'or sign up with',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: Colors.white, thickness: 1),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Social Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async{
                             try{
                               bool isSuccess = await FirebaseMethods.signInWithGoogle();
                               if(!isSuccess)
                               {
                                 // await DialogUtils.buildShowDialog(context, title: 'Sign', content: 'please complete your information !', titleColor: Colors.orange);
                                 return;
                               }
                               bool clientExist = await FirebaseMethods.checkIfUserExists(FirebaseAuth.instance.currentUser!.uid,CollectionsNames.clientsInformation);
                               bool handymanExist = await FirebaseMethods.checkIfUserExists(FirebaseAuth.instance.currentUser!.uid,CollectionsNames.handymenInformation);
                               if(clientExist||handymanExist)
                               {
                                 Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Rest(),), (route) => false,);
                                 return;
                               }
                               Navigator.pushReplacement(
                                 context,
                                 MaterialPageRoute(
                                     builder: (context) => ClientSignUpGoogle()),
                               );
                             }
                             catch(e)
                              {
                                print(e);
                              }
                              // print("Google Login Clicked");
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                border:
                                Border.all(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Image.asset('assets/google.png',
                                    width: 80, height: 80),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

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


}
