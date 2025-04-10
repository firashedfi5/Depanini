import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class ChatMessages extends StatefulWidget {
  final String receiverEmail;
  const ChatMessages({super.key, required this.receiverEmail});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  String? chatRoomId;

  @override
  void initState() {
    super.initState();
    _getChatRoom();
  }

  Future<void> _getChatRoom() async {
    final user = _auth.currentUser!;

    final String? senderEmail = user.email;
    List<String> emails = [senderEmail!, widget.receiverEmail];
    emails.sort();
    setState(() {
      chatRoomId = emails.join('-');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = _auth.currentUser!;

    // if (chatRoomId == null) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    return StreamBuilder(
      stream:
          _firestore
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Aucun message pour le moment.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Une erreur est survenue'));
        }

        final loadedMessages = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage =
                index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;

            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
