import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/Providers/requests_provider_handyman.dart';
import 'package:grad_project/handyman_screens/approved_request_handyman.dart';
import 'package:provider/provider.dart';
import '../components/collections.dart';

class AllRequestsHandyman extends StatelessWidget {
  const AllRequestsHandyman({super.key});

  @override
  Widget build(BuildContext context) {
    final requestsProvider = Provider.of<RequestsProviderHandyman>(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(86, 171, 148, 0.95),
            Color.fromRGBO(83, 99, 108, 0.95),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(86, 171, 148, 0.95),
            Color.fromRGBO(83, 99, 108, 0.95),
                ],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          title: FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: const Text(
              'All Requests',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
                letterSpacing: 1.0,
              ),
            ),
          ),
          centerTitle: true,
          // leading: Padding(
          //   padding: const EdgeInsets.only(left: 8.0),
          //   child: IconButton(
          //     onPressed: () => Navigator.pop(context),
          //     icon: Container(
          //       padding: const EdgeInsets.all(8),
          //       decoration: BoxDecoration(
          //         color: Color.fromRGBO(255, 255, 255, 0.1),
          //         shape: BoxShape.circle,
          //         boxShadow: [
          //           BoxShadow(
          //             color: Color.fromRGBO(0, 0, 0, 0.15),
          //             blurRadius: 6,
          //             offset: const Offset(0, 2),
          //           ),
          //         ],
          //       ),
          //       child: const Icon(
          //         Icons.arrow_back,
          //         color: Colors.white,
          //         size: 24,
          //       ),
          //     ),
          //     tooltip: 'Back',
          //   ),
          // ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Notifications feature coming soon!',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Color.fromRGBO(33, 150, 243, 0.7),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 1.0 + (value * 0.1),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                        size: 28,
                      ),
                    );
                  },
                ),
                tooltip: 'Notifications',
              ),
            ),
          ],
        ),
        body: requestsProvider.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(255, 255, 255, 0.7),
                ),
              )
            : requestsProvider.requests.isEmpty
                ? Center(
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.1),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'No requests available yet.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Nunito',
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      const Divider(color: Color.fromRGBO(255, 255, 255, 0.3)),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildSection(
                                context,
                                'Approved Requests',
                                requestsProvider.approved,
                                600,
                              ),
                              _buildSection(
                                context,
                                'Not Approved (1)',
                                requestsProvider.clientWant,
                                800,
                              ),
                              _buildSection(
                                context,
                                'Not Approved (2)',
                                requestsProvider.handymanWant,
                                1000,
                              ),
                              _buildSection(
                                context,
                                'Completed Requests',
                                requestsProvider.done,
                                1200,
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<QueryDocumentSnapshot> requests, int baseDelay) {
  if (requests.isEmpty) {
    return const SizedBox.shrink();
  }

  return FadeInUp(
    duration: Duration(milliseconds: baseDelay),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInUp(
          duration: Duration(milliseconds: baseDelay - 100),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.1),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.95),
                  fontSize: 24,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ...requests.asMap().entries.map((entry) {
          final index = entry.key;
          final doc = entry.value;
          final data = doc.data() as Map<String, dynamic>;
          return FadeInUp(
            duration: Duration(milliseconds: baseDelay + (index * 100)),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApprovedRequestHandyman(request: doc),
                ),
              ),
              child: _buildRequestCard(
                data[RequestFieldsName.category] ?? 'No category',
                data[RequestFieldsName.request] ?? 'No details provided',
                data[RequestFieldsName.assignedHandymanName] ?? 'Not assigned',
              ),
            ),
          );
        }),
      ],
    ),
  );
}

  Widget _buildRequestCard(String category, String content, String handymanName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Color.fromRGBO(255, 255, 255, 0.95),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(
              'Category: $category',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color.fromRGBO(33, 33, 33, 0.9),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Request: $content',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    color: Color.fromRGBO(33, 33, 33, 0.7),
                  ),
                ),
                const Divider(color: Color.fromRGBO(0, 0, 0, 0.1)),
                Text(
                  'Assigned to: $handymanName',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    color: Color.fromRGBO(33, 33, 33, 0.7),
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Color.fromRGBO(255, 61, 0, 0.9),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}