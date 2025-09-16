import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formula Sheets',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FormulaSheetScreen(),
    );
  }
}

class FormulaSheetScreen extends StatelessWidget {
  const FormulaSheetScreen({super.key});

  final List<Map<String, String>> formulaSheets = const [
    {
      'subject': 'Mathematics 1',
      'image': 'assets/mathematics.png',
      'pdf': 'assets/pdf/Algebra_formula_set.pdf'
    },
    {
      'subject': 'Mathematics 2',
      'image': 'assets/mathematics.png',
      'pdf': 'assets/pdf/geometry_formula_set.pdf'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D56CF),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Formula Sheets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: formulaSheets.length,
          itemBuilder: (context, index) {
            final sheet = formulaSheets[index];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () async {
                    String pdfPath = await _loadPdfFromAssets(sheet['pdf']!);
                    if (pdfPath.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFViewer(pdfPath: pdfPath),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to load PDF')),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Image.asset(
                          sheet['image']!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sheet['subject']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to View PDF',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.picture_as_pdf,
                                size: 24, color: Colors.redAccent),
                          ],
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
    );
  }

  Future<String> _loadPdfFromAssets(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File('${tempDir.path}/${assetPath.split('/').last}');
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      return file.path;
    } catch (e) {
      debugPrint("Error loading PDF: $e");
      return "";
    }
  }
}

class PDFViewer extends StatelessWidget {
  final String pdfPath;
  const PDFViewer({super.key, required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: pdfPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
