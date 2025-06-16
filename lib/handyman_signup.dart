import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grad_project/api_services/api_service_openai.dart';
import 'package:grad_project/components/build_field.dart';
import 'package:grad_project/components/skills_data.dart';
import 'package:grad_project/components/location_methods.dart';
import 'package:grad_project/rest.dart';
import 'package:image_picker/image_picker.dart';
import "package:lottie/lottie.dart";
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'ProviderMina.dart';
import 'client_signup_google.dart';
import 'components/collections.dart';
import 'components/dialog_utils.dart';
import 'components/firebase_methods.dart';
import 'components/validate_inputs.dart';
import 'components/wrapper.dart';
import 'handyman_signup_google.dart';
import 'login.dart';

class HandymanSignUp extends StatefulWidget {
  @override
  _HandymanSignUpState createState() => _HandymanSignUpState();
}

class _HandymanSignUpState extends State<HandymanSignUp> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  // final ApiServiceOpenai _apiService = ApiServiceOpenai();
  BoolWrapper passvis1 = BoolWrapper(false);
  BoolWrapper passvis2 = BoolWrapper(false);
  bool isEqualPassword = true;
  List<bool> _selectedSkills = List.generate(5, (_) => false);
  String _selectedCategory = 'Carpenter';
  // Position position = Position(longitude: 0, latitude: 0);
  final TextEditingController _projectInfoController = TextEditingController();
  bool isloading = false;
  bool isloading2 = false;
  File? _image;
  int imageNum = 0;
  Position? _position;
  bool firstSignUp = true;

  // Future<void> _fetchSkills(String uid) async {
  //   if (uid.isNotEmpty) {
  //     String response = await _apiService.fetchImplicitSkills(uid);
  //     print(response);
  //   }
  // }
  String getExplicitSkills(List<String> skills) {
    String explicitySkills = '';
    for (int i = 0; i < _selectedSkills.length; i++) {
      if (i >= skills.length)
        return "error happened : length of _selectedSkills not equal to length of skills";
      if (_selectedSkills[i] == true) {
        explicitySkills += skills[i];
        explicitySkills += ' ';
      }
    }
    return explicitySkills;
  }

  updateState() {
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery); // Use ImageSource.camera for camera

    if (pickedFile != null) {
      final savedImage = await _saveImageToLocal(File(pickedFile.path));
      setState(() {
        _image = savedImage; // Update the image when tapped again
      });
    }
  }

  Future<File> _saveImageToLocal(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/profile_image$imageNum.png';
    imageNum++;
    final savedImage = await image.copy(path);
    return savedImage;
  }

  @override
  void dispose() {
    _projectInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingProvider = Provider.of<Providermina>(context);
    if (_password.text == _confirmPassword.text) {
      isEqualPassword = true;
    } else {
      isEqualPassword = false;
    }
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    padding: EdgeInsets.only(
                        top: 30, left: 20, right: 20, bottom: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Sign Up Title (inside the box)
                        Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () async {
                            await _pickImage();
                            print(_image!.path);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26, blurRadius: 10)
                                  ],
                                ),
                                child: ClipOval(
                                  key: ValueKey(_image
                                      ?.path), // Force rebuild when image changes
                                  child: _image != null
                                      ? Image.file(_image!, fit: BoxFit.cover)
                                      : Image.asset('assets/avatar.png',
                                          fit: BoxFit.cover),
                                ),
                              ),
                              // Keep the "+" icon visible even after selecting an image
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 16,
                                  child: Icon(Icons.edit,
                                      color: Colors.blueGrey,
                                      size: 18), // Edit icon
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),
                        // First and Last Name
                        Row(
                          children: [
                            Expanded(
                              child: BuildField.buildTextField(
                                'First name',
                                Icons.person,
                                TextInputType.text,
                                _firstName,
                                updateState,
                                firstSignUp,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: BuildField.buildTextField(
                                'Last name',
                                Icons.person,
                                TextInputType.text,
                                _lastName,
                                updateState,
                                firstSignUp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Email
                        BuildField.buildTextField(
                          'Email address',
                          Icons.email,
                          TextInputType.emailAddress,
                          _email,
                          updateState,
                          firstSignUp,
                        ),
                        SizedBox(height: 8),

                        // Password
                        //_buildTextField('Password', Icons.lock, obscureText: true),
                        BuildField.buildPasswordField(
                            'Password',
                            _password,
                            updateState,
                            firstSignUp,
                            isEqualPassword,
                            passvis1),
                        SizedBox(height: 8),

                        // Confirm Password
                        //_buildTextField('Confirm password', Icons.lock, obscureText: true),
                        BuildField.buildPasswordField(
                            'Confirm password',
                            _confirmPassword,
                            updateState,
                            firstSignUp,
                            isEqualPassword,
                            passvis2),
                        SizedBox(height: 8),

                        // Location
                        // Location Button
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
                            label: isloading
                                ? CircularProgressIndicator(
                                    color: Colors.grey,
                                  )
                                : Text(
                                    (_position == null)
                                        ? 'Get Location'
                                        : 'Done',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w800,
                                      color: (_position == null)
                                          ? Colors.white
                                          : Colors.green,
                                    ),
                                  ),
                            onPressed: (isloading || _position != null)
                                ? null
                                : () async {
                                    setState(() {
                                      isloading = true;
                                    });
                                    _position =
                                        await LocationMethods.getUserLocation();
                                    setState(() {
                                      isloading = false;
                                    });
                                  },
                          ),
                        ),
                        SizedBox(height: 8),

                        BuildField.buildTextField(
                            'Phone number',
                            Icons.phone,
                            TextInputType.phone,
                            _phoneNumber,
                            updateState,
                            firstSignUp),
                        // _buildTextField('Phone number', Icons.phone),
                        SizedBox(height: 8),

                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            prefixIcon:
                                Icon(Icons.category, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: [
                            //TODO error i use 'word \n word'
                            CategoriesNames.carpenter,
                            CategoriesNames.plumbing,
                            CategoriesNames.blacksmith,
                            CategoriesNames.electrical,
                            CategoriesNames.painter,
                            CategoriesNames.aluminum,
                            CategoriesNames.marble,
                            CategoriesNames.upholsterer,
                            // 'Other'
                          ]
                              .map((category) => DropdownMenuItem(
                                    child: Text(category),
                                    value: category,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            _selectedSkills = List.generate(5, (_) => false);
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                        SizedBox(height: 20),

                        // Skills Checkboxes
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(
                              SkillsData.categorySkills[_selectedCategory]!
                                  .length, (index) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _selectedSkills[index],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSkills[index] = value!;
                                    });
                                  },
                                ),
                                Text(
                                  '${SkillsData.categorySkills[_selectedCategory]![index]}',
                                  style: TextStyle(color: Colors.deepOrange),
                                ),
                              ],
                            );
                          }),
                        ),
                        SizedBox(height: 20),

                        // Project Info Text Field
                        TextField(
                          controller: _projectInfoController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Add information about your projects',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

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
                            onPressed: isloading2
                                ? null
                                : () async {
                                    setState(() {
                                      isloading2 = true;
                                    });
                                    if (_image == null) {
                                      await DialogUtils.buildShowDialog(
                                        context,
                                        title: 'Image empty',
                                        content: 'please pick image for you',
                                        titleColor: Colors.red,
                                      );
                                      setState(() {
                                        isloading2 = false;
                                      });
                                      return;
                                    }
                                    if (_firstName.text.isEmpty ||
                                        _lastName.text.isEmpty) {
                                      print('Please enter your full name');
                                      await DialogUtils.buildShowDialog(
                                        context,
                                        title: 'Empty name',
                                        content:
                                            'First name, Last name cannot be empty',
                                        titleColor: Colors.red,
                                      );
                                      setState(() {
                                        isloading2 = false;
                                      });
                                      return;
                                    }

                                    if (!ValidateInputs.validateEmail(
                                        _email.text)) {
                                      print(
                                          'Please enter a valid email address');
                                      await DialogUtils.buildShowDialog(
                                        context,
                                        title: 'Invalid email',
                                        content: 'Please enter valid email',
                                        titleColor: Colors.red,
                                      );
                                      setState(() {
                                        isloading2 = false;
                                      });
                                      return;
                                    }

                                    if (!ValidateInputs.validatePassword(
                                        _password.text)) {
                                      print(
                                          'Password must be at least 6 characters');
                                      await DialogUtils.buildShowDialog(
                                        context,
                                        title: 'Password length',
                                        content:
                                            'Password must be at least 6 characters',
                                        titleColor: Colors.red,
                                      );
                                      setState(() {
                                        isloading2 = false;
                                      });
                                      return;
                                    }

                                    if (_password.text !=
                                        _confirmPassword.text) {
                                      print('Passwords do not match');
                                      await DialogUtils.buildShowDialog(
                                        context,
                                        title: 'Passwords do not match',
                                        content:
                                            'password and confirm password do not match',
                                        titleColor: Colors.red,
                                      );
                                      setState(() {
                                        isloading2 = false;
                                      });
                                      return;
                                    }

                                    if (_position == null) {
                                      print('Please enter your location');
                                      await DialogUtils.buildShowDialog(
                                        context,
                                        title: 'Empty location',
                                        content: 'Press button of location',
                                        titleColor: Colors.red,
                                      );
                                      setState(() {
                                        isloading2 = false;
                                      });
                                      return;
                                    }

                                    if (!ValidateInputs.validatePhoneNumber(
                                        _phoneNumber.text)) {
                                      print(
                                          'Please enter a valid phone number');
                                      await DialogUtils.buildShowDialog(
                                        context,
                                        title: 'Invalid phone number',
                                        content:
                                            'Please enter valid phone number',
                                        titleColor: Colors.red,
                                      );
                                      setState(() {
                                        isloading2 = false;
                                      });
                                      return;
                                    }
                                    if (_projectInfoController.text.isEmpty) {
                                      await DialogUtils.buildShowDialog(
                                        context,
                                        title:
                                            'Empty Information about project',
                                        content:
                                            'Please enter your project information',
                                        titleColor: Colors.red,
                                      );
                                      setState(() {
                                        isloading2 = false;
                                      });
                                      return;
                                    }
                                    try {
                                      await FirebaseMethods
                                          .signInWithEmailPassword(
                                              _email.text, _password.text);
                                      String imageURL =
                                          await FirebaseMethods.uploadImage(
                                              _image!);
                                      DateTime now = DateTime.now();
                                      List<String> explicitSkills = SkillsData.categorySkills[_selectedCategory]!;
                                      await FirebaseMethods.setHandymanInformation(
                                          uid: FirebaseAuth
                                              .instance.currentUser!.uid,
                                          category: _selectedCategory,
                                          description:
                                              _projectInfoController.text,
                                          email: _email.text,
                                          explicitSkills: explicitSkills,
                                          fullName:
                                              '${_firstName.text.trim()} ${_lastName.text.trim()}',
                                          implicitSkills: '',
                                          latitude: _position!.latitude,
                                          longitude: _position!.longitude,
                                          phoneNumber: _phoneNumber.text,
                                          profilePicture: imageURL,
                                          ratingAverage: 0,
                                          ratingCount: 0,
                                          timestamp: now);

                                      // await _fetchSkills(FirebaseAuth.instance.currentUser!.uid);

                                      await FirebaseAuth.instance.currentUser!
                                          .sendEmailVerification();
                                      await DialogUtils.buildShowDialog(
                                        context,
                                        title: 'Done, last step',
                                        content:
                                            'Confirm email, email send to you',
                                        titleColor: Colors.green,
                                      );
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => LoginScreen()),
                                          (route) => false);
                                    } catch (e) {
                                      await DialogUtils.buildShowDialog(
                                        context,
                                        title: 'Error',
                                        content: 'Something goes wrong !!',
                                        titleColor: Colors.red,
                                      );
                                      print(e);
                                    } finally {
                                      setState(() {
                                        isloading2 = false;
                                      });
                                    }
                                  },
                            child: isloading2
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
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
                        SizedBox(height: 15),

                        // Social Media Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // BuildField.buildSocialButton(assetPath)
                            GestureDetector(
                              onTap: () async {
                                try {
                                  bool isSuccess =
                                      await FirebaseMethods.signInWithGoogle();
                                  if (!isSuccess) {
                                    // await DialogUtils.buildShowDialog(context, title: 'Sign', content: 'please complete your information !', titleColor: Colors.orange);
                                    return;
                                  }
                                  bool handymanExit =
                                      await FirebaseMethods.checkIfUserExists(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          CollectionsNames.handymenInformation);
                                  bool clientExit =
                                      await FirebaseMethods.checkIfUserExists(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          CollectionsNames.clientsInformation);
                                  if (!handymanExit && !clientExit) {
                                    await DialogUtils.buildShowDialog(context,
                                        title: 'Information missing',
                                        content:
                                            'please complete your information !',
                                        titleColor: Colors.orange);
                                    if (settingProvider.role == 'client') {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ClientSignUpGoogle(),
                                          ));
                                    } else if (settingProvider.role ==
                                        'handyman') {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                HandymanSignupGoogle(),
                                          ));
                                    }
                                    return;
                                  }
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Rest(),
                                      ),
                                      (route) => false);
                                } catch (e) {
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
                        SizedBox(height: 20),

                        // Log In Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
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

                        // Privacy Policy
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Privacy policy',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Gear GIF Positioned on top of the border box
                Positioned(
                  top: -55,
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
