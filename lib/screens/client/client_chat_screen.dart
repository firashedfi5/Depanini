import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClientChatScreen extends StatefulWidget {
  const ClientChatScreen({super.key});

  @override
  State<ClientChatScreen> createState() => _ClientChatScreenState();
}

class _ClientChatScreenState extends State<ClientChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: _buildChatList(),
    );
  }

  Widget _buildChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chat_rooms').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final chatRooms =
            snapshot.data!.docs.where((doc) {
              final participants = doc.id.split('-');
              return participants.contains(_currentUser.email);
            }).toList();

        if (chatRooms.isEmpty) {
          return const Center(child: Text('No chats found'));
        }

        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            return _buildChatItem(chatRooms[index]);
          },
        );
      },
    );
  }

  Widget _buildChatItem(DocumentSnapshot doc) {
    final participants = doc.id.split('-');
    final otherUser = participants.firstWhere(
      (email) => email != _currentUser.email,
      orElse: () => 'Unknown User',
    );

    return ListTile(
      title: Text(otherUser),
      subtitle: _buildLastMessagePreview(doc.reference.collection('messages')),
      onTap: () => _openChatRoom(doc.id, otherUser),
    );
  }

  Widget _buildLastMessagePreview(CollectionReference messages) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          messages.orderBy('createdAt', descending: true).limit(1).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final lastMessage = snapshot.data!.docs.first;
          return Text(
            lastMessage['text'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600]),
          );
        }
        return const Text('Start a conversation...');
      },
    );
  }

  void _openChatRoom(String roomId, String otherUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatRoomScreen(roomId: roomId, otherUser: otherUser),
      ),
    );
  }
}

class ChatRoomScreen extends StatelessWidget {
  final String roomId;
  final String otherUser;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(otherUser)),
      body: Column(
        children: [Expanded(child: _buildMessagesList()), _buildMessageInput()],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('chat_rooms')
              .doc(roomId)
              .collection('messages')
              .orderBy('createdAt')
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final message = snapshot.data!.docs[index];
            return _buildMessageItem(message);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot message) {
    final isMe = message['userId'] == FirebaseAuth.instance.currentUser!.uid;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message['text']),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message['createdAt']),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              final user = FirebaseAuth.instance.currentUser!;
              await FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(roomId)
                  .collection('messages')
                  .add({
                    'text': controller.text.trim(),
                    'userId': user.uid,
                    'username': user.email,
                    'createdAt': Timestamp.now(),
                  });

              controller.clear();
            },
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
