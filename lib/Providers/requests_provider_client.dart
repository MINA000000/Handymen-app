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
  }
}
//
// class lol extends ChangeNotifier {
//   List<QueryDocumentSnapshot> _requests = [];
//   final List<QueryDocumentSnapshot> _approved = [];
//   final List<QueryDocumentSnapshot> _notApproved = [];
//   final List<QueryDocumentSnapshot> _done = [];
//   bool _isLoading = true;
//
//   List<QueryDocumentSnapshot> get requests => _requests;
//   List<QueryDocumentSnapshot> get approved => _approved;
//   List<QueryDocumentSnapshot> get notApproved => _notApproved;
//   List<QueryDocumentSnapshot> get done => _done;
//   bool get isLoading => _isLoading;
//   RequestsProvider(){
//     _fetchRequests();
//   }
//   void _fetchRequests()async {
//     await FirebaseFirestore.instance
//         .collection('request_information')
//         .where('uid',isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//         .orderBy('timestamp',descending: true)
//         .snapshots()
//         .listen((snapshot) {
//       _requests = snapshot.docs;
//       for(var doc in _requests){
//         if(doc[RequestFieldsName.status]==RequestStatus.approved){
//           _approved.add(doc);
//         }
//         else if(doc[RequestFieldsName.status]==RequestStatus.notApproved){
//           _notApproved.add(doc);
//         }
//         else{
//           _done.add(doc);
//         }
//       }
//       _isLoading = false;
//       notifyListeners(); // ✅ Notify listeners to update UI
//     });
//   }
// }
