import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quitespace/services/firebase_service.dart';

class ChatModel {
  final String id;
  final Map<String, bool> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;

  ChatModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
  });

  factory ChatModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participants: Map<String, bool>.from(data['participants']),
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime']?.toDate(),
      lastMessageSender: data['lastMessageSender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null 
          ? Timestamp.fromDate(lastMessageTime!) 
          : null,
      'lastMessageSender': lastMessageSender,
    };
  }

  String get otherParticipantId => participants.keys.firstWhere(
        (id) => id != FirebaseService.currentUser?.uid,
  );
}