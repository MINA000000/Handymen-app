import 'package:flutter/material.dart';
import 'package:grad_project/Providers/requests_provider_handyman.dart';
import 'package:provider/provider.dart';

import '../components/collections.dart';

class AllRequestsHandyman extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final requestsProvider = Provider.of<RequestsProviderHandyman>(context);
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
        body: requestsProvider.isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.black))
            : requestsProvider.requests.isEmpty
                ? Center(child: Text('There is no requests yet'))
                : Column(
                    children: [
                      Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildSectionTitle('Approved'),
                              Column(
                                children: requestsProvider.approved.map((doc) {
                                  var data = doc.data() as Map<String, dynamic>;
                                  return _buildRequestCard(
                                      data[RequestFieldsName.category],
                                      data[RequestFieldsName.request],
                                      data[RequestFieldsName.assignedHandymanName]);
                                }).toList(),
                              ),
                              _buildSectionTitle('Not Approved'),
                              Column(
                                children:
                                    requestsProvider.notApproved.map((doc) {
                                  var data = doc.data() as Map<String, dynamic>;
                                  return _buildRequestCard(
                                      data[RequestFieldsName.category],
                                      data[RequestFieldsName.request],
                                      data[RequestFieldsName.assignedHandymanName]);
                                }).toList(),
                              ),
                              _buildSectionTitle('Done'),
                              Column(
                                children: requestsProvider.done.map((doc) {
                                  var data = doc.data() as Map<String, dynamic>;
                                  return _buildRequestCard(
                                      data[RequestFieldsName.category],
                                      data[RequestFieldsName.request],
                                      data[RequestFieldsName.assignedHandymanName]);
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
