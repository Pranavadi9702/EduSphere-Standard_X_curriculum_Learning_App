import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class MapSelectionScreen extends StatelessWidget {
  const MapSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1D56CF), // Custom color for AppBar
        elevation: 0, // No elevation for a flat look
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white), // White back arrow for contrast
          onPressed: () => Navigator.pop(context), // Go back on press
        ),
        title: const Text(
          "Select Map",
          style: TextStyle(
            color: Colors.white, // White text for better contrast
            fontSize: 24, // Slightly larger font for prominence
            fontWeight: FontWeight.bold, // Bold to emphasize title
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMapButton(
                  context,
                  "India Map",
                  "http://192.168.67.223:5002/",
                  Colors.blue,
                  Colors.blueAccent),
              _buildMapButton(
                  context,
                  "Brazil Map",
                  "http://192.168.67.223:5003/",
                  Colors.green,
                  Colors.lightGreen),
            ],
          ),
        ],
      ),
    );
  }

  /// **Custom Styled Button with Animation**
  Widget _buildMapButton(BuildContext context, String title, String url,
      Color color1, Color color2) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(_createPageRoute(MapScreen(url: url)));
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: color1.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(3, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// **Custom Fade-In Page Transition**
  PageRouteBuilder _createPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

/// **MapScreen - Opens in Full Screen**
class MapScreen extends StatefulWidget {
  final String url;
  const MapScreen({super.key, required this.url});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final WebViewController _controller;
  String? _htmlContent;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _fetchHtml(widget.url);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _fetchHtml(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _htmlContent = _wrapHtml(response.body);
          _isLoading = false;
        });

        if (_htmlContent != null) {
          _controller.loadHtmlString(_htmlContent!);
        }
      } else {
        throw Exception("Failed to load map");
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  /// **Wrap HTML to Fit Full Screen**
  String _wrapHtml(String body) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <style>
        html, body {
          margin: 0;
          padding: 0;
          height: 100%;
          width: 100%;
          overflow: hidden;
        }
        #map {
          position: absolute;
          top: 0;
          left: 0;
          width: 100vw;
          height: 100vh;
        }
      </style>
    </head>
    <body>
      <div id="map">$body</div>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_hasError)
            const Center(child: Text("Error loading map"))
          else
            SizedBox.expand(
              child: WebViewWidget(controller: _controller),
            ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
