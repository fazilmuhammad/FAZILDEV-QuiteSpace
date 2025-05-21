import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quitespace/services/firebase_service.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<DocumentSnapshot> _postFuture;
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _postFuture = FirebaseService.firestore.collection('posts').doc(widget.postId).get();
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    if (FirebaseService.currentUser == null) return;
    
    final postDoc = await FirebaseService.firestore.collection('posts').doc(widget.postId).get();
    final likes = postDoc['likes'] as List<dynamic>? ?? [];
    
    setState(() {
      _isLiked = likes.contains(FirebaseService.currentUser!.uid);
      _likeCount = likes.length;
    });
  }

  Future<void> _toggleLike() async {
    if (FirebaseService.currentUser == null) return;
    
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    await FirebaseService.firestore.collection('posts').doc(widget.postId).update({
      'likes': _isLiked
          ? FieldValue.arrayUnion([FirebaseService.currentUser!.uid])
          : FieldValue.arrayRemove([FirebaseService.currentUser!.uid]),
    });
  }

  Future<void> _addComment() async {
    if (FirebaseService.currentUser == null || _commentController.text.isEmpty) return;

    final comment = {
      'userId': FirebaseService.currentUser!.uid,
      'username': FirebaseService.currentUser!.displayName ?? 'Anonymous',
      'userImage': FirebaseService.currentUser!.photoURL,
      'text': _commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseService.firestore.collection('posts').doc(widget.postId).update({
      'comments': FieldValue.arrayUnion([comment]),
    });

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          if (FirebaseService.currentUser != null)
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {
                // Implement save post functionality
              },
            ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = snapshot.data!;
          final timestamp = post['createdAt'] as Timestamp?;
          final formattedDate = timestamp != null
              ? DateFormat('MMMM d, y • h:mm a').format(timestamp.toDate())
              : '';

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post header with user info
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseService.firestore.collection('users').doc(post['userId']).get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const SizedBox();
                          }
                          
                          final user = userSnapshot.data!;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user['profileImage'] ?? ''),
                            ),
                            title: Text(user['username'] ?? 'Unknown user'),
                            subtitle: Text(formattedDate),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                // Show post options
                              },
                            ),
                          );
                        },
                      ),
                      
                      // Post image
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          post['imageUrl'] ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      
                      // Like/comment buttons
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isLiked ? Icons.favorite : Icons.favorite_border,
                                color: _isLiked ? Colors.red : null,
                              ),
                              onPressed: _toggleLike,
                            ),
                            Text(_likeCount.toString()),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.comment),
                              onPressed: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  _commentController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: _commentController.text.length),
                                  );
                                });
                              },
                            ),
                            Text((post['comments']?.length ?? 0).toString()),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                // Implement share functionality
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Caption
                      if (post['caption'] != null && post['caption'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(post['caption']),
                        ),
                      
                      // Comments section
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Comments',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      
                      // Comments list
                      if (post['comments'] != null && post['comments'].isNotEmpty)
                        ...(post['comments'] as List<dynamic>).map((comment) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: comment['userImage'] != null
                                  ? NetworkImage(comment['userImage'])
                                  : null,
                            ),
                            title: Text(comment['username']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment['text']),
                                if (comment['timestamp'] != null)
                                  Text(
                                    DateFormat('MMM d, y • h:mm a')
                                        .format((comment['timestamp'] as Timestamp).toDate()),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
              
              // Comment input
              if (FirebaseService.currentUser != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addComment(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _addComment,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}