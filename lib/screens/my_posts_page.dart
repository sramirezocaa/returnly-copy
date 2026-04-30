import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'post_details_page.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Posts')),
        body: const Center(
          child: Text('You must be logged in to view your posts.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where('userId', isEqualTo: currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading posts: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final posts = snapshot.data?.docs ?? [];

            if (posts.isEmpty) {
              return const Center(
                child: Text('You have not created any posts yet.'),
              );
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final doc = posts[index];
                final data = doc.data() as Map<String, dynamic>;

                final String postId = doc.id;
                final String title =
                    data['title']?.toString() ?? 'Untitled Post';
                final String description =
                    data['description']?.toString() ??
                        'No description available';
                final String status = data['status']?.toString() ?? 'Unknown';
                final String imageUrl = data['imageUrl']?.toString() ?? '';
                final String userEmail =
                    data['userEmail']?.toString() ?? 'Unknown';
                final String userId = data['userId']?.toString() ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            ),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.inventory_2_outlined),
                          ),
                    title: Text(title),
                    subtitle: Text('$status • $description'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailsPage(
                            postId: postId,
                            title: title,
                            description: description,
                            status: status,
                            imageUrl: imageUrl,
                            userEmail: userEmail,
                            userId: userId,
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
      ),
    );
  }
}