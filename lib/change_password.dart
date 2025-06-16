import 'package:flutter/material.dart';
import "package:lottie/lottie.dart";

import 'login.dart';


class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // void _submitNewPassword() {
  //   if (_newPasswordController.text == _confirmPasswordController.text &&
  //       _newPasswordController.text.isNotEmpty) {
  //     print("Password Changed Successfully");
  //   } else {
  //     print("Passwords do not match!");
  //   }
  // }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.71, -0.71),
            end: Alignment(-0.71, 0.71),
            colors: [Color(0xFF56AB94), Color(0xFF53636C)],
          ),
        ),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
           crossAxisAlignment: CrossAxisAlignment.center, // Centers content horizontally
          children: [
            SizedBox(height: 10),
            Text(
              'Change password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20),

            SizedBox(
              height: 300,
              width: 300,
              child: Lottie.asset(
                'assets/lock.json',
                repeat: true,
                animate: true,
              ),
            ),

            SizedBox(height: 10),

            // New Password Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _newPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            // Confirm Password Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Confirm Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF3D00),
                padding: EdgeInsets.symmetric(horizontal: 80,vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: (){
                Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
              },
              child: Text(
                'confirm',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}