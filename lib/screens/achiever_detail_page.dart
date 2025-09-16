import 'package:e_learning_app/screens/book_session_form.dart';
import 'package:flutter/material.dart';

class AchieverDetailPage extends StatefulWidget {
  final Map<String, dynamic> achiever;

  AchieverDetailPage({required this.achiever});

  @override
  _AchieverDetailPageState createState() => _AchieverDetailPageState();
}

class _AchieverDetailPageState extends State<AchieverDetailPage> {
  @override
  Widget build(BuildContext context) {
    final achiever = widget.achiever;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D56CF), // Updated theme color
        title: const Text(
          'Achiever Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18, // Adjust font size if needed
            color: Colors.white, // White text for contrast
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white), // Back button
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true, // Center align the title
        elevation: 0, // Remove shadow if needed
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(achiever["imageUrl"]),
                radius: 60,
              ),
              const SizedBox(height: 16),
              Text(
                achiever["name"],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Score: ${achiever["score"]}",
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                achiever["description"],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookSessionForm(),
                    ),
                  );
                },
                child: const Text(
                  'Book Session',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
