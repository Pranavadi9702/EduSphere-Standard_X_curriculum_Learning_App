import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'result_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class QuizPage extends StatefulWidget {
  final String board;
  final String subject;
  final String chapter;

  const QuizPage({
    super.key,
    required this.board,
    required this.subject,
    required this.chapter,
  });

  @override
  QuizPageState createState() => QuizPageState();
}

class QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  double progress = 0.0;
  int? selectedOptionIndex;
  List<String> userAnswers = [];
  String? chapterTitle;

  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadChapterTitle();
    loadQuestions();
    _initializeTts();
  }

  Future<void> _loadChapterTitle() async {
    try {
      DocumentSnapshot chapterSnapshot = await FirebaseFirestore.instance
          .collection('boards')
          .doc(widget.board)
          .collection('subjects')
          .doc(widget.subject)
          .collection('chapters')
          .doc(widget.chapter)
          .get();

      if (chapterSnapshot.exists) {
        setState(() {
          chapterTitle = chapterSnapshot["title"] ?? "Chapter Quiz";
        });
      } else {
        setState(() {
          chapterTitle = "Chapter Quiz";
        });
      }
    } catch (e) {
      debugPrint("Error fetching chapter title: $e");
      setState(() {
        chapterTitle = "Chapter Quiz";
      });
    }
  }

  // Initialize TTS settings
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // Function to speak a given text
  Future<void> _speakText(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> loadQuestions() async {
    try {
      QuerySnapshot quizSnapshot = await FirebaseFirestore.instance
          .collection('boards')
          .doc(widget.board)
          .collection('subjects')
          .doc(widget.subject)
          .collection('chapters')
          .doc(widget.chapter)
          .collection('quiz')
          .get();

      List<Map<String, dynamic>> loadedQuestions = [];

      for (var doc in quizSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey("question") &&
            data.containsKey("option1") &&
            data.containsKey("option2") &&
            data.containsKey("option3") &&
            data.containsKey("option4") &&
            data.containsKey("correct_answer")) {
          List<String> options = [
            data["option1"],
            data["option2"],
            data["option3"],
            data["option4"]
          ];
          String correctAnswer = data["correct_answer"];
          options.shuffle(); // Randomize order of options

          loadedQuestions.add({
            "question": data["question"],
            "options": options,
            "correctAnswer": correctAnswer,
          });
        }
      }

      if (loadedQuestions.isEmpty) {
        throw Exception("No valid questions found in Firestore.");
      }

      loadedQuestions.shuffle(); // Shuffle questions
      setState(() {
        questions =
            loadedQuestions.take(7).toList(); // Select 7 random questions
      });
    } catch (e) {
      debugPrint("Error fetching questions: $e");
      setState(() {
        questions = [];
      });
    }
  }

  void selectOption(int index) {
    setState(() {
      selectedOptionIndex = index;
    });
  }

  void nextQuestion() {
    if (selectedOptionIndex != null) {
      userAnswers.add(
          questions[currentQuestionIndex]["options"][selectedOptionIndex!]);
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        progress = (currentQuestionIndex + 1) / questions.length;
        selectedOptionIndex = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) =>
              ResultsScreen(
            subject: widget.subject,
            quizTitle: chapterTitle ?? "Quiz Results",
            chosenAnswers: userAnswers,
            correctAnswers:
                questions.map((q) => q["correctAnswer"] as String).toList(),
            questions: questions.map((q) => q["question"] as String).toList(),
            onRestart: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => QuizPage(
                          board: widget.board,
                          chapter: widget.chapter,
                          subject: widget.subject,
                        )),
                (route) => false,
              );
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), // Start from bottom
                end: Offset.zero, // Move to normal position
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut, // Smooth animation
              )),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var questionData = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 10),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF4A90E2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                Text(
                  chapterTitle ?? "Loading...",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        //const SizedBox(height: 20),
                        Text(
                          "Question ${currentQuestionIndex + 1}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, child) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: Colors.grey[300],
                                  color: const Color(0xFF4A90E2),
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Align text left, icon right
                          children: [
                            Expanded(
                              // Ensure question text takes available space
                              child: Text(
                                questionData["question"],
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up,
                                  color: Colors.blue),
                              onPressed: () =>
                                  _speakText(questionData["question"]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(4, (index) {
                          return Row(
                            children: [
                              Expanded(
                                child: OptionButton(
                                  text:
                                      "${String.fromCharCode(97 + index)}) ${questionData['options'][index]}",
                                  isSelected: selectedOptionIndex == index,
                                  onTap: () => selectOption(index),
                                  textColor: Colors.black,
                                  onSpeak: () => _speakText(
                                      questionData['options'][index]),
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
                    color: Colors.white,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedOptionIndex != null
                            ? const Color.fromARGB(255, 77, 145, 223)
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed:
                          selectedOptionIndex != null ? nextQuestion : null,
                      child: const Text(
                        "Next",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Color textColor;
  final VoidCallback onTap;
  final VoidCallback onSpeak; // New parameter for text-to-speech

  const OptionButton({
    super.key,
    required this.text,
    required this.isSelected,
    this.textColor = Colors.black,
    required this.onTap,
    required this.onSpeak, // Accept the speak function
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.blue),
              onPressed: onSpeak, // Call the speak function
            ),
          ],
        ),
      ),
    );
  }
}
