import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardScreen extends StatefulWidget {
  final String board;
  final String subject;
  final String chapter;

  const FlashcardScreen({
    super.key,
    required this.board,
    required this.subject,
    required this.chapter,
  });

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _showFront = true;
  final FlutterTts _tts = FlutterTts();
  List<Map<String, String>> _flashcards = [];

  @override
  void initState() {
    super.initState();
    _fetchFlashcards();
  }

  Future<void> _fetchFlashcards() async {
    try {
      print(
          "Fetching flashcards from: /boards/${widget.board}/subjects/${widget.subject}/chapters/${widget.chapter}/flashcards");

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('boards')
          .doc(widget.board)
          .collection('subjects')
          .doc(widget.subject)
          .collection('chapters')
          .doc(widget.chapter)
          .collection('flashcards')
          .get();

      print("Flashcards fetched: ${snapshot.docs.length}");

      List<Map<String, String>> fetchedFlashcards = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'front': (data['front'] as String?)?.trim() ?? 'No front text',
          'back': (data['back'] as String?)?.trim() ?? 'No back text',
        };
      }).toList();

      if (mounted) {
        setState(() {
          _flashcards = fetchedFlashcards;
        });
      }

      print("Final Flashcards List: $_flashcards");
    } catch (e) {
      print("Error fetching flashcards: $e");
    }
  }

  void _flipCard() {
    setState(() {
      _showFront = !_showFront;
    });
  }

  void _nextCard() {
    if (_flashcards.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
      _showFront = true;
    });
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    if (_flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Flashcards"),
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final card = _flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Transparent background for gradient
        elevation: 0, // No elevation to allow gradient to show better
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade600, // Deep blue for a fresh look
                Colors
                    .blueAccent, // Lighter blue to complement the deeper shade
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white), // White back arrow for contrast
          onPressed: () => Navigator.pop(context), // Go back on press
        ),
        title: const Text(
          "Flashcards",
          style: TextStyle(
            color: Colors.white, // White text for better contrast
            fontSize: 24, // Slightly larger font for prominence
            fontWeight: FontWeight.bold, // Bold to emphasize title
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.shade100,
              Colors.lightBlueAccent
            ], // Lighter blue and blue accent
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: GestureDetector(
                onTap: _flipCard,
                child: SizedBox(
                  width: 320,
                  height: 220,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      final rotateAnim =
                          Tween(begin: 1.0, end: 0.0).animate(animation);
                      return RotationYTransition(
                          turns: rotateAnim, child: child);
                    },
                    child: Container(
                      key: ValueKey<bool>(_showFront),
                      width: 320,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _showFront ? Colors.white : Colors.orangeAccent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _showFront
                                      ? Icons.question_mark
                                      : Icons.lightbulb,
                                  size: 40,
                                  color: _showFront
                                      ? Colors.blueAccent
                                      : Colors.white,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _showFront ? card['front']! : card['back']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: _showFront
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IconButton(
                              icon: Icon(Icons.volume_up,
                                  color: _showFront
                                      ? Colors.blueAccent
                                      : Colors.white),
                              onPressed: () => _speak(
                                  _showFront ? card['front']! : card['back']!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _nextCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Button color
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // Explicitly setting the text style to ensure the text color is white
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Ensures the text color is white
                ),
              ),
              child: const Text("Next Card",
                  style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
      //bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}

class RotationYTransition extends AnimatedWidget {
  final Widget child;
  final Animation<double> turns;

  const RotationYTransition(
      {super.key, required this.child, required this.turns})
      : super(listenable: turns);

  @override
  Widget build(BuildContext context) {
    final double value = turns.value;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(value * 3.1416),
      child: value > 0.5
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.1416),
              child: child,
            )
          : child,
    );
  }
}
