import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quitespace/models/post_model.dart';
import 'package:quitespace/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostWidget extends StatefulWidget {
  final PostModel post;
  
  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isBookmarked = false;
  UserModel? _author;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _checkIfLiked();
    _checkIfBookmarked();
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.post.userId)
        .get();
    setState(() {
      _author = UserModel.fromDocument(userDoc);
    });
  }

  Future<void> _checkIfLiked() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final likeDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.postId)
        .collection('likes')
        .doc(currentUser.uid)
        .get();

    setState(() {
      _isLiked = likeDoc.exists;
    });
  }

  Future<void> _checkIfBookmarked() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final bookmarkDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('bookmarks')
        .doc(widget.post.postId)
        .get();

    setState(() {
      _isBookmarked = bookmarkDoc.exists;
    });
  }

  Future<void> _toggleLike() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.postId);

    if (_isLiked) {
      await postRef.collection('likes').doc(currentUser.uid).set({
        'timestamp': FieldValue.serverTimestamp(),
      });
      await postRef.update({
        'likeCount': FieldValue.increment(1),
      });
    } else {
      await postRef.collection('likes').doc(currentUser.uid).delete();
      await postRef.update({
        'likeCount': FieldValue.increment(-1),
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid);

    if (_isBookmarked) {
      await userRef.collection('bookmarks').doc(widget.post.postId).set({
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await userRef.collection('bookmarks').doc(widget.post.postId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, y • h:mm a').format(widget.post.createdAt);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          _buildPostHeader(),
          
          // Post Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              widget.post.content,
              style: TextStyle(fontSize: 16),
            ),
          ),
          
          // Post Image if available
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
            _buildPostImage(),
          
          // Post Footer
          _buildPostFooter(formattedDate),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: _author?.profileImage != null 
            ? NetworkImage(_author!.profileImage!)
            : null,
        child: _author?.profileImage == null 
            ? Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(
        _author?.username ?? 'Loading...',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        widget.post.privacy == 'public' ? '🌍 Public' : '🔒 Private',
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () => _showPostOptions(context),
      ),
    );
  }

  Widget _buildPostImage() {
    return GestureDetector(
      onTap: () {
        // TODO: Implement image viewer
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: 300),
        child: Image.network(
          widget.post.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(
                child: Icon(Icons.error, color: Colors.red),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostFooter(String formattedDate) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : null,
                    ),
                    onPressed: _toggleLike,
                  ),
                  Text(_likeCount.toString()),
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.comment),
                    onPressed: () {
                      // TODO: Implement comments
                    },
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      // TODO: Implement sharing
                    },
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _isBookmarked ? Colors.blue : null,
                ),
                onPressed: _toggleBookmark,
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            formattedDate,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.flag),
              title: Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement report functionality
              },
            ),
            if (widget.post.userId == FirebaseAuth.instance.currentUser?.uid)
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Post'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeletePost(context);
                },
              ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePost();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost() async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.postId)
          .delete();
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }
}