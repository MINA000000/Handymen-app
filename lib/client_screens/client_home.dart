import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:grad_project/components/firebase_methods.dart';
import 'category_screen.dart';

class ClientHome extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {'name': CategoriesNames.carpenter, 'image': 'assets/carpenter.jpeg'},
    {'name': CategoriesNames.painter, 'image': 'assets/painter.jpeg'},
    {'name': CategoriesNames.electrical, 'image': 'assets/electrician.jpeg'},
    {'name': CategoriesNames.plumbing, 'image': 'assets/plumber.jpeg'},
    {'name': CategoriesNames.blacksmith, 'image': 'assets/blacksmith.jpeg'},
    {'name': CategoriesNames.aluminum, 'image': 'assets/aluminumWorker.jpeg'},
    {'name': CategoriesNames.marble, 'image': 'assets/marbleWorker.jpeg'},
    {'name': CategoriesNames.upholsterer, 'image': 'assets/upholsterer.jpeg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(86, 171, 148, 0.95), // Updated from Color(0xFF56AB94)
              Color.fromRGBO(83, 99, 108, 0.95), // Updated from Color(0xFF53636C)
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'All Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
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
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  return FadeInUp(
                    duration: Duration(milliseconds: 600 + (index * 100)),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryScreen(
                              categoryName: categories[index]['name']!,
                              categoryImage: categories[index]['image']!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.95), // Updated from Color.fromARGB
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                categories[index]['image']!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              categories[index]['name']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Nunito',
                                color: Color.fromRGBO(33, 33, 33, 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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