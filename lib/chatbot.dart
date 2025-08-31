import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

import 'profile.dart';
import 'setting.dart';
import 'about.dart';

class MyApp extends StatefulWidget {
  final String username;
  final String email;

  const MyApp({super.key, required this.username, required this.email});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  String _currentSessionId = "";

  @override
  void initState() {
    super.initState();
    _startNewChat();
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  Future<void> _loadHistory([String? sessionId]) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.email)
          .collection("history")
          .orderBy("timestamp", descending: false)
          .get();

      if (!mounted) return;

      setState(() {
        _messages.clear();
        for (var doc in snapshot.docs) {
          final chat = doc.data();
          final chatSession = chat["sessionId"]?.toString() ?? "";
          if (sessionId != null && chatSession != sessionId) continue;

          final queryText = chat["query"]?.toString() ?? '';
          final responseText = chat["response"]?.toString() ?? '';

          if (queryText.isNotEmpty) {
            _messages.add({"sender": "user", "text": queryText});
          }
          if (responseText.isNotEmpty) {
            _messages.add({"sender": "bot", "text": responseText});
          }
        }
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": userMessage});
    });
    _scrollToBottom();
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": widget.email, "query": userMessage}),
      );

      String botResponse = "No response";
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        botResponse = data["response"]?.toString() ?? botResponse;
      } else {
        botResponse = "Server error: ${response.statusCode}";
      }

      if (!mounted) return;

      setState(() {
        _messages.add({"sender": "bot", "text": botResponse});
      });

      final docRef = FirebaseFirestore.instance
          .collection("users")
          .doc(widget.email)
          .collection("history")
          .doc();
      await docRef.set({
        "sessionId": _currentSessionId,
        "query": userMessage,
        "response": botResponse,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({"sender": "bot", "text": "Error: $e"});
      });
    }

    _scrollToBottom();
  }

  Future<void> _showPastChats() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.email)
          .collection("history")
          .orderBy("timestamp", descending: true)
          .get();

      if (!mounted) return;

      final sessions = snapshot.docs
          .map((doc) => doc.data()["sessionId"]?.toString() ?? "")
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.deepPurple,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Past Chats",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final sessionId = sessions[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 1, 29, 52),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text(
                              "Chat ${index + 1}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              _currentSessionId = sessionId;
                              _loadHistory(sessionId);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Error loading past chats: $e");
    }
  }

  // Helper function to render bot messages with clickable links
  Widget _buildMessageText(String text, bool isUser) {
    if (isUser) {
      return Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      );
    }

    final urlRegex = RegExp(r'https?://[^\s]+');
    List<TextSpan> spans = [];
    int start = 0;

    for (final match in urlRegex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }

      final url = match.group(0);
      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (url != null) {
                final uri = Uri.parse(url);
                if (!await launchUrl(uri,
                    mode: LaunchMode.externalApplication)) {
                  debugPrint('Could not launch $url');
                }
              }
            },
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 16),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 29, 52),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutGenieBot()),
          ),
        ),
        title: const Text(
          'GenieBot',
          style:
              TextStyle(color: Color.fromARGB(255, 82, 244, 54), fontSize: 27),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Past Chats",
            onPressed: _showPastChats,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "New Chat",
            onPressed: _startNewChat,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: const Color.fromARGB(255, 22, 139, 198),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        Profile(username: widget.username, email: widget.email),
                  ),
                );
              } else if (value == 'settings') {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => Setting()));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                textStyle: const TextStyle(color: Colors.white),
                child: const Text('Profile'),
              ),
              PopupMenuItem(
                value: 'settings',
                textStyle: const TextStyle(color: Colors.white),
                child: const Text('Settings'),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 5, 13, 33),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["sender"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color.fromARGB(255, 47, 33, 243)
                          : const Color.fromARGB(255, 151, 4, 117),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _buildMessageText(msg["text"] ?? '', isUser),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 25,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
