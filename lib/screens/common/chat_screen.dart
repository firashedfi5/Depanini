import 'dart:developer' as dev;

import 'package:depanini/widgets/chat_messages.dart';
import 'package:depanini/widgets/new_message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUsername;
  final String receiverProfilPicture;
  final String receiverEmail;

  const ChatScreen({
    super.key,
    required this.receiverUsername,
    required this.receiverProfilPicture,
    required this.receiverEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();

    final token = await fcm.getToken();
    dev.log(token.toString());

    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();

    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundImage: NetworkImage(widget.receiverProfilPicture),
            ),
            SizedBox(width: 10),
            Text(widget.receiverUsername),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Expanded(child: ChatMessages(receiverEmail: widget.receiverEmail)),
            NewMessage(
              receiverEmail: widget.receiverEmail,
              receiverProfilPicture: widget.receiverProfilPicture,
              receiverUsername: widget.receiverUsername,
            ),
          ],
        ),
      ),
    );
  }
}
