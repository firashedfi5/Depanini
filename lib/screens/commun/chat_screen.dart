import 'dart:developer' as dev;

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:depanini/widgets/chat_messages.dart';
import 'package:depanini/widgets/new_message.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// final _firestore = FirebaseFirestore.instance;
// final _auth = FirebaseAuth.instance;

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
  // final _currentUserUid = _auth.currentUser?.uid;

  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();

    final token = await fcm.getToken();
    dev.log(token.toString());

    fcm.subscribeToTopic('chat');

    // Try updating the token in 'prestataires' collection
    // final prestataireSnapshot =
    //     await _firestore
    //         .collection('prestataires')
    //         .where('Uid', isEqualTo: _currentUserUid)
    //         .get();

    // if (prestataireSnapshot.docs.isNotEmpty) {
    //   final docId = prestataireSnapshot.docs.first.id;
    //   await _firestore.collection('prestataires').doc(docId).update({
    //     'fcmToken': token,
    //   });
    //   dev.log('Token updated in prestataires');
    //   return;
    // }

    // // If not found in prestataires, try 'clients'
    // final clientSnapshot =
    //     await _firestore
    //         .collection('clients')
    //         .where('Uid', isEqualTo: _currentUserUid)
    //         .get();

    // if (clientSnapshot.docs.isNotEmpty) {
    //   final docId = clientSnapshot.docs.first.id;
    //   await _firestore.collection('clients').doc(docId).update({
    //     'fcmToken': token,
    //   });
    //   dev.log('Token updated in clients');
    //   return;
    // }

    // dev.log('User not found in either prestataires or clients collection');
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
              backgroundImage: CachedNetworkImageProvider(
                widget.receiverProfilPicture,
                cacheKey: widget.receiverProfilPicture,
              ),
              // NetworkImage(widget.receiverProfilPicture),
            ),
            const SizedBox(width: 10),
            Text(widget.receiverUsername),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 10),
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
