import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quitespace/models/post_model.dart';
import 'package:quitespace/services/firebase_service.dart';
import 'package:quitespace/widgets/post_widget.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StoriesList(),
        ),
        SliverPadding(
          padding: EdgeInsets.only(top: 8),
          sliver: StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.firestore
                .collection('posts')
                .where('privacy', isEqualTo: 'public')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error loading posts')),
                );
              }
              
              final posts = snapshot.data!.docs
                  .map((doc) => PostModel.fromDocument(doc))
                  .toList();
                  
              if (posts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text('No posts available')),
                );
              }
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => PostWidget(post: posts[index]),
                  childCount: posts.length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class StoriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.firestore
            .collection('stories')
            .where('expiresAt', isGreaterThan: DateTime.now())
            .orderBy('expiresAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error loading stories'));
          }
          
          final stories = snapshot.data!.docs;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stories.length + 1, // +1 for add story button
            itemBuilder: (context, index) {
              if (index == 0) {
                return AddStoryButton();
              }
              return StoryWidget(story: stories[index - 1]);
            },
          );
        },
      ),
    );
  }
}

class AddStoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 2),
            ),
            child: Icon(Icons.add, size: 30),
          ),
          SizedBox(height: 4),
          Text('Your Story', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class StoryWidget extends StatelessWidget {
  final DocumentSnapshot story;
  
  const StoryWidget({Key? key, required this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement your story widget here
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(story['userImage']),
            ),
          ),
          SizedBox(height: 4),
          Text(story['username'], style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}