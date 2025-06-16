import 'package:flutter/material.dart';

class Providermina extends ChangeNotifier {
  String role = 'client';
  // String email = '';
  void changeState() {
    notifyListeners(); // Notify listeners when the state changes
  }
}