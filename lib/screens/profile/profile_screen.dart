import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quitespace/screens/auth/login_page.dart';
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: ${e.toString()}')),
      );
    }
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
                backgroundColor: Colors.white, // Light blue background
                expandedHeight: 170,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Optional cover image
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
                                user['zodiacImage'] ?? '',
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
                            fontSize: 28.0
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '@${user['username'] ?? 'userhandle'}',
                          style: TextStyle(color: Colors.grey,fontFamily: 'instrument sans',fontSize: 20),
                        ),
                        SizedBox(height: 8),
                        Text(user['bio'], textAlign: TextAlign.center,style: TextStyle(fontFamily: 'instrument sans',),),
                        SizedBox(height: 20),

                        SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.greenAccent.shade200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12.0,
                                ), // Adjust the value as needed
                              ),
                            ),
                            onPressed: () {
                              _showBottomModal(context);
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
                                    style: TextStyle(color: Colors.black,fontFamily: 'jumper',fontSize: 15),
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
                              user['followingCount'] ?? 120,
                            ),
                            _buildStat(
                              'Followers',
                              user['followerCount'] ?? 20,
                            ),
                            _buildStat('Twinkles', user['postCount'] ?? 2),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              // Your posts list comes here
            ],
          );
          // return CustomScrollView(
          //   slivers: [
          //     SliverAppBar(
          //       expandedHeight: 60,
          //       flexibleSpace: FlexibleSpaceBar(
          //         background: Image.asset(
          //           user['coverImage'] ?? '',
          //           fit: BoxFit.cover,
          //         ),
          //       ),
          //     ),
          //     SliverToBoxAdapter(
          //       child: Padding(
          //         padding: EdgeInsets.all(16),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Row(
          //               children: [
          //                 CircleAvatar(
          //                   radius: 40,
          //                   backgroundImage: AssetImage(
          //                     user['zodiacImage'] ?? '',
          //                   ),
          //                 ),
          //                 Spacer(),
          //                 if (widget.userId != FirebaseService.currentUser?.uid)
          //                   ElevatedButton(
          //                     onPressed: () async {
          //                       await FirebaseService.toggleFollow(userId);
          //                       await _checkFollowingStatus();
          //                     },
          //                     child: Text(
          //                       _isFollowing ? 'Following' : 'Follow',
          //                     ),
          //                   ),
          //               ],
          //             ),
          //             SizedBox(height: 16),
          //             Text(
          //               user['username'],
          //               style: Theme.of(context).textTheme.headlineSmall,
          //             ),
          //             if (user['bio'] != null) ...[
          //               SizedBox(height: 8),
          //               Text(user['bio']),
          //             ],
          //             SizedBox(height: 16),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceAround,
          //               children: [
          //                 Column(
          //                   children: [
          //                     Text(user['postCount']?.toString() ?? '0'),
          //                     Text('Posts'),
          //                   ],
          //                 ),
          //                 Column(
          //                   children: [
          //                     Text(user['followerCount']?.toString() ?? '0'),
          //                     Text('Followers'),
          //                   ],
          //                 ),
          //                 Column(
          //                   children: [
          //                     Text(user['followingCount']?.toString() ?? '0'),
          //                     Text('Following'),
          //                   ],
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // );
        },
      ),
    );
  }

  void _showBottomModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,

      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Important for bottom sheet
            children: [
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
                    Navigator.pop(context); // Close modal
                    // Add your change bio logic here
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 25, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Change Bio', style: TextStyle(color: Colors.black,fontFamily: 'jumper',fontSize: 15)),
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
                    _logout(); // Call the logout function
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 25, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.black,fontFamily: 'jumper',fontSize: 15)),
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
}

Widget _buildStat(String label, int value) {
  return Column(
    children: [
      Text('$value', style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'instrument sans bold',
                            fontSize: 16.0
                          ),),
      Text(label, style: TextStyle(color: Colors.pinkAccent, fontFamily: 'instrument sans',)),
    ],
  );
}
