import 'package:flutter/material.dart';
import 'package:grad_project/components/wrapper.dart';

class BuildField{
  static Widget buildTextField(
      String hint, IconData icon, TextInputType inputType, TextEditingController controller, Function updateState, bool firstSignUp) {
    return SizedBox(
      height: 45,
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: (controller.text.isEmpty && !firstSignUp) ? Colors.red : Colors.transparent,
            ),
          ),
        ),
        onChanged: (value) {
          updateState();
        },
      ),
    );
  }

  static Widget buildPasswordField(String hint, TextEditingController controller, Function updateState, bool firstSignUp, bool isEqual,BoolWrapper isVisible) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: controller,
        obscureText:isVisible.value?false:true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
          suffixIcon:  IconButton(onPressed: (){
            isVisible.value = !isVisible.value;
            updateState();
          }, icon: Icon((isVisible.value)?Icons.visibility:Icons.visibility_off)),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: (controller.text.isEmpty && !firstSignUp) ? Colors.red : (isEqual) ? Colors.transparent : Colors.red,
            ),
          ),
        ),
        onChanged: (value) {
          updateState();
        },
      ),
    );
  }

  static Widget buildSocialButton(String assetPath) {
    return GestureDetector(

      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 40,
            height: 40,
          ),
        ),
      ),
    );
  }
}