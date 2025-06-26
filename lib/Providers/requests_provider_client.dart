import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/components/firebase_methods.dart';
import '../components/collections.dart';

class RequestsProviderClient extends ChangeNotifier {
  List<QueryDocumentSnapshot> _requests = [];
  final List<QueryDocumentSnapshot> _approved = [];
  final List<QueryDocumentSnapshot> _notApproved = [];
  final List<QueryDocumentSnapshot> _done = [];
  bool _isLoading = true;

  List<QueryDocumentSnapshot> get requests => _requests;
  List<QueryDocumentSnapshot> get approved => _approved;
  List<QueryDocumentSnapshot> get notApproved => _notApproved;
  List<QueryDocumentSnapshot> get done => _done;
  bool get isLoading => _isLoading;

  RequestsProviderClient() {
    _fetchRequests();
  }
  void changeState() {
    notifyListeners();
  }

  void _fetchRequests() {
    FirebaseFirestore.instance
        .collection('request_information')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _requests = snapshot.docs;

      _approved.clear();
      _notApproved.clear();
      _done.clear();

      for (var doc in _requests) {
        if (doc[RequestFieldsName.status] == RequestStatus.approved) {
          _approved.add(doc);
        } else if (doc[RequestFieldsName.status] == RequestStatus.notApproved) {
          _notApproved.add(doc);
        } else {
          _done.add(doc);
        }
      }

      _isLoading = false;
      notifyListeners(); // ✅ Notify UI about updates
    });
    notifyListeners();
  }

  Future<void> refresh() async {
    try{
      _isLoading = true;
    notifyListeners();

    var snapshot = await FirebaseFirestore.instance
        .collection('request_information')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .get();

    _requests = snapshot.docs;

    _approved.clear();
    _notApproved.clear();
    _done.clear();

    for (var doc in _requests) {
      if (doc[RequestFieldsName.status] == RequestStatus.approved) {
        _approved.add(doc);
      } else if (doc[RequestFieldsName.status] == RequestStatus.notApproved) {
        _notApproved.add(doc);
      } else {
        _done.add(doc);
      }
    }

    _isLoading = false;
    notifyListeners();
    }
    catch(e){
        print("❌ Firestore Stream Error on refresh client provider: $e");
        _isLoading = false;
        notifyListeners(); 
    }
  }
  
}
