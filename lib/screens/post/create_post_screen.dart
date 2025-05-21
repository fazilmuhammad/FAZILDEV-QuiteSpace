import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quitespace/services/firebase_service.dart';
import 'package:quitespace/widgets/custom_app_bar.dart';
import 'package:quitespace/utilities/toast_utils.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;
  String _privacy = 'public'; // 'public', 'friends', 'private'
  int _characterCount = 0;
  final int _maxCharacters = 280;

  Future<void> _createPost() async {
    if (_contentController.text.isEmpty) {
      ToastUtils.showErrorToast('Please enter some text');
      return;
    }

    if (_characterCount > _maxCharacters) {
      ToastUtils.showErrorToast('Post exceeds character limit');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create post document
      await FirebaseService.firestore.collection('posts').add({
        'userId': FirebaseService.currentUser!.uid,
        'content': _contentController.text,
        'privacy': _privacy,
        'likeCount': 0,
        'commentCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'type': 'text', // To differentiate between future post types
      });

      // Update user's post count
      await FirebaseService.firestore
          .collection('users')
          .doc(FirebaseService.currentUser!.uid)
          .update({
        'postCount': FieldValue.increment(1),
      });

      ToastUtils.showSuccessToast('Posted successfully!');
      Navigator.of(context).pop();
    } catch (e) {
      ToastUtils.showErrorToast('Failed to create post: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Create Post',
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPost,
            child: Text(
              'Post',
              style: TextStyle(
                color: _characterCount > _maxCharacters
                    ? Colors.grey
                    : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Author Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    FirebaseService.currentUser?.photoURL ?? '',
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  FirebaseService.currentUser?.displayName ?? 'Anonymous',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                DropdownButton<String>(
                  value: _privacy,
                  items: [
                    DropdownMenuItem(
                      value: 'public',
                      child: Row(
                        children: [
                          Icon(Icons.public, size: 16),
                          SizedBox(width: 4),
                          Text('Public'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'friends',
                      child: Row(
                        children: [
                          Icon(Icons.people, size: 16),
                          SizedBox(width: 4),
                          Text('Friends Only'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'private',
                      child: Row(
                        children: [
                          Icon(Icons.lock, size: 16),
                          SizedBox(width: 4),
                          Text('Private'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _privacy = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            // Content Input
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: "What's happening?",
                border: InputBorder.none,
              ),
              maxLines: null,
              maxLength: _maxCharacters,
              onChanged: (text) {
                setState(() {
                  _characterCount = text.length;
                });
              },
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_characterCount/$_maxCharacters',
                style: TextStyle(
                  color: _characterCount > _maxCharacters
                      ? Colors.red
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}