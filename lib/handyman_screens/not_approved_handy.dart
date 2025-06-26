import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotApprovedHandy extends StatelessWidget {
  QueryDocumentSnapshot request;
  NotApprovedHandy({super.key,required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Not approved handy'),
      ),
    );
  }
}
