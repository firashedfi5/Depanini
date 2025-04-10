import 'package:flutter/material.dart';

class ClientChatScreen extends StatelessWidget {
  const ClientChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mes messages')),
      body: Center(child: Text('Chat Screen')),
    );
  }
}
