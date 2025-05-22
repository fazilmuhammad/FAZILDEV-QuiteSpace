import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quitespace/screens/auth/login_page.dart';
import 'package:quitespace/services/firebase_service.dart';
import 'package:quitespace/utilities/toast_utils.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  ProfileScreen({this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<DocumentSnapshot> _userFuture;
  bool _isFollowing = false;
  TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userId = widget.userId ?? FirebaseService.currentUser?.uid;
    if (userId == null) return;

    _userFuture =
        FirebaseService.firestore.collection('users').doc(userId).get();
    _checkFollowingStatus();
  }

  Future<void> _checkFollowingStatus() async {
    if (FirebaseService.currentUser == null || widget.userId == null) return;

    final followDoc =
        await FirebaseService.firestore
            .collection('followers')
            .doc('${FirebaseService.currentUser!.uid}_${widget.userId}')
            .get();

    setState(() => _isFollowing = followDoc.exists);
  }

  Future<void> _logout() async {
    try {
      await FirebaseService.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      ToastUtils.showSuccessToast('Stay pawsitive, see you soon! 🐱');
    } catch (e) {
      ToastUtils.showErrorToast('Failed to logout: ${e.toString()}');
    }
  }

  Future<void> _updateBio(String newBio) async {
    try {
      final userId = widget.userId ?? FirebaseService.currentUser?.uid;
      if (userId == null) return;

      await FirebaseService.firestore.collection('users').doc(userId).update({
        'bio': newBio,
      });

      setState(() {
        _userFuture =
            FirebaseService.firestore.collection('users').doc(userId).get();
      });
      // Show success messag
      ToastUtils.showSuccessToast('Bio updated successfully!');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update bio: ${e.toString()}')),
      );
    }
  }

  void _showBioEditModal(BuildContext context, String currentBio) {
    _bioController.text = currentBio;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                const Text(
                  'Edit Bio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'instrument sans',
                  ),
                ),
                const SizedBox(height: 16),

                // Text field
                TextField(
                  controller: _bioController,
                  maxLines: 4,
                  maxLength: 50,
                  decoration: InputDecoration(
                    hintText: 'Tell something about yourself...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _updateBio(_bioController.text);
                    },
                    child: const Text(
                      'Save Bio',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'jumper',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.userId ?? FirebaseService.currentUser?.uid;
    if (userId == null) return Center(child: Text('Please log in'));

    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<DocumentSnapshot>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final user = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                expandedHeight: 170,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      if (user['coverImage'] != null &&
                          user['coverImage'] != '')
                        Image.asset(
                          user['coverImage'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150,
                        ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(
                                user['profileImage'] ?? '',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          user['username'] ?? '',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'instrument sans',
                            fontSize: 28.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '@${user['userUniq'] ?? 'userhandle'}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'instrument sans',
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          user['bio'],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'instrument sans'),
                        ),
                        SizedBox(height: 20),

                        SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.greenAccent.shade200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            onPressed: () {
                              _showBottomModal(context, user['bio'] ?? '');
                            },
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.settings,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Snuggle Settings',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'jumper',
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStat(
                              'Following',
                              user['followingCount'] ?? 0,
                            ),
                            _buildStat('Followers', user['followerCount'] ?? 0),
                            _buildStat('Twinkles', user['postCount'] ?? 0),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBottomModal(BuildContext context, String currentBio) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Change Bio Button
              SizedBox(
                height: 70,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF1F1F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showBioEditModal(context, currentBio);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 25, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Change Bio',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'jumper',
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 70,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF1F1F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _logout();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 25, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'jumper',
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'instrument sans bold',
            fontSize: 16.0,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.pinkAccent,
            fontFamily: 'instrument sans',
          ),
        ),
      ],
    );
  }
}
