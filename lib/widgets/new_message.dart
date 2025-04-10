import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class NewMessage extends StatefulWidget {
  final String receiverEmail;
  const NewMessage({super.key, required this.receiverEmail});

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
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    // FocusScope.of(context).unfocus();
    _messageController.clear();

    final user = _auth.currentUser!;

    // Try to get user data from 'clients' first
    DocumentSnapshot userDoc =
        await _firestore.collection("clients").doc(user.uid).get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    // If not found in 'clients', try 'prestataires'
    if (userData == null) {
      userDoc = await _firestore.collection("prestataires").doc(user.uid).get();
      userData = userDoc.data() as Map<String, dynamic>?;
    }

    if (userData == null ||
        !userData.containsKey('Nom d\'utilisateur') ||
        !userData.containsKey('Photo de profile')) {
      throw Exception("Données non trouvées pour l'utilisateur");
    }

    final senderEmail = userData['Email'];
    final senderUsername = userData['Nom d\'utilisateur'];
    final profilePicture = userData['Photo de profile'];

    List<String> emails = [senderEmail, widget.receiverEmail];
    emails.sort();
    String chatRoomId = emails.join('-');

    _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'participants': emails,
    });

    _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
          'text': enteredMessage,
          'createdAt': Timestamp.now(),
          'userId': user.uid,
          'senderUsername': senderUsername,
          'senderEmail': senderEmail,
          'userImage': profilePicture,
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14, top: 14),
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
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
