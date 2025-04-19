import 'package:depanini/widgets/chat_messages.dart';
import 'package:depanini/widgets/new_message.dart';
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
      body: Stack(
        children: [
          // Background image
          // Positioned.fill(
          //   child: Opacity(
          //     opacity: 0.1,
          //     child: Image.asset(
          //       Theme.of(context).brightness == Brightness.dark
          //           ? 'assets/images/chat_background_white.png'
          //           : 'assets/images/chat_background_black.png',
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),

          // Chat content
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Expanded(
                  child: ChatMessages(receiverEmail: widget.receiverEmail),
                ),
                NewMessage(
                  receiverEmail: widget.receiverEmail,
                  receiverProfilPicture: widget.receiverProfilPicture,
                  receiverUsername: widget.receiverUsername,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
