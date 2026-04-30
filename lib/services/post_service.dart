import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<QuerySnapshot> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String> uploadPostImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user logged in');
    }

    final String path =
        'post_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    final Reference ref = _storage.ref().child(path);

    final UploadTask uploadTask = ref.putData(imageBytes);

    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<void> createPost({
    required String title,
    required String description,
    required String category,
    required String status,
    String imageUrl = '',
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user logged in');
    }

    await _firestore.collection('posts').add({
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'imageUrl': imageUrl,
      'userId': user.uid,
      'userEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}