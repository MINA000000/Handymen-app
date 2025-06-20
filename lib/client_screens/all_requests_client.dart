import 'package:flutter/material.dart';
import 'package:grad_project/Providers/requests_provider_client.dart';
import 'package:grad_project/client_screens/approved_request_client.dart';
import 'package:grad_project/client_screens/done_request_client.dart';
import 'package:grad_project/client_screens/not_approved_request.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../components/collections.dart';

class AllRequestsClient extends StatelessWidget {
  const AllRequestsClient({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final requestsProvider = Provider.of<RequestsProviderClient>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF56AB94),
            Color(0xFF2E3B4E),
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context),
        body: requestsProvider.isLoading
            ? _buildLoadingState()
            : requestsProvider.requests.isEmpty
                ? _buildEmptyState()
                : _buildRequestList(context, requestsProvider),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: FadeInDown(
        duration: const Duration(milliseconds: 600),
        child: const Text(
          'My Requests',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            letterSpacing: 1.2,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications feature coming soon!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.notifications_outlined),
          color: Colors.white70,
          iconSize: 28,
          tooltip: 'Notifications',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
        backgroundColor: Colors.white24,
        strokeWidth: 5,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              color: Colors.white70,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'No Requests Yet',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 24,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a new request to get started!',
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

  Widget _buildRequestList(BuildContext context, RequestsProviderClient requestsProvider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequestSection(
            context: context,
            title: 'Approved Requests',
            requests: requestsProvider.approved,
            cardColor: Colors.greenAccent.withOpacity(0.15),
            onTap: (doc) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ApprovedRequestClient(request: doc),
              ),
            ),
          ),
          _buildRequestSection(
            context: context,
            title: 'Pending Requests',
            requests: requestsProvider.notApproved,
            cardColor: Colors.orangeAccent.withOpacity(0.15),
            onTap: (doc) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotApprovedRequest(request: doc),
              ),
            ),
          ),
          _buildRequestSection(
            context: context,
            title: 'Completed Requests',
            requests: requestsProvider.done,
            cardColor: Colors.blueAccent.withOpacity(0.15),
            onTap: (doc) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoneRequestClient(request: doc),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRequestSection({
    required BuildContext context,
    required String title,
    required List<dynamic> requests,
    required Color cardColor,
    required Function(dynamic) onTap,
  }) {
    if (requests.isEmpty) return const SizedBox.shrink();

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...requests.asMap().entries.map((entry) {
            final index = entry.key;
            final doc = entry.value;
            return FadeInUp(
              duration: Duration(milliseconds: 600 + (index * 100)),
              child: _buildRequestCard(doc, context, cardColor, onTap),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    dynamic doc,
    BuildContext context,
    Color cardColor,
    Function(dynamic) onTap,
  ) {
    var data = doc.data() as Map<String, dynamic>;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardColor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              data[RequestFieldsName.category] ?? 'No Category',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Nunito',
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  data[RequestFieldsName.request] ?? 'No Request',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontFamily: 'Nunito',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  'Assigned to: ${data[RequestFieldsName.assignedHandymanName] ?? 'Unassigned'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 20,
            ),
            onTap: () => onTap(doc),
          ),
        ),
      ),
    );
  }
}