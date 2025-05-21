import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quitespace/services/firebase_service.dart';

class NotificationItem extends StatelessWidget {
  final QueryDocumentSnapshot notification;

  const NotificationItem({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = notification.data() as Map<String, dynamic>;
    final type = data['type'] ?? 'unknown';
    final isRead = data['isRead'] ?? false;
    final createdAt = data['createdAt']?.toDate() ?? DateTime.now();

    // Get appropriate icon and text based on notification type
    IconData icon;
    String title;
    String? body;

    switch (type) {
      case 'like':
        icon = Icons.favorite;
        title = 'New like';
        body = data['postTitle'] != null ? 'on "${data['postTitle']}"' : 'on your post';
        break;
      case 'comment':
        icon = Icons.comment;
        title = 'New comment';
        body = data['commentPreview'] ?? 'on your post';
        break;
      case 'follow':
        icon = Icons.person_add;
        title = 'New follower';
        body = data['username'] != null ? '@${data['username']} followed you' : 'Someone followed you';
        break;
      case 'mention':
        icon = Icons.alternate_email;
        title = 'You were mentioned';
        body = data['commentPreview'] ?? 'in a comment';
        break;
      default:
        icon = Icons.notifications;
        title = 'Notification';
        body = data['message'] ?? '';
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseService.firestore.collection('users').doc(data['senderUserId']).get(),
      builder: (context, snapshot) {
        final sender = snapshot.data?.data() as Map<String, dynamic>?;
        final senderName = sender?['username'] ?? 'Unknown user';
        final senderImage = sender?['profileImage'];

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: isRead ? Colors.white : Colors.blue[50],
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: senderImage != null ? NetworkImage(senderImage) : null,
              child: senderImage == null ? Icon(Icons.person) : null,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isRead ? Colors.black : Theme.of(context).primaryColor,
                  ),
                ),
                if (body != null && body.isNotEmpty)
                  Text(
                    body,
                    style: TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            subtitle: Text(
              DateFormat('MMM d, h:mm a').format(createdAt),
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(
              icon,
              color: isRead ? Colors.grey : Theme.of(context).primaryColor,
            ),
            onTap: () {
              // Mark as read when tapped
              notification.reference.update({'isRead': true});
              
              // Handle navigation based on notification type
              _handleNotificationTap(context, type, data);
            },
          ),
        );
      },
    );
  }

  void _handleNotificationTap(BuildContext context, String type, Map<String, dynamic> data) {
    switch (type) {
      case 'like':
      case 'comment':
      case 'mention':
        // Navigate to post
        if (data['postId'] != null) {
          Navigator.pushNamed(context, '/post', arguments: data['postId']);
        }
        break;
      case 'follow':
        // Navigate to user profile
        if (data['senderUserId'] != null) {
          Navigator.pushNamed(context, '/profile', arguments: data['senderUserId']);
        }
        break;
      default:
        // Handle other notification types or default case
        break;
    }
  }
}