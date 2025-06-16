import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/rest.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:math';

class ConfirmationScreen extends StatefulWidget {
  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final List<TextEditingController> _pinControllers =
  List.generate(6, (_) => TextEditingController());
  String _verificationCode = '';
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Generate a 6-digit verification code
  String generateVerificationCode() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Send the verification code to the user's email
  Future<void> sendVerificationCode(String email, String code) async {
    final HttpsCallable callable =
    FirebaseFunctions.instance.httpsCallable('sendVerificationCode');
    try {
      final response = await callable.call({
        'email': email,
        'code': code,
      });
      print('Email sent: ${response.data}');
    } catch (e) {
      print('Failed to send email: $e');
      throw e; // Rethrow the error to handle it in the UI
    }
  }

  // Store the verification code in Firestore
  Future<void> storeVerificationCode(String email, String code) async {
    await FirebaseFirestore.instance.collection('verificationCodes').doc(email).set({
      'code': code,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Verify the code entered by the user
  Future<bool> verifyCode(String email, String userEnteredCode) async {
    final doc = await FirebaseFirestore.instance
        .collection('verificationCodes')
        .doc(email)
        .get();
    if (doc.exists) {
      final storedCode = doc.data()!['code'];
      final timestamp = doc.data()!['timestamp'].toDate();
      final now = DateTime.now();

      // Check if the code is correct and not expired (e.g., 10 minutes)
      if (storedCode == userEnteredCode && now.difference(timestamp).inMinutes <= 10) {
        return true; // Code is valid
      }
    }
    return false; // Code is invalid or expired
  }

  // Handle PIN submission
  void _submitPin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user's email
      final email = FirebaseAuth.instance.currentUser?.email;
      if (email == null) {
        throw Exception('User is not authenticated or email is missing.');
      }

      // Combine all digits into one string
      String pin = _pinControllers.map((controller) => controller.text).join();
      print("Entered PIN: $pin");

      // Verify the code
      final isValid = await verifyCode(email, pin);
      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email verified successfully!')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (_)=>Rest()));
        // Navigate to the next screen or perform other actions
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid or expired code')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Send the verification code when the screen loads
  @override
  void initState() {
    super.initState();
    _sendCodeOnLoad();
  }

  Future<void> _sendCodeOnLoad() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user's email
      final email = FirebaseAuth.instance.currentUser?.email;
      if (email == null) {
        throw Exception('User is not authenticated or email is missing.');
      }

      // Generate and send the verification code
      _verificationCode = generateVerificationCode();
      await storeVerificationCode(email, _verificationCode);
      await sendVerificationCode(email, _verificationCode);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification code sent to $email')),
      );
    } catch (e) {
      print('Failed to send verification code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send verification code: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.71, -0.71),
              end: Alignment(-0.71, 0.71),
              colors: [Color(0xFF56AB94), Color(0xFF53636C)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text(
                'Confirmation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              CircleAvatar(
                radius: 100,
                backgroundColor: Colors.orange.shade200,
                child: Lottie.asset('assets/confirm_reset.json'),
              ),
              SizedBox(height: 20),
              Text(
                'Enter the 6-digit \n activation number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: TextField(
                          controller: _pinControllers[index],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              FocusScope.of(context).nextFocus();
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF3D00),
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _submitPin,
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: _sendCodeOnLoad,
                child: Text(
                  'Didn’t receive the code? Send again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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