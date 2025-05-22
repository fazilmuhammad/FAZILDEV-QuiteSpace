import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // Auth
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static User? get currentUser => auth.currentUser;
  
  // Firestore
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  // Storage
  static FirebaseStorage get storage => FirebaseStorage.instance;

  // User Operations
  static Future<void> updateUserProfile({
    String? username,
    String? bio,
    String? profileImageUrl,
    String? coverImageUrl,
  }) async {
    if (currentUser == null) return;
    
    await firestore.collection('users').doc(currentUser!.uid).update({
      if (username != null) 'username': username,
      if (bio != null) 'bio': bio,
      if (profileImageUrl != null) 'profileImage': profileImageUrl,
      if (coverImageUrl != null) 'coverImage': coverImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Post Operations
  static Future<String> createPost({
    required String content,
    String? imagePath,
    String privacy = 'public',
  }) async {
    if (currentUser == null) throw Exception('Not authenticated');
    
    String? imageUrl;
    if (imagePath != null) {
      final ref = storage.ref('posts/${currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(File(imagePath));
      imageUrl = await ref.getDownloadURL();
    }

    final docRef = await firestore.collection('posts').add({
      'userId': currentUser!.uid,
      'content': content,
      'privacy': privacy,
      'likeCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // Like Operations
  static Future<void> toggleLike(String postId) async {
    if (currentUser == null) return;
    
    final likeRef = firestore.collection('likes').doc('${postId}_${currentUser!.uid}');
    final likeDoc = await likeRef.get();
    
    final batch = firestore.batch();
    
    if (likeDoc.exists) {
      batch.delete(likeRef);
      batch.update(firestore.collection('posts').doc(postId), {
        'likeCount': FieldValue.increment(-1),
      });
    } else {
      batch.set(likeRef, {
        'postId': postId,
        'userId': currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(firestore.collection('posts').doc(postId), {
        'likeCount': FieldValue.increment(1),
      });
      // Create notification for post owner
      await createNotification(
        targetUserId: (await firestore.collection('posts').doc(postId).get()).data()!['userId'],
        type: 'like',
        postId: postId,
      );
    }
    
    await batch.commit();
  }

  // Comment Operations
  static Future<void> addComment(String postId, String content) async {
    if (currentUser == null) return;
    
    final batch = firestore.batch();
    
    // Add comment
    final commentRef = firestore.collection('comments').doc();
    batch.set(commentRef, {
      'postId': postId,
      'userId': currentUser!.uid,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Update comment count
    batch.update(firestore.collection('posts').doc(postId), {
      'commentCount': FieldValue.increment(1),
    });
    
    await batch.commit();
    
    // Create notification for post owner
    await createNotification(
      targetUserId: (await firestore.collection('posts').doc(postId).get()).data()!['userId'],
      type: 'comment',
      postId: postId,
    );
  }

  // Follow Operations
  static Future<void> toggleFollow(String targetUserId) async {
    if (currentUser == null || currentUser!.uid == targetUserId) return;
    
    final followRef = firestore.collection('followers').doc('${currentUser!.uid}_$targetUserId');
    final followDoc = await followRef.get();
    
    final batch = firestore.batch();
    
    if (followDoc.exists) {
      batch.delete(followRef);
      batch.update(firestore.collection('users').doc(currentUser!.uid), {
        'followingCount': FieldValue.increment(-1),
      });
      batch.update(firestore.collection('users').doc(targetUserId), {
        'followerCount': FieldValue.increment(-1),
      });
    } else {
      batch.set(followRef, {
        'followerId': currentUser!.uid,
        'followingId': targetUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(firestore.collection('users').doc(currentUser!.uid), {
        'followingCount': FieldValue.increment(1),
      });
      batch.update(firestore.collection('users').doc(targetUserId), {
        'followerCount': FieldValue.increment(1),
      });
      // Create notification
      await createNotification(
        targetUserId: targetUserId,
        type: 'follow',
      );
    }
    
    await batch.commit();
  }

  // Notification Operations
  static Future<void> createNotification({
    required String targetUserId,
    required String type,
    String? postId,
    String? commentId,
  }) async {
    if (currentUser == null || targetUserId == currentUser!.uid) return;
    
    await firestore.collection('notifications').add({
      'senderId': currentUser!.uid,
      'targetUserId': targetUserId,
      'type': type,
      'postId': postId,
      'commentId': commentId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Story Operations
  static Future<String> uploadStory(String imagePath) async {
    if (currentUser == null) throw Exception('Not authenticated');
    
    final ref = storage.ref('stories/${currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(File(imagePath));
    final imageUrl = await ref.getDownloadURL();
    
    await firestore.collection('stories').add({
      'userId': currentUser!.uid,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': DateTime.now().add(Duration(hours: 24)),
    });
    
    return imageUrl;
  }

  // Chat Operations
  static Future<void> sendMessage({
    required String chatId,
    required String content,
    String? imagePath,
  }) async {
    if (currentUser == null) return;
    
    String? imageUrl;
    if (imagePath != null) {
      final ref = storage.ref('messages/$chatId/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(File(imagePath));
      imageUrl = await ref.getDownloadURL();
    }
    
    await firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUser!.uid,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
    
    // Update last message in chat
    await firestore.collection('chats').doc(chatId).update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSender': currentUser!.uid,
    });
  }
}