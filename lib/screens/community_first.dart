import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class Message {
  String id;
  String user;
  String text;
  DateTime date;
  String userAvatar;
  String? repliedText;
  bool isCurrentUser;

  Message({
    this.id = '',
    required this.user,
    required this.text,
    required this.date,
    this.userAvatar = '',
    this.repliedText,
    this.isCurrentUser = false,
  });
}

class CommunityChatPage extends StatefulWidget {
  const CommunityChatPage({super.key});

  @override
  _CommunityChatPageState createState() => _CommunityChatPageState();
}

class _CommunityChatPageState extends State<CommunityChatPage> {
  List<Message> messages = [];
  late String currentUserAvatar;
  late String currentUserId;
  late String currentUserName;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Added
  Message? selectedMessage;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _getCurrentUserProfile();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose controller
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _fetchMessages() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('messages')
          .orderBy('date', descending: false)
          .get();

      setState(() {
        messages = snapshot.docs.map((doc) {
          final data = doc.data();
          return Message(
            id: doc.id,
            user: data['user'],
            text: data['text'],
            date: DateTime.parse(data['date']),
            userAvatar: data['userAvatar'] ?? '',
            repliedText: data['repliedText'],
            isCurrentUser: data['user'] == currentUserId,
          );
        }).toList();
      });

      _scrollToBottom(); // Scroll to latest message after loading
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch messages: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    try {
      final collection = FirebaseFirestore.instance.collection('messages');
      final doc = collection.doc();

      DateTime now = DateTime.now();

      await doc.set({
        'user': currentUserName,
        'text': text,
        'date': now.toIso8601String(),
        'userAvatar': currentUserAvatar,
        'repliedText': selectedMessage?.text, // Store replied message
      });

      setState(() {
        messages.add(Message(
          id: doc.id,
          user: currentUserId,
          text: text,
          date: now,
          userAvatar: currentUserAvatar,
          repliedText: selectedMessage?.text,
          isCurrentUser: true,
        ));
        selectedMessage = null; // Clear reply selection
      });

      _messageController.clear();
      _scrollToBottom(); // Scroll to latest message after sending
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send message: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(messageId)
          .delete();

      setState(() {
        messages.removeWhere((message) => message.id == messageId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Message deleted"), backgroundColor: Colors.red),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to delete message: $error"),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _getCurrentUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userPhotoUrl = user.photoURL;
        final userName =
            user.displayName ?? user.email?.split('@')[0] ?? 'User';
        setState(() {
          currentUserAvatar = userPhotoUrl ?? '';
          currentUserId = user.uid;
          currentUserName = userName;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch user profile: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _replyToMessage(Message message) {
    setState(() {
      selectedMessage = message;
    });
  }

  void _cancelReply() {
    setState(() {
      selectedMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D56CF), // Matching theme color
        elevation: 0, // Flat design without shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white), // Updated back icon
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Community Chat",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05, // Dynamic font size
          ),
        ),
        centerTitle: true, // Centering the title
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Add this
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Slidable(
                  key: ValueKey(message.id),
                  startActionPane: ActionPane(
                    motion: StretchMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _replyToMessage(message);
                        },
                        backgroundColor: Color(0xFF1D56CF),
                        foregroundColor: Colors.white,
                        icon: Icons.reply,
                        label: 'Reply',
                      ),
                      if (message.isCurrentUser)
                        SlidableAction(
                          onPressed: (context) {
                            _deleteMessage(message.id);
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: message.isCurrentUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!message.isCurrentUser)
                          CircleAvatar(
                            backgroundImage: message.userAvatar.isNotEmpty
                                ? NetworkImage(message.userAvatar)
                                : null,
                            child: message.userAvatar.isEmpty
                                ? Text(message.user[0].toUpperCase(),
                                    style: TextStyle(color: Color(0xFF1D56CF)))
                                : null,
                          ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: message.isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!message.isCurrentUser)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  message.user,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                            if (message.repliedText != null)
                              Container(
                                margin: EdgeInsets.only(bottom: 4),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Replying to: ${message.repliedText}",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 12),
                                ),
                              ),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: message.isCurrentUser
                                    ? Colors.blue[100]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(message.text,
                                      style: TextStyle(color: Colors.black)),
                                  Text(DateFormat('H:mm').format(message.date),
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedMessage != null)
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Replying to: ${selectedMessage!.text}",
                      style: TextStyle(color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black),
                    onPressed: _cancelReply,
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.black26),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                    }
                  },
                  backgroundColor: Color(0xFF1D56CF),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
