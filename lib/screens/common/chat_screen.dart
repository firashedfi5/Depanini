import 'package:depanini/widgets/chat_messages.dart';
import 'package:depanini/widgets/new_message.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  final String profilPictureUrl;
  final String receiverEmail;

  const ChatScreen({
    super.key,
    required this.username,
    required this.profilPictureUrl,
    required this.receiverEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundImage: NetworkImage(widget.profilPictureUrl),
            ),
            SizedBox(width: 10),
            Text(widget.username),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Expanded(child: ChatMessages(receiverEmail: widget.receiverEmail)),
            NewMessage(receiverEmail: widget.receiverEmail),
          ],
        ),
      ),
    );
  }
}
