import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class BookSessionForm extends StatefulWidget {
  @override
  _BookSessionFormState createState() => _BookSessionFormState();
}

class _BookSessionFormState extends State<BookSessionForm> {
  final _formKey = GlobalKey<FormState>();
  String _date = '';
  String _time = '';
  String _subject = '';
  String _comments = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D56CF), // Updated theme color
        title: const Text(
          'Book Session',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter date (e.g., 2025-03-15)',
                ),
                style:
                    TextStyle(color: Colors.black), // Set text color to black
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
                onSaved: (value) {
                  _date = value!;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Select Time',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter time (e.g., 10:00 AM)',
                ),
                style:
                    TextStyle(color: Colors.black), // Set text color to black
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a time';
                  }
                  return null;
                },
                onSaved: (value) {
                  _time = value!;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Subject',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter subject',
                ),
                style:
                    TextStyle(color: Colors.black), // Set text color to black
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
                onSaved: (value) {
                  _subject = value!;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Additional Comments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter any additional comments',
                ),
                style:
                    TextStyle(color: Colors.black), // Set text color to black
                onSaved: (value) {
                  _comments = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Handle form submission
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Session booked for $_date at $_time')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
