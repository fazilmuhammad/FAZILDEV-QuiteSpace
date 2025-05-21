import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quitespace/screens/messages/chat_detail_screen.dart';
import 'package:quitespace/services/firebase_service.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.firestore
            .collection('chats')
            .where('participants.${FirebaseService.currentUser?.uid}', isEqualTo: true)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
          final chats = snapshot.data!.docs;
          if (chats.isEmpty) {
            return Center(child: Text('No messages yet'));
          }
          
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = Map<String, dynamic>.from(chat['participants']);
              final otherUserId = participants.keys.firstWhere(
                (id) => id != FirebaseService.currentUser?.uid);
              
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseService.firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return ListTile();
                  
                  final user = userSnapshot.data!;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['profileImage'] ?? ''),
                    ),
                    title: Text(user['username']),
                    subtitle: Text(
                      chat['lastMessageSender'] == FirebaseService.currentUser?.uid
                          ? 'You: ${chat['lastMessage']}'
                          : chat['lastMessage'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      DateFormat('HH:mm').format(chat['lastMessageTime'].toDate()),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            chatId: chat.id,
                            otherUserId: otherUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}