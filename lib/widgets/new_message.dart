import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  void _submitMessage() async {
    final entredMessage = _messageController.text;

    if (entredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userDoc =
        await FirebaseFirestore.instance
            .collection("clients")
            .doc(user.uid)
            .get();
    final userData = userDoc.data();

    if (userData == null ||
        !userData.containsKey('Nom d\'utilisateur') ||
        !userData.containsKey('Photo de profile')) {
      throw Exception("Données non trouvé pour l'utilisateur");
    }

    final username = userData['Nom d\'utilisateur'];
    final profilPicture = userData['Photo de profile'];

    FirebaseFirestore.instance.collection('chat').add({
      'text': entredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': username,
      'userImage': profilPicture,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'Envoyer un message...'),
            ),
          ),
          IconButton(
            onPressed: _submitMessage,
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
