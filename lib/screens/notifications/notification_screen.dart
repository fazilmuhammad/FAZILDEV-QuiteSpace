import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quitespace/services/firebase_service.dart';
import 'package:quitespace/widgets/notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.firestore
            .collection('notifications')
            .where('targetUserId', isEqualTo: FirebaseService.currentUser?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
          final notifications = snapshot.data!.docs;
          if (notifications.isEmpty) {
            return Center(child: Text('No notifications yet'));
          }
          
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return NotificationItem(notification: notifications[index]);
            },
          );
        },
      ),
    );
  }
}