import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quitespace/models/post_model.dart';
import 'package:quitespace/models/user_model.dart';
import 'package:quitespace/widgets/post_widget.dart';
import 'package:quitespace/screens/profile/profile_screen.dart';

class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showUsers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for users or hashtags...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _showUsers = false;
                });
              },
            ),
          ),
          onFieldSubmitted: (query) {
            setState(() {
              _searchQuery = query;
              _showUsers = query.isNotEmpty;
            });
          },
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildTrendingContent()
          : _showUsers
              ? _buildUserSearchResults()
              : _buildPostSearchResults(),
    );
  }

  Widget _buildTrendingContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Trending Today',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _buildTrendingHashtags(),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Popular Posts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _buildTrendingPosts(),
        ],
      ),
    );
  }

  Widget _buildTrendingHashtags() {
    final hashtags = ['#FlutterDev', '#Zodiac', '#SocialApp', '#Firebase', '#Astrology'];
    
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hashtags.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ActionChip(
              label: Text(hashtags[index]),
              onPressed: () {
                setState(() {
                  _searchQuery = hashtags[index];
                  _showUsers = false;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('likeCount', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        final posts = snapshot.data!.docs.map((doc) => PostModel.fromDocument(doc)).toList();
        
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostWidget(post: posts[index]);
          },
        );
      },
    );
  }

  Widget _buildUserSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: _searchQuery)
          .where('username', isLessThan: _searchQuery + 'z')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        final users = snapshot.data!.docs.map((doc) => UserModel.fromDocument(doc)).toList();
        
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.profileImage ?? ''),
              ),
              title: Text(user.username),
              subtitle: Text(user.bio ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: user.uid),
                ));
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPostSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('content', isGreaterThanOrEqualTo: _searchQuery)
          .where('content', isLessThan: _searchQuery + 'z')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        final posts = snapshot.data!.docs.map((doc) => PostModel.fromDocument(doc)).toList();
        
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostWidget(post: posts[index]);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}