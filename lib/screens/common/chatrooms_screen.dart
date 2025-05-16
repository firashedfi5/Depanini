import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/screens/common/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class ChatroomsScreen extends StatelessWidget {
  const ChatroomsScreen({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _chatRoomsStream() {
    final currentUserEmail = _auth.currentUser?.email;
    if (currentUserEmail == null) {
      throw Exception('User not logged in');
    }

    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserEmail)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _lastMessageStream(
    String chatRoomId,
  ) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null,
        )
        .where((doc) => doc != null)
        .cast<DocumentSnapshot<Map<String, dynamic>>>();
  }

  String? determineOtherUsername(
    Map<String, dynamic>? data,
    String currentEmail,
  ) {
    if (data == null) return null;
    final receiverEmail = data['receiverEmail'];
    final receiverUsername = data['receiverUsername'];
    final senderUsername = data['senderUsername'];
    return receiverEmail != null && receiverEmail != currentEmail
        ? receiverUsername
        : senderUsername;
  }

  String? determineOtherProfilePicture(
    Map<String, dynamic>? data,
    String currentEmail,
  ) {
    if (data == null) return null;
    final receiverEmail = data['receiverEmail'];
    final receiverPic = data['receiverProfilPicture'];
    final senderPic = data['senderProfilePicture'];
    return receiverEmail != null && receiverEmail != currentEmail
        ? receiverPic
        : senderPic;
  }

  String? determineOtherEmail(Map<String, dynamic>? data, String currentEmail) {
    if (data == null) return null;
    final receiver = data['receiverEmail'];
    final sender = data['senderEmail'];
    return receiver != null && receiver != currentEmail ? receiver : sender;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes messages')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _chatRoomsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final chatRooms = snapshot.data?.docs ?? [];

          if (chatRooms.isEmpty) {
            return Center(
              child: Text(
                'Aucune conversation trouvée.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final currentUserEmail = _auth.currentUser?.email;
          if (currentUserEmail == null) return const SizedBox();

          return ListView.separated(
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            physics: const BouncingScrollPhysics(),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final chatRoomId = chatRoom.id;

              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _lastMessageStream(chatRoomId),
                builder: (context, messageSnapshot) {
                  if (!messageSnapshot.hasData) {
                    return const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final messageData = messageSnapshot.data!.data();
                  if (messageData == null) return const SizedBox();

                  final lastMessageText =
                      messageData['text'] ?? 'Aucun message';
                  final lastMessageTime =
                      messageData['createdAt'] != null
                          ? (messageData['createdAt'] as Timestamp).toDate()
                          : null;

                  final otherUsername = determineOtherUsername(
                    messageData,
                    currentUserEmail,
                  );
                  final otherProfilePicture = determineOtherProfilePicture(
                    messageData,
                    currentUserEmail,
                  );
                  final otherEmail = determineOtherEmail(
                    messageData,
                    currentUserEmail,
                  );

                  if (otherEmail == null || otherUsername == null) {
                    return const SizedBox();
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatScreen(
                                receiverEmail: otherEmail,
                                receiverUsername: otherUsername,
                                receiverProfilPicture:
                                    otherProfilePicture ??
                                    'https://ui-avatars.com/api/?name=$otherUsername',
                              ),
                        ),
                      );
                    },
                    child: Card(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withAlpha(120)
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  otherProfilePicture != null
                                      ? NetworkImage(otherProfilePicture)
                                      : const AssetImage(
                                            'assets/images/default_avatar.png',
                                          )
                                          as ImageProvider,
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    otherUsername,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    messageData['senderEmail'] ==
                                            currentUserEmail
                                        ? 'Vous: $lastMessageText'
                                        : lastMessageText,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            if (lastMessageTime != null)
                              Text(
                                timeago.format(lastMessageTime, locale: 'fr'),
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
