import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/client_screens/client_home.dart';
import 'package:grad_project/client_screens/client_profile.dart';
import 'package:grad_project/main.dart';
import 'all_requests_client.dart';

class MasterPageClient extends StatefulWidget {
  const MasterPageClient({super.key});

  @override
  _MasterPageClientState createState() => _MasterPageClientState();
}

class _MasterPageClientState extends State<MasterPageClient> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ClientHome(),
    const ClientProfile(),
    const AllRequestsClient(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeIn(
        duration: const Duration(milliseconds: 800),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 0.9),
            // borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.3),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.85),
                // borderRadius:
                //     const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(86, 171, 148, 0.9),
                      Color.fromRGBO(83, 99, 108, 0.9),
                    ],
                  ),
                  // borderRadius:
                  //     const BorderRadius.vertical(top: Radius.circular(20)),
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
                  selectedItemColor: Color.fromRGBO(
                      255, 61, 0, 0.9), // Vibrant orange for selected items
                  unselectedItemColor: Color.fromRGBO(
                      255, 255, 255, 0.7), // Softer white for unselected
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
                        tween: Tween<double>(
                            begin: 1.0, end: _selectedIndex == 0 ? 1.2 : 1.0),
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
                        tween: Tween<double>(
                            begin: 1.0, end: _selectedIndex == 1 ? 1.2 : 1.0),
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
                        tween: Tween<double>(
                            begin: 1.0, end: _selectedIndex == 2 ? 1.2 : 1.0),
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
              ))),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

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
      child: Center(
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
              'Search Coming Soon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'Nunito',
                letterSpacing: 0.5,
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
    );
  }
}
