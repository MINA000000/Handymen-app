import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
class ChatPage extends StatefulWidget {
  final String email;

  const ChatPage({required this.email, Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _message = TextEditingController();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null) return;

      // setState(() => _isUploading = true);

      PlatformFile file = result.files.first;
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef = FirebaseStorage.instance.ref().child('chat_images/$fileName');
      await storageRef.putFile(File(file.path!));
      final String downloadURL = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('messages').add({
        'message': downloadURL,
        'sender': FirebaseAuth.instance.currentUser!.email,
        'receiver': widget.email,
        'time': FieldValue.serverTimestamp(),
        'isImage': true,
      });

      // setState(() => _isUploading = false);
    } catch (e) {
      // setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to upload image")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF56AB94), Color(0xFF2E3B4E)],
          stops: [0.0, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Text(
              'Chat',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                letterSpacing: 1.2,
              ),
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where(Filter.or(
                      Filter.and(
                        Filter('sender', isEqualTo: FirebaseAuth.instance.currentUser!.email),
                        Filter('receiver', isEqualTo: widget.email),
                      ),
                      Filter.and(
                        Filter('sender', isEqualTo: widget.email),
                        Filter('receiver', isEqualTo: FirebaseAuth.instance.currentUser!.email),
                      ),
                    ))
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: FadeIn(
                        duration: const Duration(milliseconds: 800),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.chat_bubble_outline_rounded, color: Colors.white70, size: 60),
                            SizedBox(height: 16),
                            Text(
                              'No Messages Yet',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  var messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      final bool isImage = message['isImage'] ?? false;
                      final isSender = message['sender'] == FirebaseAuth.instance.currentUser!.email;

                      return FadeInUp(
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        child: Align(
                          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSender
                                  ? Colors.greenAccent.withOpacity(0.3)
                                  : Colors.blueAccent.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FullScreenImageView(imageUrl: message['message']),
                                          ),
                                        );
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: message['message'],
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white70,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => const Icon(
                                          Icons.error_outline,
                                          color: Colors.white70,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message['message'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        message['time'] != null
                                            ? message['time'].toDate().toString().substring(0, 16)
                                            : 'Sending...',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white54,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_isUploading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
                    SizedBox(width: 12),
                    Text(
                      'Uploading image...',
                      style: TextStyle(color: Colors.white70, fontFamily: 'Nunito'),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _message,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: const TextStyle(
                            color: Colors.black54,
                            fontFamily: 'Nunito',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      if (_message.text.trim().isEmpty) return;
                      try {
                        await FirebaseFirestore.instance.collection('messages').add({
                          'message': _message.text.trim(),
                          'sender': FirebaseAuth.instance.currentUser!.email,
                          'receiver': widget.email,
                          'time': FieldValue.serverTimestamp(),
                          'isImage': false,
                        });
                        _message.clear();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to send message')),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    iconSize: 28,
                    tooltip: 'Send',
                  ),
                  ImageUploadButton(receiverEmail: widget.email),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ImageUploadButton extends StatefulWidget {
  final String receiverEmail;

  const ImageUploadButton({required this.receiverEmail, Key? key}) : super(key: key);

  @override
  State<ImageUploadButton> createState() => _ImageUploadButtonState();
}

class _ImageUploadButtonState extends State<ImageUploadButton> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null) return;

      setState(() => _isUploading = true);

      PlatformFile file = result.files.first;
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef = FirebaseStorage.instance.ref().child('chat_images/$fileName');
      await storageRef.putFile(File(file.path!));
      final String downloadURL = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('messages').add({
        'message': downloadURL,
        'sender': FirebaseAuth.instance.currentUser!.email,
        'receiver': widget.receiverEmail,
        'time': FieldValue.serverTimestamp(),
        'isImage': true,
      });

      setState(() => _isUploading = false);
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to upload image")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isUploading
        ? const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
          )
        : IconButton(
            onPressed: _pickAndUploadImage,
            icon: const Icon(Icons.attach_file_rounded, color: Colors.white),
            iconSize: 28,
            tooltip: 'Attach Image',
          );
  }
}


class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}