import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';
import 'meetup_page.dart';

class PostDetailsPage extends StatelessWidget {
  final String postId;
  final String title;
  final String description;
  final String status;
  final String imageUrl;
  final String userEmail;
  final String userId;

  const PostDetailsPage({
    super.key,
    required this.postId,
    required this.title,
    required this.description,
    required this.status,
    required this.imageUrl,
    required this.userEmail,
    required this.userId,
  });

  Future<void> deletePost(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.uid != userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only delete your own post'),
        ),
      );
      return;
    }

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text(
            'Are you sure you want to take down this post?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete != true) {
      return;
    }

    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

    if (!context.mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post deleted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser?.uid == userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      color: status == 'Lost' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 25),
                  const Text(
                    'Posted by',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(userEmail),
                  const SizedBox(height: 30),
                  if (!isOwner)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: userId.isEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      otherUserId: userId,
                                      otherUserEmail: userEmail,
                                      itemTitle: title,
                                    ),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.chat),
                        label: const Text('Message User'),
                      ),
                    ),
                  if (!isOwner) const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MeetupPage(itemTitle: title),
                          ),
                        );
                      },
                      icon: const Icon(Icons.local_police_outlined),
                      label: const Text('Set Safe Meetup'),
                    ),
                  ),
                  if (isOwner) const SizedBox(height: 12),
                  if (isOwner)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          deletePost(context);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Post'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}