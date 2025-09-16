import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF1D56CF), // Custom color for AppBar
        elevation: 0, // No elevation for a flat look
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white), // White back arrow for contrast
          onPressed: () => Navigator.pop(context), // Go back on press
        ),
        title: const Text(
          "Privacy & Policy",
          style: TextStyle(
            color: Colors.white, // White text for better contrast
            fontSize: 24, // Slightly larger font for prominence
            fontWeight: FontWeight.bold, // Bold to emphasize title
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "1. Introduction",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Welcome to our app. This Privacy Policy explains how we collect, use, and protect your personal information when you use our services. By using the app, you consent to the collection and use of information in accordance with this policy.",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              "2. Information Collection",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "We may collect the following types of information:\n\n"
              "- Personal Information: Name, email address, phone number, etc.\n"
              "- Usage Data: IP address, browser type, pages visited, and other usage data.\n"
              "- Location Data: If you enable location services, we may collect your location.",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              "3. How We Use Your Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "We use your information for the following purposes:\n\n"
              "- To improve our services and app experience\n"
              "- To send updates and notifications\n"
              "- To respond to inquiries and support requests\n"
              "- To comply with legal obligations",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              "4. Data Security",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "We take reasonable measures to protect your personal data from unauthorized access, alteration, disclosure, or destruction. However, no method of data transmission or storage is 100% secure, and we cannot guarantee the absolute security of your information.",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              "5. Your Rights",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "You have the following rights regarding your personal data:\n\n"
              "- Access: You can request access to the personal data we hold about you.\n"
              "- Rectification: You can request corrections to any inaccurate data.\n"
              "- Deletion: You can request the deletion of your personal data.\n"
              "- Opt-out: You can opt-out of marketing communications at any time.",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              "6. Changes to This Privacy Policy",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated effective date. We encourage you to review this policy periodically for any updates.",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              "7. Contact Us",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "If you have any questions or concerns about this Privacy Policy or our practices, please contact us at:\n\n"
              "- Email: support@yourapp.com\n"
              "- Address: 1234 Your App St, Your City, Your Country",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
