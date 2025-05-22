import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quitespace/models/post_model.dart';
import 'package:quitespace/widgets/post_widget.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return CustomScrollView(
      slivers: [
        // const SliverToBoxAdapter(
        //   child: StoriesList(),
        // ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 8),
          sliver: StreamBuilder<QuerySnapshot>(
            stream: currentUser != null
                ? FirebaseFirestore.instance
                    .collection('posts')
                    .where('privacy', whereIn: ['public', 'friends'])
                    .orderBy('createdAt', descending: true)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('posts')
                    .where('privacy', isEqualTo: 'public')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              print(snapshot.error);
              
              if (snapshot.hasError) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Error loading posts')),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No posts available')),
                );
              }
              
              final posts = snapshot.data!.docs
                  .map((doc) => PostModel.fromDocument(doc))
                  .toList();
                  
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    return PostWidget(post: post);
                  },
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

// class StoriesList extends StatelessWidget {
//   const StoriesList({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 120,
//       child: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('stories')
//             .where('expiresAt', isGreaterThan: DateTime.now())
//             .orderBy('expiresAt')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
          
//           if (snapshot.hasError) {
//             return const Center(child: Text('Error loading stories'));
//           }
          
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No stories available'));
//           }
          
//           final stories = snapshot.data!.docs;
//           return ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: stories.length + 1, // +1 for add story button
//             itemBuilder: (context, index) {
//               if (index == 0) {
//                 return const AddStoryButton();
//               }
//               final story = stories[index - 1];
//               final data = story.data() as Map<String, dynamic>;
//               return StoryWidget(
//                 userImage: data['userImage'] ?? '',
//                 username: data['username'] ?? '',
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class AddStoryButton extends StatelessWidget {
//   const AddStoryButton({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8),
//       child: Column(
//         children: [
//           Container(
//             width: 70,
//             height: 70,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.grey[200],
//               border: Border.all(color: Colors.grey, width: 2),
//             ),
//             child: Icon(Icons.add, size: 30, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 4),
//           const Text('Your Story', style: TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }
// }

// class StoryWidget extends StatelessWidget {
//   final String userImage;
//   final String username;
  
//   const StoryWidget({
//     Key? key, 
//     required this.userImage,
//     required this.username,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8),
//       child: Column(
//         children: [
//           Container(
//             width: 70,
//             height: 70,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: const LinearGradient(
//                 colors: [Colors.purple, Colors.orange],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               border: Border.all(color: Colors.white, width: 2),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(2),
//               child: CircleAvatar(
//                 backgroundImage: NetworkImage(userImage),
//                 onBackgroundImageError: (_, __) => const Icon(Icons.person),
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             username,
//             style: const TextStyle(fontSize: 12),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }