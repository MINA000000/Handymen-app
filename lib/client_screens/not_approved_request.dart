import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/Providers/requests_provider_client.dart';
import 'package:grad_project/client_screens/done_request_client.dart';
import 'package:grad_project/client_screens/handymen_profiles.dart';
import 'package:grad_project/components/image_viewer_screen.dart';
import 'package:provider/provider.dart';

import '../components/collections.dart';

class NotApprovedRequest extends StatelessWidget {
  QueryDocumentSnapshot request;
  NotApprovedRequest({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.71, -0.71),
          end: Alignment(-0.71, 0.71),
          colors: [Color(0xFF56AB94), Color(0xFF53636C)],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Requests',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications),
              color: Colors.white,
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Container(
                  width: 269,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      request[RequestFieldsName.request],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewerScreen(
                          imageUrl: request[RequestFieldsName.imageURL],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    child: Image.network(
                      request[RequestFieldsName.imageURL],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                const SizedBox(height: 30),
                // Send Button
                ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HanymenProfiles(
                          categoryName: request[RequestFieldsName.category],
                          docId: request.id,
                          request: request[RequestFieldsName.request],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3D00),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Send to handyman',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // ElevatedButton(
                //   onPressed: () async {},
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: const Color(0xFFFF3D00),
                //     padding: const EdgeInsets.symmetric(
                //         horizontal: 40, vertical: 12),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //   ),
                //   child: const Text(
                //     'handymen you send to',
                //     style: TextStyle(
                //       fontSize: 20,
                //       fontWeight: FontWeight.bold,
                //       fontFamily: 'Nunito',
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // Helper method to build request cards
  Widget _buildRequestCard(
      String category, String content, String handymanName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(
            'Category : $category',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request : $content'),
              Divider(),
              Text('Assigned to: $handymanName'),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
