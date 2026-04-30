import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import 'chat_page.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: chatService.getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading chats: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(
              child: Text('No chats yet. Open a post to message a user.'),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final data = chats[index].data() as Map<String, dynamic>;

              final users = List<String>.from(data['users'] ?? []);
              final otherUserId = users.firstWhere(
                (id) => id != currentUser.uid,
                orElse: () => '',
              );

              final userEmails =
                  Map<String, dynamic>.from(data['userEmails'] ?? {});

              final otherUserEmail =
                  userEmails[otherUserId]?.toString() ?? 'Unknown user';

              final itemTitle = data['itemTitle']?.toString() ?? 'Item';
              final lastMessage =
                  data['lastMessage']?.toString() ?? 'No messages yet';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.chat_bubble_outline),
                  ),
                  title: Text(otherUserEmail),
                  subtitle: Text('$itemTitle • $lastMessage'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          otherUserId: otherUserId,
                          otherUserEmail: otherUserEmail,
                          itemTitle: itemTitle,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}