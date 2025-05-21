import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quitespace/services/firebase_service.dart';
import 'dart:io';
import 'package:quitespace/models/post_model.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _imageFile;
  String _privacy = 'public';
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _imageFile = null;
    });
  }

  Future<void> _submitPost() async {
    if (_contentController.text.isEmpty && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add some content or an image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_imageFile != null) {
        // Upload image to Firebase Storage
        final ref = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      // Create post in Firestore
      await FirebaseService.createPost(
        content: _contentController.text,
        imagePath: _imageFile?.path,
        privacy: _privacy,
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isLoading ? null : _submitPost,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            FirebaseAuth.instance.currentUser?.photoURL ?? ''),
                        ),
                        SizedBox(width: 10),
                        Text(
                          FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous',
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
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                    if (_imageFile != null)
                      Stack(
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: _removeImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.image),
              onPressed: _pickImage,
              tooltip: 'Add Image',
            ),
            IconButton(
              icon: Icon(Icons.tag),
              onPressed: () {
                // Add hashtag functionality
                _contentController.text += ' #';
              },
              tooltip: 'Add Hashtag',
            ),
            IconButton(
              icon: Icon(Icons.emoji_emotions),
              onPressed: () {
                // Add emoji picker functionality
              },
              tooltip: 'Add Emoji',
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