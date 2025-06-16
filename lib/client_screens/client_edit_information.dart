import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grad_project/components/collections.dart';
import '../components/dialog_utils.dart';
import '../components/location_methods.dart';
import '../components/validate_inputs.dart';

class ClientEditInformation extends StatefulWidget {
  @override
  _ClientEditInformationState createState() => _ClientEditInformationState();
}

class _ClientEditInformationState extends State<ClientEditInformation> {
  Position? _position;
  bool isloading2 = false;
  bool isloading = false;
  bool doneUpdated = false;
  TextEditingController _firstName = TextEditingController();
  TextEditingController  _lastName= TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.71, -0.71),
          end: Alignment(-0.71, 0.71),
          colors: [Color(0xFF56AB94), Color(0xFF53636C)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Profile information',
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
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      const SizedBox(height: 16),
                      _buildTextField("First Name",_firstName),
                      _buildTextField("Last Name",_lastName),
                      _buildTextField("Password",_password, obscureText: true),
                      _buildTextField("Confirm Password",_confirmPassword, obscureText: true),
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
                      _buildTextField("Phone Number",_phoneNumber),
                      const SizedBox(height: 10),

                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed:isloading||doneUpdated?null: () async{
                          setState(() {
                            isloading = true;
                          });
                          if (_firstName.text.isEmpty || _lastName.text.isEmpty) {
                            print('Please enter your full name');
                            await DialogUtils.buildShowDialog(context, title: 'Empty name', content: 'First name, Last name cannot be empty', titleColor: Colors.red,);
                            setState(() {
                              isloading = false;
                            });
                            return;
                          }

                          if (!ValidateInputs.validatePassword(_password.text)) {
                            await DialogUtils.buildShowDialog(context, title: 'Password length', content: 'Password must be at least 6 characters', titleColor: Colors.red,);
                            setState(() {
                              isloading = false;
                            });
                            return;
                          }

                          if (_password.text != _confirmPassword.text) {
                            await DialogUtils.buildShowDialog(context, title: 'Passwords do not match', content: 'password and confirm password do not match', titleColor: Colors.red,);
                            setState(() {
                              isloading = false;
                            });
                            return;
                          }

                          if (_position==null) {
                            await DialogUtils.buildShowDialog(context, title: 'Empty location', content: 'press on location button', titleColor: Colors.red,);
                            setState(() {
                              isloading = false;
                            });
                            return;
                          }
                          if (!ValidateInputs.validatePhoneNumber(_phoneNumber.text)) {
                            await DialogUtils.buildShowDialog(context, title: 'Invalid phone number', content: 'Please enter valid phone number', titleColor: Colors.red,);
                            setState(() {
                              isloading = false;
                            });
                            return;
                          }

                          try{
                            final userAuth = FirebaseAuth.instance.currentUser;

                            DateTime now = DateTime.now();
                            await userAuth!.updatePassword(_password.text);
                            await FirebaseFirestore.instance.collection(CollectionsNames.clientsInformation).doc(userAuth.uid).update(
                              {
                                ClientFieldsName.fullName : '${_firstName.text.trim()} ${_lastName.text.trim()}',
                                ClientFieldsName.latitude : _position!.latitude,
                                ClientFieldsName.longitude : _position!.longitude,
                                ClientFieldsName.phoneNumber : _phoneNumber.text,
                              }
                            );
                            doneUpdated = true;
                            // await DialogUtils.buildShowDialog(context, title: 'Done', content: 'Please enter valid phone number', titleColor: Colors.red,);
                          }
                          catch(e)
                          {
                              print(e);
                          }
                          finally{
                            setState(() {
                              isloading = false;
                            });
                          }
                          //TODO
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                        ),
                        child: isloading?CircularProgressIndicator(color:Colors.grey):Container(
                          width: 100,
                          child: Center(
                            child: Text(
                              doneUpdated?"Done":"Edit",
                              style: TextStyle(color: doneUpdated?Colors.green:Colors.black,fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label,TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }

}
