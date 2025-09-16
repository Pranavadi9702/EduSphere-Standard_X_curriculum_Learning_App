import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final List<types.Message> _messages = [];
  final List<String> _conversationHistory = [];
  final _user = const types.User(id: 'user');
  final _bot = const types.User(id: 'bot');
  bool _isTyping = false;

  final String _apiKey =
      'AIzaSyAgumtLCvV2RYFDWVQJBG4pTIwkpvPg8tA'; // Replace with actual API key

  final Map<String, String> predefinedResponses = {
    "hi": "Hello! How can I help you today?",
    "hello": "Hey there! Ask me anything related to Class 10th subjects.",
    "bye": "Goodbye! Have a great day!",
    "thanks": "You're welcome! 😊"
  };

  @override
  void initState() {
    super.initState();
    _addDefaultMessage();
    _flutterTts.setLanguage("en-US");
  }

  void _addDefaultMessage() {
    _addBotMessage(
        'Hello! I am Scooby, your study companion. Ask me anything about Science, Math, History, Geography, or Grammar!');
  }

  void _addTypingIndicator() {
    setState(() {
      _isTyping = true;
      _messages.insert(
        0,
        types.TextMessage(
          author: _bot,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: "typing_indicator",
          text: "Scooby is typing...",
        ),
      );
    });
  }

  void _removeTypingIndicator() {
    setState(() {
      _isTyping = false;
      _messages.removeWhere(
          (msg) => msg is types.TextMessage && msg.id == "typing_indicator");
    });
  }

  void _addBotMessage(String text) {
    _removeTypingIndicator();

    final botMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: text,
    );

    setState(() {
      _messages.insert(0, botMessage);
      _conversationHistory.insert(0, text);
      if (_conversationHistory.length > 5) {
        _conversationHistory.removeLast();
      }
    });
  }

  Future<void> _sendMessage(types.PartialText message) async {
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, userMessage);
    });

    _addTypingIndicator();

    String lowerText = message.text.toLowerCase().trim();

    if (predefinedResponses.containsKey(lowerText)) {
      await Future.delayed(const Duration(seconds: 1));
      _addBotMessage(predefinedResponses[lowerText]!);
      return;
    }

    if (lowerText.contains("idiot") || lowerText.contains("stupid")) {
      await Future.delayed(const Duration(seconds: 1));
      _addBotMessage(
          "Please be respectful. I'm here to help you with your studies.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {
                  "text":
                      "You are a chatbot strictly limited to SSC Standard 10th class subjects (Science, Math, History, Geography, Grammar, English, Marathi, Hindi, Sanskrit). Do not answer questions outside this scope. If a question is outside this curriculum, respond with 'I'm sorry, but I can only assist with SSC 10th class subjects.'"
                }
              ]
            },
            {
              "role": "user",
              "parts": [
                {"text": message.text}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        String botReply =
            responseBody['candidates'][0]['content']['parts'][0]['text'];

        botReply = _formatResponseInPoints(botReply);
        _addBotMessage(botReply);
      } else {
        _showErrorMessage("Error: ${response.body}");
      }
    } catch (e) {
      _showErrorMessage("Oops! Something went wrong. Please try again.");
    }
  }

  String _formatResponseInPoints(String response) {
    List<String> lines = response.split('\n');
    List<String> formattedLines = [];
    bool containsMultiplePoints = lines.length > 2;

    for (String line in lines) {
      if (line.trim().isNotEmpty) {
        if (line.contains(':') || line.trim().length < 50) {
          formattedLines.add(line.trim());
        } else if (containsMultiplePoints) {
          formattedLines.add('- ${line.trim()}');
        } else {
          formattedLines.add(line.trim());
        }
      }
    }

    return formattedLines.join('\n');
  }

  void _showErrorMessage(String errorMessage) {
    _addBotMessage(errorMessage);
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'EduSphereChatbot',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1D56CF),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Chat(
                messages: _messages,
                onSendPressed: _sendMessage,
                user: _user,
                showUserAvatars: false,
                showUserNames: false,
                theme: DefaultChatTheme(
                  primaryColor: Colors.white,
                  backgroundColor: Colors.white,
                  inputBackgroundColor: Colors.grey.shade200,
                  inputTextColor: Colors.black,
                  sentMessageBodyTextStyle:
                      const TextStyle(color: Colors.black87, fontSize: 16),
                  receivedMessageBodyTextStyle:
                      const TextStyle(color: Colors.white, fontSize: 16),
                ),
                textMessageBuilder: (message,
                    {required int messageWidth, required bool showName}) {
                  bool isBotMessage = message.author.id == _bot.id;
                  bool isTypingMessage = message.text == "Scooby is typing...";

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isTypingMessage && _isTyping)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SpinKitWave(
                                color: Colors.grey.shade700,
                                size: 8.0,
                                itemCount: 3, // Only three dots
                                type: SpinKitWaveType
                                    .center, // Ensures dots move in a wave effect
                                duration: const Duration(
                                    milliseconds: 900), // Smooth wave motion
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Scooby is typing...',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isBotMessage
                                ? Color(0xFF1D56CF)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: isBotMessage ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      if (isBotMessage && !isTypingMessage)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              iconSize: 18,
                              icon: const Icon(Icons.copy,
                                  color: Color(0xFF1D56CF)),
                              onPressed: () => _copyText(message.text),
                            ),
                            IconButton(
                              iconSize: 18,
                              icon: const Icon(Icons.volume_up,
                                  color: Color(0xFF1D56CF)),
                              onPressed: () => _flutterTts.speak(message.text),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  final bool isTyping;
  final TextStyle textStyle;

  const TypingIndicator({
    super.key,
    required this.isTyping,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70, // Set the background color to white
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            'Scooby is typing...',
            textStyle: textStyle,
            speed: const Duration(milliseconds: 100),
          ),
        ],
        isRepeatingAnimation: isTyping,
        totalRepeatCount: isTyping ? 1 : 0,
      ),
    );
  }
}
