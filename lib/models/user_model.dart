import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String userUniq;
  final String? bio;
  final String? profileImage;
  final String? coverImage;
  final DateTime birthDate;
  final String zodiacSign;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.userUniq,
    this.bio,
    this.profileImage,
    this.coverImage,
    required this.birthDate,
    required this.zodiacSign,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    required this.createdAt,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'],
      username: data['username'],
      userUniq: data['userUniq'],
      bio: data['bio'],
      profileImage: data['profileImage'],
      coverImage: data['coverImage'],
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      zodiacSign: data['zodiacSign'],
      followerCount: data['followerCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      postCount: data['postCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'user_uniq': userUniq,
      'bio': bio,
      'profileImage': profileImage,
      'coverImage': coverImage,
      'birthDate': Timestamp.fromDate(birthDate),
      'zodiacSign': zodiacSign,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'postCount': postCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}