import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class ApiServiceOpenai {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5000/extract_skills',  // Change to your Flask server IP
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // 🔹 GET: Fetch implicit skills for a handyman
  Future<String> fetchImplicitSkills(String uid) async {
    try {
      Response response = await _dio.post(
        "/extract_skills", // Ensure correct endpoint
        data: {"handyman_uid": uid}, // JSON body
        options: Options(
          headers: {"Content-Type": "application/json"}, // Explicit JSON content type
        ),
      );

      return response.data['implicit_skills'].toString();
    } catch (e) {
      return "Error fetching implicit skills: $e";
    }
  }
}

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ApiTestScreen(),
    );
  }
}

class ApiTestScreen extends StatefulWidget {
  @override
  _ApiTestScreenState createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ApiServiceOpenai _apiService = ApiServiceOpenai();
  String _result = "";

  Future<void> _fetchSkills(String uid) async {
    if (uid.isNotEmpty) {
      String response = await _apiService.fetchImplicitSkills(uid);
      print(response);
      setState(() {
        _result = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("API Service Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                _fetchSkills("KyEHIVDtbnNr073mxOdpRy3ng7a2");
              },
              child: Text("Fetch Implicit Skills"),
            ),
            SizedBox(height: 20),
            Text("Result:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
