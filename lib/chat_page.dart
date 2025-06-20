import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ChatPage extends StatelessWidget {
  final String email;
  final TextEditingController _message = TextEditingController();

  ChatPage({required this.email});


  Future<void> _pickAndUploadImage(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result == null) return;

      PlatformFile file = result.files.first;
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef =
      FirebaseStorage.instance.ref().child('chat_images/$fileName');
      await storageRef.putFile(File(file.path!));

      final String downloadURL = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('messages').add({
        'message': downloadURL,
        'sender': FirebaseAuth.instance.currentUser!.email,
        'receiver': email,
        'time': FieldValue.serverTimestamp(),
        'isImage': true,
      });
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with $email")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where(Filter.or(
                  Filter.and(
                    Filter('sender', isEqualTo: FirebaseAuth.instance.currentUser!.email),
                    Filter('receiver', isEqualTo: email),
                  ),
                  Filter.and(
                    Filter('sender', isEqualTo: email),
                    Filter('receiver', isEqualTo: FirebaseAuth.instance.currentUser!.email),
                  ),
                ))
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No messages yet."));
                  }

                  var messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      final bool isImage = message['isImage'] ?? false;

                      return Align(
                        alignment: message['sender'] == FirebaseAuth.instance.currentUser!.email
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: message['sender'] == FirebaseAuth.instance.currentUser!.email
                                ? Colors.blue[300]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: isImage
                              ? Image.network(
                            message['message'],
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['message'],
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                message['time'] != null
                                    ? message['time'].toDate().toString()
                                    : "Sending...",
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Message Input Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _message,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (_message.text.trim().isEmpty) return;
                    try {
                      await FirebaseFirestore.instance.collection('messages').add({
                        'message': _message.text.trim(),
                        'sender': FirebaseAuth.instance.currentUser!.email,
                        'receiver': email,
                        'time': FieldValue.serverTimestamp(),
                        'isImage': false,
                      });

                      _message.clear();
                    } catch (e) {
                      print("Error sending message: $e");
                    }
                  },
                  icon: Icon(Icons.send, color: Colors.blue),
                ),
                IconButton(
                  onPressed: () => _pickAndUploadImage(context),
                  icon: Icon(Icons.attach_file, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}