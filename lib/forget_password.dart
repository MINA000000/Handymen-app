import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/components/dialog_utils.dart';
import 'package:grad_project/components/validate_inputs.dart';
import 'package:lottie/lottie.dart';

import 'reset_password.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController _email = TextEditingController();

  bool isloading = false;

  @override
  Widget build(BuildContext context) {
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
                colors: [Color(0xFF56AB94), Color(0xFF53636C)],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Moves everything up
                children: [
                  const SizedBox(height: 50), // Added top spacing

                  // Lottie Animation (Moved Up)
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: SizedBox(
                      width: 320, // Slightly reduced size for better positioning
                      height: 320,
                      child: Lottie.asset('assets/forgot_password.json'), // Ensure correct path
                    ),
                  ),
                  const SizedBox(height: 10), // Reduced space

                  // Forgot Password Text (Moved Up)
                  const Text(
                    'Did you forget your \npassword?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 25), // Adjusted spacing

                  // Phone Number Input Field (Reduced Height & Rounded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      height: 45, // Reduced height
                      child: TextField(
                        //TODO controller here
                        controller: _email ,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter your Email ',
                          hintStyle: const TextStyle(
                            color: Color(0xFF53636C),
                            fontSize: 18,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                          ),
                          prefixIcon: const Icon(Icons.email, color: Color(0xFF53636C)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15), // More rounded corners
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Next Button (Final Version)
                  SizedBox(
                    width: 200, // Button width
                    height: 50, // Button height
                    child: ElevatedButton(

                      onPressed: isloading?null: () async{
                        setState(() {
                          isloading = true;
                        });
                        //TODO validate email then send him email reset password then take him to login screen
                        if(!ValidateInputs.validateEmail(_email.text))
                          {
                            await DialogUtils.buildShowDialog(context, title: "Wrong Format", content: "Please write valid email address", titleColor: Colors.red);
                            setState(() {
                              isloading = false;
                            });
                            return;
                          }
                        try{
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text);
                          await DialogUtils.buildShowDialog(context, title: "Done", content: "Email send to helping you reset your password", titleColor: Colors.green);
                          Navigator.pop(context);
                        }
                        catch(e)
                        {
                          print("error happened Mina1 is : $e");
                        }
                        finally
                        {
                          setState(() {
                            isloading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 60, 0),//const Color(0xFFFF3C00), // Bright Orange like Reset button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Rounded button
                        ),
                      ),
                      child: isloading?CircularProgressIndicator(color: Colors.blue,):const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
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
}