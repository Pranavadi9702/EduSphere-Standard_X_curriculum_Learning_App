import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewer extends StatelessWidget {
  final String pdfPath;

  const PDFViewer({super.key, required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white), // White back arrow
          onPressed: () => Navigator.pop(context), // Go back on press
        ),
        backgroundColor:
            const Color(0xFF1D56CF), // Setting the theme color as specified
        elevation: 0, // No elevation for a flat look
        title: Text(
          'PDF Viewer',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Bold title
            fontSize: 18, // Dynamic font size based on screen width
            color: Colors.white, // White text for better contrast
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: PDFView(
        filePath: pdfPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageSnap: true,
        fitPolicy: FitPolicy.WIDTH,
      ),
    );
  }
}
