import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserScreen(),
    );
  }
}

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  List<Map<String, dynamic>> users = [];

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:5000", // Change for physical device
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Function to add a user
  Future<void> _addUser() async {
    String name = _nameController.text;
    int age = int.tryParse(_ageController.text) ?? 0;

    if (name.isNotEmpty && age > 0) {
      try {
        var response = await _dio.post(
          "/add_user",
          data: {"name": name, "age": age},
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User added successfully!")),
          );
          _fetchUsers();
        }
      } catch (e) {
        print("Error adding user: $e");
      }
    }
  }

  // Function to fetch users
  Future<void> _fetchUsers() async {
    try {
      var response = await _dio.get("/get_users");
      if (response.statusCode == 200) {
        setState(() {
          users = List<Map<String, dynamic>>.from(response.data["users"]);
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Manager")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Age"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text("Add User"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(users[index]["name"]),
                    subtitle: Text("Age: ${users[index]["age"]}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}