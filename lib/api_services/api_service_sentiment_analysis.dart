// import 'package:dio/dio.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// class ApiServiceSentimentAnalysis {
//   final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:5000"));

//   Future<Map<String, dynamic>> sendReview(String review, String handymanUID) async {
//     try {
//       Response response = await _dio.post(
//         "/predict",
//         data: {"review": review, "handyman_uid": handymanUID},
//       );
//       return response.data; // Returns prediction data
//     } catch (e) {
//       return {"error": "Failed to connect to server: $e"};
//     }
//   }
// }


// void main()async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: UserScreen(),
//     );
//   }
// }

// class UserScreen extends StatefulWidget {
//   @override
//   _UserScreenState createState() => _UserScreenState();
// }

// class _UserScreenState extends State<UserScreen> {
//   ApiServiceSentimentAnalysis api = ApiServiceSentimentAnalysis();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("User Manager")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             ElevatedButton(onPressed: ()async{
//               try{
//                 final receiveData = await api.sendReview("this was amazing thank you", "KyEHIVDtbnNr073mxOdpRy3ng7a2");
//                 print(receiveData);
//               }
//               catch(e){
//                 print("error here: $e");
//               }
//             }, child: Text('press'),),
//           ],
//         ),
//       ),
//     );
//   }
// }
