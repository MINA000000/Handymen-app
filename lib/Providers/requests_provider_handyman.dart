import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/components/firebase_methods.dart';
import '../components/collections.dart';

class RequestsProviderHandyman extends ChangeNotifier {
  List<QueryDocumentSnapshot> _requests = [];
  final List<QueryDocumentSnapshot> _approved = [];
  final List<QueryDocumentSnapshot> _client_want = [];
  final List<QueryDocumentSnapshot> _handyman_want = [];
  final List<QueryDocumentSnapshot> _done = [];
  bool _isLoading = true;
  DocumentSnapshot? handyman;
  List<QueryDocumentSnapshot> get requests => _requests;
  List<QueryDocumentSnapshot> get approved => _approved;
  List<QueryDocumentSnapshot> get clientWant => _client_want;
  List<QueryDocumentSnapshot> get handymanWant => _handyman_want;
  List<QueryDocumentSnapshot> get done => _done;
  bool get isLoading => _isLoading;
  RequestsProviderHandyman() {
    _fetchRequests();
  }
  Future<void> _fetchHandyman() async {
    try {
      handyman = await FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _fetchRequests() async {
    try {
      await _fetchHandyman();
      _isLoading = true;
      notifyListeners(); // ✅ Notify UI before fetching

      FirebaseFirestore.instance
          .collection('request_information')
          .orderBy('timestamp', descending: true)
          .where('category', isEqualTo: handyman!.get('category'))
          .snapshots()
          .listen((snapshot) {
        print("🔥 Firestore Data Updated ${snapshot.docs.length}");

        _requests = snapshot.docs;
        _approved.clear();
        _client_want.clear();
        _handyman_want.clear();
        _done.clear();

        final handymanUID = FirebaseAuth.instance.currentUser!.uid;

        for (var doc in _requests) {
          var data = doc.data() as Map<String, dynamic>;

          if (data[RequestFieldsName.status] == RequestStatus.approved &&
              handymanUID == data['assigned_handyman']) {
            _approved.add(doc);
          } else if (data[RequestFieldsName.status] ==
              RequestStatus.notApproved) {
            if ((data[RequestFieldsName.clientWantingHandymen] as List)
                .contains(handymanUID)) {
              _client_want.add(doc);
            } else if ((data[RequestFieldsName.handymenWantingRequest] as List)
                .contains(handymanUID)) {
              _handyman_want.add(doc);
            }
          } else if (data[RequestFieldsName.status] == RequestStatus.done &&
              handymanUID == data['assigned_handyman']) {
            _done.add(doc);
          }
        }

        _isLoading = false;
        notifyListeners(); // ✅ Notify UI after updating lists
      }, onError: (error) {
        print("❌ Firestore Stream Error on refresh handyman provider: $error");
        _isLoading = false;
        notifyListeners(); // ✅ Notify UI on error
      });
    } catch (e) {
      print("❌ Firestore Stream Error on refresh handyman provider: $e");
      _isLoading = false;
      notifyListeners(); // ✅ Ensure UI updates on failure
    }
  }
  Future<void> refresh() async {
     _fetchRequests();
  }
}
