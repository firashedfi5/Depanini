import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _counter = 0; // Counter variable

  void _incrementCounter() {
    setState(() {
      _counter++; // Increase counter by 1
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Times Clicked: $_counter", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _incrementCounter, // Call function when clicked
              child: Text("Click Me"),
            ),
          ],
        ),
      ),
    );
  }
}
