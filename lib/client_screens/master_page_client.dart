import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/client_screens/client_home.dart';
import 'package:grad_project/client_screens/client_profile.dart';
import '../main.dart';
import 'all_requests_client.dart';

class MasterPageClient extends StatefulWidget {
  @override
  _MasterPageClientState createState() => _MasterPageClientState();
}

class _MasterPageClientState extends State<MasterPageClient> {
  int _selectedIndex = 0; // Track the selected index

  // List of pages corresponding to each navigation item
  final List<Widget> _pages = [
    ClientHome(), // Replace with your home page widget
    ClientProfile(), // Replace with your profile page widget
    // SearchPage(), // Replace with your search page widget
    AllRequestsClient(), // Replace with your requests page widget
  ];

  Widget get bottomNavigationBar {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.blue, // Color for the selected item
      unselectedItemColor: Colors.grey, // Color for unselected items
      selectedLabelStyle: TextStyle(fontSize: 12), // Style for selected label
      unselectedLabelStyle:
          TextStyle(fontSize: 12), // Style for unselected label
      type: BottomNavigationBarType.fixed, // Ensure all items are visible
      currentIndex: _selectedIndex, // Set the current selected index
      onTap: _onItemTapped, // Handle item taps
      items: [
        BottomNavigationBarItem(
          icon:
              Icon(Icons.home, size: MediaQuery.of(context).size.width * 0.06),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person,
              size: MediaQuery.of(context).size.width * 0.06),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_drive_file,
              size: MediaQuery.of(context).size.width * 0.06),
          label: 'Requests',
        ),
      ],
    );
  }

  // Function to handle navigation when an item is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        //     appBar: AppBar(
        //     title: Text(
        //     'Master Page',
        //     style: TextStyle(
        //     color: Colors.white,
        //     fontSize: 24,
        //     fontWeight: FontWeight.bold,
        // ),
        // ),
        // centerTitle: true,
        // flexibleSpace: Container(
        // decoration: BoxDecoration(
        // gradient: LinearGradient(
        // colors: [Colors.greenAccent, Colors.blueGrey],
        // begin: Alignment.topLeft,
        // end: Alignment.bottomRight,
        // ),
        // borderRadius: BorderRadius.vertical(
        // bottom: Radius.circular(30), // Curvy bottom edges
        // ),
        // ),
        // ),
        // shape: RoundedRectangleBorder(
        // borderRadius: BorderRadius.vertical(
        // bottom: Radius.circular(30), // Curvy bottom edges
        // ),),
        // elevation: 10, // Add shadow
        // actions: [
        // IconButton(
        // onPressed: () async {
        // await FirebaseAuth.instance.signOut();
        // Navigator.pushAndRemoveUntil(
        // context,
        // MaterialPageRoute(builder: (_) => ChooseScreen()),
        // (route) => false,
        // );
        // },
        // icon: Icon(Icons.exit_to_app, color: Colors.white),
        // ),
        // ],
        // ),
        body: _pages[_selectedIndex], // Display the selected page
        bottomNavigationBar: bottomNavigationBar);
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      'Search Page',
      style: TextStyle(color: Colors.white),
    ));
  }
}
