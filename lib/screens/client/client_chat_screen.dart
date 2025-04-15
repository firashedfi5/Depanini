import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mes messages')),
      body: FutureBuilder(
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
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            padding: EdgeInsets.symmetric(horizontal: 8),
            physics: BouncingScrollPhysics(),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              return Card(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withAlpha(120)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(
                          'assets/images/Mobile_login_bro.png',
                        ),
                      ),
                      SizedBox(width: 13),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 8),
                          Text('data'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
