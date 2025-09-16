import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultsScreen extends StatelessWidget {
  final String quizTitle;
  final List<String> chosenAnswers;
  final String subject;
  final List<String> correctAnswers;
  final List<String> questions;
  final VoidCallback onRestart;

  ResultsScreen({
    super.key,
    required this.quizTitle,
    required this.subject,
    required this.chosenAnswers,
    required this.correctAnswers,
    required this.questions,
    required this.onRestart,
  });

  final FlutterTts _flutterTts = FlutterTts();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _fetchUserName() async {
    User? user = _auth.currentUser;
    return user?.displayName ?? "No Name";
  }

  Future<void> _saveResultToFirestore(
      String username, int score, double percentage, String subject) async {
    // Add subject parameter
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection("quiz_results").add({
          "user_id": user.uid,
          "username": username,
          "quiz_title": quizTitle,
          "subject": subject, // Add this line
          "score": score,
          "total_questions": questions.length,
          "percentage": percentage,
          "timestamp": FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Error saving result: $e");
      }
    }
  }

  Future<void> _speakText(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    int correctAnswerCount = 0;
    for (int i = 0; i < chosenAnswers.length; i++) {
      if (chosenAnswers[i] == correctAnswers[i]) {
        correctAnswerCount++;
      }
    }

    double percentage = (correctAnswerCount / questions.length) * 100;

    String feedbackMessage;
    if (percentage <= 30) {
      feedbackMessage = "Great Attempt!";
    } else if (percentage > 30 && percentage <= 60) {
      feedbackMessage = "Good Work!";
    } else if (percentage > 60 && percentage <= 90) {
      feedbackMessage = "Bravo! Keep it up!";
    } else {
      feedbackMessage = "Excellent!";
    }

    if (percentage > 60) {
      _confettiController.play();
    }

    _fetchUserName().then((username) {
      _saveResultToFirestore(username, correctAnswerCount, percentage,
          subject); // Pass subject here
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 60, horizontal: 10),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A90E2),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          quizTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.white),
                      onPressed: () => _speakText(
                          "You have scored $correctAnswerCount questions correctly out of ${questions.length}!"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Quiz Result",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      "You have scored $correctAnswerCount questions correctly out of ${questions.length}!",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      feedbackMessage,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    itemCount: correctAnswers.length,
                    itemBuilder: (context, index) {
                      bool isCorrect =
                          chosenAnswers[index] == correctAnswers[index];
                      Color answerColor = isCorrect ? Colors.green : Colors.red;

                      return Card(
                        color: Colors.grey.shade100,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: answerColor,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      questions[index],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Your Answer: ${chosenAnswers[index]}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: answerColor,
                                      ),
                                    ),
                                    Text(
                                      "Correct Answer: ${correctAnswers[index]}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up,
                                    color: Colors.blue),
                                onPressed: () => _speakText(
                                    "Question: ${questions[index]}. Your Answer: ${chosenAnswers[index]}. Correct Answer: ${correctAnswers[index]}"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: onRestart,
                  child: const Center(
                    child: Text(
                      "Restart Quiz",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
