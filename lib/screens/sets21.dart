import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class Sets21Screen extends StatelessWidget {
  const Sets21Screen({super.key});

  final List<Map<String, String>> samplePapers = const [
    // {
    //   'year': '2020',
    //   'subject': 'English',
    //   'image': 'assets/english.png',
    //   'pdf': 'assets/pdf/Marathi_Paper.pdf'
    // },
    {
      'year': '2020',
      'subject': 'Mathematics ',
      'image': 'assets/mathematics.png',
      'pdf': 'assets/pdf/Maths_1_Paper.pdf'
    },
    // {
    //   'year': '2020',
    //   'subject': 'Mathematics 2',
    //   'image': 'assets/Maths1.png',
    //   'pdf': 'assets/pdf/Maths_2_Paper.pdf'
    // },
    {
      'year': '2020',
      'subject': 'Science 1',
      'image': 'assets/science.png',
      'pdf': 'assets/pdf/Science_1_Paper.pdf'
    },
    {
      'year': '2020',
      'subject': 'Science 2',
      'image': 'assets/science.png',
      'pdf': 'assets/pdf/Science_2_Paper.pdf'
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
          '21 Sets',
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
          itemCount: samplePapers.length,
          itemBuilder: (context, index) {
            final paper = samplePapers[index];
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
                    String pdfPath = await _loadPdfFromAssets(paper['pdf']!);
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
                          paper['image']!,
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
                                  '${paper['subject']} - ${paper['year']}',
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

  /// Copies a PDF from assets to a temporary directory and returns its path
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

class PDFViewer extends StatefulWidget {
  final String pdfPath;
  const PDFViewer({super.key, required this.pdfPath});

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfPath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
                _isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = error.toString();
              });
              debugPrint(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                _errorMessage = '$page: ${error.toString()}';
              });
              debugPrint('$page: ${error.toString()}');
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page ?? 0;
              });
            },
          ),
          if (!_isReady && _errorMessage.isEmpty)
            const Center(child: CircularProgressIndicator()),
          if (_errorMessage.isNotEmpty) Center(child: Text(_errorMessage)),
        ],
      ),
    );
  }
}
