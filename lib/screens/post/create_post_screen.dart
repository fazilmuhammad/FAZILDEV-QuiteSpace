import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quitespace/services/firebase_service.dart';
import 'package:quitespace/utilities/toast_utils.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;
  int _characterCount = 0;
  final int _maxCharacters = 280;

  String generateRandomCode({int length = 5}) {
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const digits = '0123456789';
    final allChars = letters + digits;
    final rand = Random();

    return List.generate(length, (index) {
      return allChars[rand.nextInt(allChars.length)];
    }).join();
  }

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
      await FirebaseService.firestore.collection('posts').add({
        'postId': generateRandomCode(),
        'userId': FirebaseService.currentUser!.uid,
        'content': _contentController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

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
      backgroundColor: Color(0xFFF9DCDC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spark a Twinkle!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFF2F2B3A),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: "What's on your cozy mind?",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
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
                      Spacer(),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _createPost,
                        icon: Icon(Icons.auto_awesome, color: Colors.black, size: 18),
                        label: Text(
                          'Star Drop',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB3F3C2),
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Color(0xFF91E5F6),
              child: Icon(Icons.add, color: Colors.black),
            ),
            label: '',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
