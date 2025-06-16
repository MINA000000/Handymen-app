import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'collections.dart';

class FirebaseMethods {
  static Future<bool> checkIfUserExists(String uid, String collection) async {
    // Get a reference to the Firestore collection
    CollectionReference usersInformation =
        FirebaseFirestore.instance.collection(collection);

    // Query the collection to check if a document with the given uid exists
    DocumentSnapshot documentSnapshot = await usersInformation.doc(uid).get();

    // Return true if the document exists, otherwise return false
    return documentSnapshot.exists;
  }

  static Future<void> setClientInformation({
    required String uid,
    required String email,
    required String fullName,
    required double latitude,
    required double longitude,
    required String phoneNumber,
    required DateTime timestamp,
  }) async {
    try {
      // Reference to the Firestore collection
      final CollectionReference handymenCollection = FirebaseFirestore.instance
          .collection(CollectionsNames.clientsInformation);

      // Set or update the document with the given UID
      await handymenCollection.doc(uid).set(
          {
            ClientFieldsName.email: email,
            ClientFieldsName.fullName: fullName,
            ClientFieldsName.latitude: latitude,
            ClientFieldsName.longitude: longitude,
            ClientFieldsName.phoneNumber: phoneNumber,
            ClientFieldsName.timestamp: timestamp,
          },
          SetOptions(
              merge:
                  true)); // Use merge to update specific fields without overwriting the entire document

      // print('Handyman information set/updated successfully for UID: $uid');
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> setRequestInformation({
    required String uid,
    required String request,
    required String imageURL,
    required String status,
    required String category,
    required String handyman,
    required DateTime timestamp,
  }) async {
    try {
      // Reference to the Firestore collection
      final CollectionReference handymenCollection = FirebaseFirestore.instance
          .collection(CollectionsNames.requestInformation);

      // Add a new document and get the DocumentReference
      DocumentReference docRef = await handymenCollection.add({
        RequestFieldsName.uid: uid,
        RequestFieldsName.request: request,
        RequestFieldsName.imageURL: imageURL,
        RequestFieldsName.status: status,
        RequestFieldsName.category: category,
        RequestFieldsName.assignedHandyman: handyman,
        RequestFieldsName.clientWantingHandymen: [],
        RequestFieldsName.handymenWantingRequest: [],
        RequestFieldsName.assignedHandymanName: 'none',
        RequestFieldsName.timestamp: timestamp,
      });

      // Return the newly created document ID
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signInWithEmailPassword(
      String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      rethrow; // Rethrow the exception to handle it in the calling function
    } catch (e) {
      // print(e);
      rethrow;
    }
  }

  static Future<bool> signInWithGoogle() async {
    try {
      // Sign out any previously signed-in user
      await GoogleSignIn().signOut();

      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return false; // User canceled the sign-in process
      }

      // Get authentication details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a credential from Google's access token and ID token
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Check if the user is successfully signed in
      final User? user = userCredential.user;
      if (user != null) {
        return true; // Sign-in successful
      } else {
        return false; // Firebase sign-in failed
      }
    } catch (error) {
      // Handle any errors that occur during the process
      print('Error during Google Sign-In: $error');
      return false; // Return false if an error occurs
    }
  }

  static Future<String> uploadImage(File imageFile) async {
    // Get a reference to the storage location
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

    // Upload the image
    final uploadTask = storageRef.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/png'), // Set the content type
    );

    // Monitor the upload progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
    });

    // Wait for the upload to complete
    await uploadTask;

    // Get the download URL
    String downloadURL = await storageRef.getDownloadURL();
    return downloadURL;
    // print('File uploaded, download URL: $downloadURL');
  }

  static Future<void> setHandymanInformation({
    required String uid,
    required String category,
    required String description,
    required String email,
    required List<String> explicitSkills,
    required String fullName,
    required String implicitSkills,
    required double latitude,
    required double longitude,
    required String phoneNumber,
    required String profilePicture,
    required double ratingAverage,
    required int ratingCount,
    required DateTime timestamp,
  }) async {
    try {
      // Reference to the Firestore collection
      final CollectionReference handymenCollection = FirebaseFirestore.instance
          .collection(CollectionsNames.handymenInformation);

      // Set or update the document with the given UID
      await handymenCollection.doc(uid).set(
          {
            HandymanFieldsName.category: category,
            HandymanFieldsName.description: description,
            HandymanFieldsName.email: email,
            HandymanFieldsName.explicitSkills: explicitSkills,
            HandymanFieldsName.fullName: fullName,
            HandymanFieldsName.implicitSkills: implicitSkills,
            HandymanFieldsName.latitude: latitude,
            HandymanFieldsName.longitude: longitude,
            HandymanFieldsName.phoneNumber: phoneNumber,
            HandymanFieldsName.profilePicture: profilePicture,
            HandymanFieldsName.ratingAverage: ratingAverage,
            HandymanFieldsName.ratingCount: ratingCount,
            HandymanFieldsName.projectsCount: 0,
            HandymanFieldsName.timestamp: timestamp,
          },
          SetOptions(
              merge:
                  true)); // Use merge to update specific fields without overwriting the entire document

      print('Handyman information set/updated successfully for UID: $uid');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> addToArrayRequestsCollection(
      String docId, String handymanId, String wanting) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference docRef =
        firestore.collection(CollectionsNames.requestInformation).doc(docId);

    await docRef.update({
      wanting: FieldValue.arrayUnion([handymanId])
    });
  }
}

class RequestStatus {
  static String approved = "approved";
  static String notApproved = "notApproved";
  static String done = "done";
}

class CategoriesNames {
  static final String _carpenter = "Carpenter";
  static final String _plumbing = "Plumbing";
  static final String _blacksmith = "Blacksmith";
  static final String _electrical = "Electrical";
  static final String _painter = "Painter";
  static final String _aluminum = "Aluminum";
  static final String _marble = "Marble";
  static final String _upholsterer = "Upholsterer";

  // Getters to access the private variables with modified formatting
  static String get carpenter => _carpenter.replaceAll(' ', '\n');
  static String get plumbing => _plumbing.replaceAll(' ', '\n');
  static String get blacksmith => _blacksmith.replaceAll(' ', '\n');
  static String get electrical => _electrical.replaceAll(' ', '\n');
  static String get painter => _painter.replaceAll(' ', '\n');
  static String get aluminum => _aluminum.replaceAll(' ', '\n');
  static String get marble => _marble.replaceAll(' ', '\n');
  static String get upholsterer => _upholsterer.replaceAll(' ', '\n');
}
