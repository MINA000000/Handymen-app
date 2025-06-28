import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:animate_do/animate_do.dart';
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
  bool isLoadingLocation = false;
  bool isLoadingName = false;
  bool isLoadingPhone = false;
  bool doneNameUpdated = false;
  bool donePhoneUpdated = false;
  bool doneLocationUpdated = false;
  bool isEditingName = false;
  bool isEditingPhone = false;
  bool isEditingLocation = false;
  TextEditingController _fullName = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  String? originalFullName;
  String? originalPhoneNumber;
  Position? originalPosition;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userAuth = FirebaseAuth.instance.currentUser;
      final doc = await FirebaseFirestore.instance
          .collection(CollectionsNames.clientsInformation)
          .doc(userAuth!.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _fullName.text = data[ClientFieldsName.fullName] as String? ?? '';
          _phoneNumber.text =
              data[ClientFieldsName.phoneNumber] as String? ?? '';
          originalFullName = _fullName.text;
          originalPhoneNumber = _phoneNumber.text;
          if (data[ClientFieldsName.latitude] != null &&
              data[ClientFieldsName.longitude] != null) {
            _position = Position(
              latitude: data[ClientFieldsName.latitude] as double,
              longitude: data[ClientFieldsName.longitude] as double,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
            originalPosition = _position;
          }
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      await DialogUtils.buildShowDialog(
        context,
        title: 'Fetch Failed',
        content: 'Failed to load profile data. Please try again.',
        titleColor: Color.fromRGBO(255, 61, 0, 0.9),
      );
    }
  }

  Future<void> _updateName() async {
    setState(() {
      isLoadingName = true;
    });
    if (_fullName.text.isEmpty) {
      await DialogUtils.buildShowDialog(
        context,
        title: 'Empty Name',
        content: 'Full name cannot be empty',
        titleColor: Color.fromRGBO(255, 61, 0, 0.9),
      );
      setState(() {
        isLoadingName = false;
      });
      return;
    }

    try {
      final userAuth = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection(CollectionsNames.clientsInformation)
          .doc(userAuth!.uid)
          .update({
        ClientFieldsName.fullName: _fullName.text.trim(),
      });
      setState(() {
        doneNameUpdated = true;
        originalFullName = _fullName.text;
        isEditingName = false;
      });
      await DialogUtils.buildShowDialog(
        context,
        title: 'Name Updated',
        content: 'Your name has been updated successfully',
        titleColor: Color.fromRGBO(33, 150, 243, 0.9),
      );
    } catch (e) {
      print('Error updating name: $e');
      await DialogUtils.buildShowDialog(
        context,
        title: 'Update Failed',
        content: 'Failed to update name. Please try again.',
        titleColor: Color.fromRGBO(255, 61, 0, 0.9),
      );
    } finally {
      setState(() {
        isLoadingName = false;
      });
    }
  }

  Future<void> _updatePhoneNumber() async {
    setState(() {
      isLoadingPhone = true;
    });
    if (!ValidateInputs.validatePhoneNumber(_phoneNumber.text)) {
      await DialogUtils.buildShowDialog(
        context,
        title: 'Invalid Phone Number',
        content: 'Please enter a valid phone number',
        titleColor: Color.fromRGBO(255, 61, 0, 0.9),
      );
      setState(() {
        isLoadingPhone = false;
      });
      return;
    }

    try {
      final userAuth = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection(CollectionsNames.clientsInformation)
          .doc(userAuth!.uid)
          .update({
        ClientFieldsName.phoneNumber: _phoneNumber.text,
      });
      setState(() {
        donePhoneUpdated = true;
        originalPhoneNumber = _phoneNumber.text;
        isEditingPhone = false;
      });
      await DialogUtils.buildShowDialog(
        context,
        title: 'Phone Number Updated',
        content: 'Your phone number has been updated successfully',
        titleColor: Color.fromRGBO(33, 150, 243, 0.9),
      );
    } catch (e) {
      print('Error updating phone number: $e');
      await DialogUtils.buildShowDialog(
        context,
        title: 'Update Failed',
        content: 'Failed to update phone number. Please try again.',
        titleColor: Color.fromRGBO(255, 61, 0, 0.9),
      );
    } finally {
      setState(() {
        isLoadingPhone = false;
      });
    }
  }

  Future<void> _updateLocation() async {
    setState(() {
      isLoadingLocation = true;
    });
    try {
      _position = await LocationMethods.getUserLocation();
      final userAuth = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection(CollectionsNames.clientsInformation)
          .doc(userAuth!.uid)
          .update({
        ClientFieldsName.latitude: _position!.latitude,
        ClientFieldsName.longitude: _position!.longitude,
      });
      setState(() {
        doneLocationUpdated = true;
        originalPosition = _position;
        isEditingLocation = false;
      });
      await DialogUtils.buildShowDialog(
        context,
        title: 'Location Updated',
        content: 'Your location has been updated successfully',
        titleColor: Color.fromRGBO(33, 150, 243, 0.9),
      );
    } catch (e) {
      print('Error updating location: $e');
      await DialogUtils.buildShowDialog(
        context,
        title: 'Update Failed',
        content: 'Failed to update location. Please try again.',
        titleColor: Color.fromRGBO(255, 61, 0, 0.9),
      );
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  void _cancelName() {
    setState(() {
      _fullName.text = originalFullName ?? '';
      isEditingName = false;
    });
  }

  void _cancelPhoneNumber() {
    setState(() {
      _phoneNumber.text = originalPhoneNumber ?? '';
      isEditingPhone = false;
    });
  }

  void _cancelLocation() {
    setState(() {
      _position = originalPosition;
      isEditingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
              'Profile Information',
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
                      backgroundColor: Color.fromRGBO(33, 150, 243, 0.7),
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.95),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Nunito',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: Container(
                    width: screenWidth * 0.9,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromRGBO(255, 255, 255, 0.95),
                          Color.fromRGBO(245, 245, 245, 0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color.fromRGBO(255, 255, 255, 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Section
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            'Name',
                            style: TextStyle(
                              color: Color.fromRGBO(33, 33, 33, 0.9),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTextField("Full Name", _fullName,
                                    enabled: isEditingName && !doneNameUpdated),
                              ),
                              const SizedBox(width: 8),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1100),
                                child: IconButton(
                                  onPressed: doneNameUpdated
                                      ? null
                                      : () {
                                          setState(() {
                                            isEditingName = !isEditingName;
                                          });
                                        },
                                  icon: Icon(
                                    Icons.edit,
                                    color: doneNameUpdated
                                        ? Colors.grey
                                        : Color.fromRGBO(255, 61, 0, 0.7),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isEditingName && !doneNameUpdated) ...[
                          const SizedBox(height: 12),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1200),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ZoomIn(
                                  duration: const Duration(milliseconds: 600),
                                  child: ElevatedButton(
                                    onPressed: _cancelName,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(33, 150, 243, 0.9),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 8,
                                      shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Nunito',
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ZoomIn(
                                  duration: const Duration(milliseconds: 600),
                                  child: ElevatedButton(
                                    onPressed:
                                        isLoadingName ? null : _updateName,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(255, 61, 0, 0.9),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 8,
                                      shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                                    ),
                                    child: isLoadingName
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            doneNameUpdated ? 'Done' : 'Save',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Nunito',
                                              color: doneNameUpdated
                                                  ? Colors.green
                                                  : Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Phone Number Section
                        FadeInUp(
                          duration: const Duration(milliseconds: 1300),
                          child: Text(
                            'Phone Number',
                            style: TextStyle(
                              color: Color.fromRGBO(33, 33, 33, 0.9),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1400),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                    "Phone Number", _phoneNumber,
                                    enabled:
                                        isEditingPhone && !donePhoneUpdated),
                              ),
                              const SizedBox(width: 8),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1500),
                                child: IconButton(
                                  onPressed: donePhoneUpdated
                                      ? null
                                      : () {
                                          setState(() {
                                            isEditingPhone = !isEditingPhone;
                                          });
                                        },
                                  icon: Icon(
                                    Icons.edit,
                                    color: donePhoneUpdated
                                        ? Colors.grey
                                        : Color.fromRGBO(255, 61, 0, 0.7),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isEditingPhone && !donePhoneUpdated) ...[
                          const SizedBox(height: 12),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ZoomIn(
                                  duration: const Duration(milliseconds: 600),
                                  child: ElevatedButton(
                                    onPressed: _cancelPhoneNumber,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(33, 150, 243, 0.9),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 8,
                                      shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Nunito',
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ZoomIn(
                                  duration: const Duration(milliseconds: 600),
                                  child: ElevatedButton(
                                    onPressed: isLoadingPhone
                                        ? null
                                        : _updatePhoneNumber,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(255, 61, 0, 0.9),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 8,
                                      shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                                    ),
                                    child: isLoadingPhone
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            donePhoneUpdated ? 'Done' : 'Save',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Nunito',
                                              color: donePhoneUpdated
                                                  ? Colors.green
                                                  : Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Location Section
                        FadeInUp(
                          duration: const Duration(milliseconds: 1700),
                          child: Text(
                            'Location',
                            style: TextStyle(
                              color: Color.fromRGBO(33, 33, 33, 0.9),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1800),
                          child: SizedBox(
                            width: double.infinity,
                            child: ZoomIn(
                              duration: const Duration(milliseconds: 600),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(255, 61, 0, 0.9),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 8,
                                  shadowColor:
                                      const Color.fromRGBO(0, 0, 0, 0.3),
                                ),
                                icon: isLoadingLocation
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                label: const Text(
                                  'Update Location',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                onPressed: isLoadingLocation
                                    ? null
                                    : () {
                                        setState(() {
                                          isEditingLocation = true;
                                        });
                                        _updateLocation();
                                      },
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(255, 255, 255, 0.95),
            Color.fromRGBO(245, 245, 245, 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color.fromRGBO(255, 255, 255, 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(33, 33, 33, 0.9),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color.fromRGBO(33, 33, 33, 0.5),
            fontFamily: 'Nunito',
            fontSize: 16,
          ),
          prefixIcon: Icon(
            label.contains('Name') ? Icons.person : Icons.phone,
            color: Color.fromRGBO(255, 61, 0, 0.7),
            size: 24,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}
