import 'package:flutter/material.dart';
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
  // int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.71, -0.71),
            end: Alignment(-0.71, 0.71),
            colors: [Color(0xFF56AB94), Color(0xFF53636C)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              'All Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cards per row
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to Category Page with arguments
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
                        color: const Color.fromARGB(237, 255, 255, 255),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            categories[index]['image']!,
                            width: 60,
                            height: 60,
                          ),
                          const SizedBox(height: 8, width: 8),
                          Text(
                            categories[index]['name']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
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