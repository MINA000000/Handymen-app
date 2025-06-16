import 'package:flutter/material.dart';
import 'request_screen.dart';

// import 'list_of_handymen.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  final String categoryImage;

  const CategoryScreen({
    super.key,
    required this.categoryName,
    required this.categoryImage,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
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
            // Top Bar with Back Arrow, Title, and Settings Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(
                    widget.categoryName, // Dynamically show category name
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const Icon(Icons.settings, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // Centered Category Image with Border
            Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 0, 0, 0), width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Image.asset(
                  widget.categoryImage, // Dynamically show category image
                  width: 220,
                  height: 220,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Request Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RequestScreen(categoryName: widget.categoryName,),
                  ),
                );
                // Request button functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3D00),
                padding:
                const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Request',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
