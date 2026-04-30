import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'post_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recent Lost & Found Posts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Search items',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('createdAt', descending: true)
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

                final docs = snapshot.data?.docs ?? [];

                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final description =
                      (data['description'] ?? '').toString().toLowerCase();
                  final query = searchText.toLowerCase();

                  return title.contains(query) || description.contains(query);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No posts found.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final String postId = doc.id;
                    final String title =
                        data['title']?.toString() ?? 'Untitled Post';
                    final String description =
                        data['description']?.toString() ??
                            'No description available';
                    final String status =
                        data['status']?.toString() ?? 'Unknown';
                    final String imageUrl =
                        data['imageUrl']?.toString() ?? '';
                    final String userEmail =
                        data['userEmail']?.toString() ?? 'Unknown';
                    final String userId =
                        data['userId']?.toString() ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.inventory_2_outlined),
                              ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('$status • $description'),
                        ),
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
        ],
      ),
    );
  }
}