import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/handyman_screens/all_requests_handyman.dart';
import 'handyman_home.dart';
import 'handyman_profile.dart';
import 'search_page.dart';

class MasterPageHandyman extends StatefulWidget {
  const MasterPageHandyman({super.key});

  @override
  _MasterPageHandymanState createState() => _MasterPageHandymanState();
}

class _MasterPageHandymanState extends State<MasterPageHandyman> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HandymanHome(),
     HandymanProfile(),
     SearchPage(),
     AllRequestsHandyman(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        // appBar: AppBar(
        //   title: const Text(
        //     'Master Page',
        //     style: TextStyle(
        //       color: Colors.white,
        //       fontSize: 24,
        //       fontWeight: FontWeight.bold,
        //       fontFamily: 'Nunito',
        //     ),
        //   ),
        //   centerTitle: true,
        //   flexibleSpace: Container(
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         colors: [Colors.greenAccent, Colors.blueGrey],
        //         begin: Alignment.topLeft,
        //         end: Alignment.bottomRight,
        //       ),
        //       borderRadius: const BorderRadius.vertical(
        //         bottom: Radius.circular(30),
        //       ),
        //     ),
        //   ),
        //   shape: const RoundedRectangleBorder(
        //     borderRadius: BorderRadius.vertical(
        //       bottom: Radius.circular(30),
        //     ),
        //   ),
        //   elevation: 10,
        //   actions: [
        //     IconButton(
        //       onPressed: () async {
        //         await FirebaseAuth.instance.signOut();
        //         Navigator.pushAndRemoveUntil(
        //           context,
        //           MaterialPageRoute(builder: (_) => ChooseScreen()),
        //           (route) => false,
        //         );
        //       },
        //       icon: const Icon(Icons.exit_to_app, color: Colors.white),
        //     ),
        //   ],
        // ),
        body: FadeIn(
          duration: const Duration(milliseconds: 800),
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(86, 171, 148, 0.9),
                Color.fromRGBO(83, 99, 108, 0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.3),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            selectedItemColor: Color.fromRGBO(255, 61, 0, 0.9),
            unselectedItemColor: Color.fromRGBO(255, 255, 255, 0.7),
            selectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w400,
            ),
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 1.0, end: _selectedIndex == 0 ? 1.2 : 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Icon(
                        Icons.home,
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                    );
                  },
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 1.0, end: _selectedIndex == 1 ? 1.2 : 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Icon(
                        Icons.person,
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                    );
                  },
                ),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 1.0, end: _selectedIndex == 2 ? 1.2 : 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Icon(
                        Icons.search,
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                    );
                  },
                ),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 1.0, end: _selectedIndex == 3 ? 1.2 : 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Icon(
                        Icons.insert_drive_file,
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                    );
                  },
                ),
                label: 'Requests',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

