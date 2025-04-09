import 'package:flutter/material.dart';

class ClientChatScreen extends StatefulWidget {
  const ClientChatScreen({super.key});

  @override
  State<ClientChatScreen> createState() => _ClientChatScreenState();
}

class _ClientChatScreenState extends State<ClientChatScreen> {
  void getAllChats() {
    // _firestore
    //       .collection('chat_rooms')
    //       .doc(chatRoomId)
    //       .collection('messages')
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Chat Screen')));
  }
}
