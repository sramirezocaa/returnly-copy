import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getChatRoomId(String user1, String user2) {
    List<String> users = [user1, user2];
    users.sort();
    return users.join('_');
  }

  Stream<QuerySnapshot> getChatRooms() {
    final currentUser = _auth.currentUser!;

    return _firestore
        .collection('chat_rooms')
        .where('users', arrayContains: currentUser.uid)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessages(String otherUserId) {
    final currentUser = _auth.currentUser!;
    final chatRoomId = getChatRoomId(currentUser.uid, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendMessage({
    required String otherUserId,
    required String otherUserEmail,
    required String itemTitle,
    required String message,
  }) async {
    final currentUser = _auth.currentUser!;
    final chatRoomId = getChatRoomId(currentUser.uid, otherUserId);

    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'users': [currentUser.uid, otherUserId],
      'userEmails': {
        currentUser.uid: currentUser.email,
        otherUserId: otherUserEmail,
      },
      'itemTitle': itemTitle,
      'lastMessage': message,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': currentUser.uid,
      'senderEmail': currentUser.email,
      'receiverId': otherUserId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}