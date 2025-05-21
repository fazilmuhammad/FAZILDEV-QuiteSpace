import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quitespace/screens/post/post_detail_screen.dart';
import 'package:quitespace/services/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  ProfileScreen({this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<DocumentSnapshot> _userFuture;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    final userId = widget.userId ?? FirebaseService.currentUser?.uid;
    if (userId == null) return;
    
    _userFuture = FirebaseService.firestore.collection('users').doc(userId).get();
    _checkFollowingStatus();
  }

  Future<void> _checkFollowingStatus() async {
    if (FirebaseService.currentUser == null || widget.userId == null) return;
    
    final followDoc = await FirebaseService.firestore
        .collection('followers')
        .doc('${FirebaseService.currentUser!.uid}_${widget.userId}')
        .get();
        
    setState(() => _isFollowing = followDoc.exists);
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.userId ?? FirebaseService.currentUser?.uid;
    if (userId == null) return Center(child: Text('Please log in'));

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
          final user = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 100,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(user['coverImage'] ?? '', fit: BoxFit.cover,)
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(user['zodiacImage'] ?? ''),
                          ),
                          Spacer(),
                          if (widget.userId != FirebaseService.currentUser?.uid)
                            ElevatedButton(
                              onPressed: () async {
                                await FirebaseService.toggleFollow(userId);
                                await _checkFollowingStatus();
                              },
                              child: Text(_isFollowing ? 'Following' : 'Follow'),
                            ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        user['username'],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (user['bio'] != null) ...[
                        SizedBox(height: 8),
                        Text(user['bio']),
                      ],
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(user['postCount']?.toString() ?? '0'),
                              Text('Posts'),
                            ],
                          ),
                          Column(
                            children: [
                              Text(user['followerCount']?.toString() ?? '0'),
                              Text('Followers'),
                            ],
                          ),
                          Column(
                            children: [
                              Text(user['followingCount']?.toString() ?? '0'),
                              Text('Following'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(top: 16),
                sliver: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.firestore
                      .collection('posts')
                      .where('userId', isEqualTo: userId)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                    }
                    
                    final posts = snapshot.data!.docs;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailScreen(postId: posts[index].id),
                              ),
                            );
                          },
                          child: Image.network(
                            posts[index]['imageUrl'] ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                        childCount: posts.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}