import 'package:depanini/widgets/chat_messages.dart';
import 'package:depanini/widgets/new_message.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: const [Expanded(child: ChatMessages()), NewMessage()],
        ),
      ),
    );
  }
}
