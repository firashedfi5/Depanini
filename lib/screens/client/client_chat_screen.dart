import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/screens/common/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class ClientChatScreen extends StatelessWidget {
  const ClientChatScreen({super.key});

  Future<QuerySnapshot<Map<String, dynamic>>> _getChatRooms() async {
    final currentUserEmail = _auth.currentUser!.email;

    final chatRooms =
        await _firestore
            .collection('chat_rooms')
            .where('participants', arrayContains: currentUserEmail)
            .get();

    return chatRooms;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _getLastMessage(
    String chatRoomId,
  ) async {
    final snapshot =
        await _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes messages')),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: _getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final chatRooms = snapshot.data?.docs ?? [];

          if (chatRooms.isEmpty) {
            return const Center(child: Text('Aucune conversation trouvée.'));
          }

          return ListView.separated(
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            physics: const BouncingScrollPhysics(),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final chatRoomId = chatRoom.id;

              final currentUserEmail = _auth.currentUser!.email!;
              // final participants = chatRoomId.split('_');
              // final otherUserEmail = participants.firstWhere(
              //   (email) => email != currentUserEmail,
              //   orElse: () => 'Inconnu',
              // );

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                future: _getLastMessage(chatRoomId),
                builder: (context, messageSnapshot) {
                  final messageData = messageSnapshot.data?.data();
                  final lastMessageText =
                      messageData?['text'] ?? 'Aucun message';
                  final lastMessageTime =
                      messageData?['createdAt'] != null
                          ? (messageData!['createdAt'] as Timestamp).toDate()
                          : null;

                  final recieverUsername =
                      messageData?['receiverUsername'] ?? 'Aucun';
                  final recieverProfilPicture =
                      messageData?['receiverProfilPicture'];
                  final recieverEmail = messageData?['receiverEmail'];

                  return InkWell(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChatScreen(
                                  receiverEmail: recieverEmail,
                                  receiverUsername: recieverUsername,
                                  receiverProfilPicture: recieverProfilPicture,
                                ),
                          ),
                        ),
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
                                  recieverProfilPicture != null
                                      ? NetworkImage(recieverProfilPicture)
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
                                    recieverUsername,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    messageData?['senderEmail'] ==
                                            currentUserEmail
                                        ? 'Vous: $lastMessageText'
                                        : lastMessageText,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  if (lastMessageTime != null)
                                    Text(
                                      '${lastMessageTime.hour.toString().padLeft(2, '0')}:${lastMessageTime.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
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
