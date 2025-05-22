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
  UserModel? _author;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        _loadAuthor(),
        _checkIfLiked(),
      ]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAuthor() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.post.userId)
          .get();
          
      if (!mounted) return;
      
      setState(() {
        _author = UserModel.fromDocument(userDoc);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  Future<void> _checkIfLiked() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final likeDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.postId)
          .collection('likes')
          .doc(currentUser.uid)
          .get();

      if (!mounted) return;
      setState(() {
        _isLiked = likeDoc.exists;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (!mounted) return;
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      final postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.postId);

      if (_isLiked) {
        await postRef.collection('likes').doc(currentUser.uid).set({
          'userId': currentUser.uid,
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // print(_hasError);
    
    if (_hasError) {
      return const Center(child: Text('Error loading post'));
    }

    final formattedDate = DateFormat('MMM d, y • h:mm a').format(widget.post.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              widget.post.content,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          
          _buildPostFooter(formattedDate),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: _author?.profileImage != null 
            ? AssetImage(_author!.profileImage!)
            : null,
        child: _author?.profileImage == null 
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(
        _author?.username ?? 'Unknown user',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        _getPrivacyText(widget.post.privacy),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showPostOptions(context),
      ),
    );
  }

  String _getPrivacyText(String privacy) {
    switch (privacy) {
      case 'public': return '🌍 Public';
      case 'friends': return '👥 Friends';
      case 'private': return '🔒 Private';
      default: return privacy;
    }
  }

  Widget _buildPostFooter(String formattedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : null,
                ),
                onPressed: _toggleLike,
              ),
              Text('$_likeCount'),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: () {
                  // TODO: Implement comments
                },
              ),

            ],
          ),
          const SizedBox(height: 4),
          Text(
            formattedDate,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
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
              leading: const Icon(Icons.flag),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement report functionality
              },
            ),
            if (widget.post.userId == FirebaseAuth.instance.currentUser?.uid)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Post'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeletePost(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
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
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePost();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post: ${e.toString()}')),
        );
      }
    }
  }
}