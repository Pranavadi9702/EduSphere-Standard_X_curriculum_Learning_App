// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.white, // Keeping background white
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D56CF), // Bright Orange Red
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Help & Support",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("FAQs:", screenWidth),
              _buildFAQTile(
                  "Account",
                  [
                    {
                      "question": "How do I reset my password?",
                      "answer": "Go to settings and click on 'Reset Password'."
                    },
                    {
                      "question": "How can I update my profile details?",
                      "answer":
                          "Navigate to profile settings and edit your details."
                    },
                    {
                      "question":
                          "What should I do if I forget my login credentials?",
                      "answer":
                          "Use the 'Forgot Password' option on the login page."
                    }
                  ],
                  screenWidth),
              _buildFAQTile(
                  "Payment",
                  [
                    {
                      "question": "What payment methods are accepted?",
                      "answer": "We accept credit/debit cards, PayPal, and UPI."
                    },
                    {
                      "question": "How can I get a refund?",
                      "answer":
                          "Request a refund via the 'Payments' section in settings."
                    },
                    {
                      "question": "Is my payment information secure?",
                      "answer":
                          "Yes, all transactions are secured using encryption technology."
                    }
                  ],
                  screenWidth),
              _buildFAQTile(
                  "Course",
                  [
                    {
                      "question": "How do I enroll in a course?",
                      "answer":
                          "Click on the 'Enroll' button on the course page."
                    },
                    {
                      "question": "Can I access my courses offline?",
                      "answer":
                          "Yes, you can download lessons for offline access."
                    },
                    {
                      "question":
                          "Are there any prerequisites for the courses?",
                      "answer":
                          "Check the course details for any prerequisites."
                    }
                  ],
                  screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Padding(
      padding:
          EdgeInsets.only(top: screenWidth * 0.02, bottom: screenWidth * 0.025),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.05,
        ),
      ),
    );
  }

  Widget _buildFAQTile(
      String title, List<Map<String, String>> faqs, double screenWidth) {
    return Column(
      children: faqs.map((faq) {
        return Card(
          color: Colors.grey.shade200, // Lighter Vanilla shade
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent, // Remove black divider
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              title: Text(
                faq["question"]!,
                style: TextStyle(
                  color: Colors.black, // Keeping text black for contrast
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.045,
                ),
              ),
              iconColor: const Color(0xFF1D56CF), // Bright Orange Red icon
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Text(
                    faq["answer"]!,
                    style: TextStyle(
                        color: Colors.black87, // Darker text for readability
                        fontSize: screenWidth * 0.04),
                  ),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
