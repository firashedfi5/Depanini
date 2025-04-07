import 'package:flutter/material.dart';

class ProviderChatScreen extends StatefulWidget {
  const ProviderChatScreen({super.key});

  @override
  State<ProviderChatScreen> createState() => _ProviderChatScreenState();
}

class _ProviderChatScreenState extends State<ProviderChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Provider Chat Screen')));
  }
}
