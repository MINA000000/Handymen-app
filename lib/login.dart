import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/ProviderMina.dart';
import 'package:grad_project/Providers/requests_provider_client.dart';
import 'package:grad_project/Providers/requests_provider_handyman.dart';
import 'package:grad_project/client_signup.dart';
import 'package:grad_project/components/build_field.dart';
import 'package:grad_project/components/dialog_utils.dart';
import 'package:grad_project/components/firebase_methods.dart';
import 'package:grad_project/components/validate_inputs.dart';
import 'package:grad_project/components/wrapper.dart';
import 'package:grad_project/confirm_password.dart';
import 'package:grad_project/rest.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'client_signup_google.dart';
import 'components/collections.dart';
import 'forget_password.dart';
import 'handyman_signup.dart';
import 'handyman_signup_google.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  bool googleLoading = false;

  updateState() {
    setState(() {});
  }

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool firstLogin = true;
  BoolWrapper passvis = BoolWrapper(false);
  @override
  Widget build(BuildContext context) {
    final providerSetting = Provider.of<Providermina>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
                  // Black Border Container (Login Form)
                  Container(
                    width: 320,
                    margin: const EdgeInsets.only(
                        top: 100), // Increased space for larger GIF
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 40), // Space for GIF

                        // Title
                        const Text(
                          'Log in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Form Fields
                        BuildField.buildTextField(
                          'Email address',
                          Icons.email,
                          TextInputType.emailAddress,
                          _email,
                          updateState,
                          firstLogin,
                        ),
                        const SizedBox(height: 20), // Reduced spacing
                        BuildField.buildPasswordField('Password', _password,
                            updateState, firstLogin, true, passvis),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ForgetPasswordScreen()),
                              );
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    firstLogin = false;
                                    if (!ValidateInputs.validateEmail(
                                        _email.text)) {
                                      print(
                                          'Please enter a valid email address');
                                      DialogUtils.buildShowDialog(
                                        context,
                                        title: 'Invalid email',
                                        content: 'Please enter valid email',
                                        titleColor: Colors.red,
                                      );
                                      setState(() {
                                        isLoading = false;
                                      });
                                      return;
                                    }

                                    if (!ValidateInputs.validatePassword(
                                        _password.text)) {
                                      print(
                                          'Password must be at least 6 characters');
                                      DialogUtils.buildShowDialog(
                                        context,
                                        title: 'Password length',
                                        content:
                                            'Password must be at least 6 characters',
                                        titleColor: Colors.red,
                                      );
                                      setState(() {
                                        isLoading = false;
                                      });
                                      return;
                                    }
                                    try {
                                      // print(FirebaseAuth.instance.currentUser!.email);
                                      // if(FirebaseA)
                                      FirebaseAuth.instance.signOut();
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                              email: _email.text,
                                              password: _password.text);
                                      if (FirebaseAuth.instance.currentUser!
                                          .emailVerified) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Rest(),
                                          ),
                                          (route) => false,
                                        );
                                      } else {
                                        // print(FirebaseAuth.instance.currentUser!.email);
                                        // return;
                                        await FirebaseAuth.instance.currentUser!
                                            .sendEmailVerification();
                                        await DialogUtils.buildShowDialog(
                                          context,
                                          title: 'Email verification',
                                          content:
                                              'Email must be verified first , email send to you',
                                          titleColor: Colors.red,
                                        );
                                        // Navigator.push(context, MaterialPageRoute(builder: (_)=>ConfirmationScreen()));
                                      }
                                    } catch (e) {
                                      print(e);
                                      DialogUtils.buildShowDialog(
                                        context,
                                        title: 'Error',
                                        content: 'Invalid email or password',
                                        titleColor: Colors.red,
                                      );
                                    } finally {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 255, 60, 0),
                              //padding: const EdgeInsets.symmetric(vertical: 8), // Reduced height
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Log in',
                                    style: TextStyle(
                                      fontSize:
                                          28, // Slightly reduced font size
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
                            Expanded(
                              child: Divider(color: Colors.white, thickness: 1),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'or log in with',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Expanded(
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
                              onTap: googleLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        googleLoading = true;
                                      });
                                      try {
                                        bool isSuccess = await FirebaseMethods
                                            .signInWithGoogle();
                                        if (!isSuccess) {
                                          setState(() {
                                            googleLoading = false;
                                          });
                                          // print('ERROR 1');
                                          // await DialogUtils.buildShowDialog(context, title: 'Sign', content: 'please complete your information !', titleColor: Colors.orange);
                                          return;
                                        }
                                        // print(FirebaseAuth.instance.currentUser!.uid);
                                        bool handymanExist =
                                            await FirebaseMethods
                                                .checkIfUserExists(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    CollectionsNames
                                                        .handymenInformation);
                                        bool clientExist = await FirebaseMethods
                                            .checkIfUserExists(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                CollectionsNames
                                                    .clientsInformation);
                                        // print(handymanExist);
                                        // print(clientExist);
                                        if (!handymanExist && !clientExist) {
                                          await DialogUtils.buildShowDialog(
                                              context,
                                              title: 'Information missing',
                                              content:
                                                  'please complete your information !',
                                              titleColor: Colors.orange);
                                          if (providerSetting.role ==
                                              'client') {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ClientSignUpGoogle(),
                                                ));
                                          } else if (providerSetting.role ==
                                              'handyman') {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      HandymanSignupGoogle(),
                                                ));
                                          }
                                          setState(() {
                                            googleLoading = false;
                                          });
                                          // print('ERROR 2');
                                          return;
                                        }
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Rest(),
                                            ),
                                            (route) => false);
                                        final requestsProviderHandy = Provider
                                            .of<RequestsProviderHandyman>(
                                                context);
                                        final requestsProviderClient =
                                            Provider.of<RequestsProviderClient>(
                                                context);
                                        requestsProviderClient.refresh();
                                        requestsProviderHandy.refresh();
                                      } catch (e) {
                                        print(e);
                                      } finally {
                                        setState(() {
                                          googleLoading = false;
                                        });
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
                                child: googleLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.grey,
                                      )
                                    : Center(
                                        child: Image.asset('assets/google.png',
                                            width: 80, height: 80),
                                      ),
                              ),
                            ),
                          ],
                        ),

                        //const SizedBox(height: 8),

                        // Register Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don’t have an account?',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () {
                                String role = providerSetting.role;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => (role == 'client')
                                          ? SignUpScreen()
                                          : HandymanSignUp()),
                                );
                              },
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 60, 0),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Privacy Policy
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Privacy policy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),

                  // Lottie Animation (Placed Above the Box) - Increased Size
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      height: 200, // Increased size
                      width: 200, // Increased size
                      child: Lottie.asset('assets/gear_loading.json'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Social Login Button - Reduced margin & changed border color to black
}
