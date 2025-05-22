import 'package:flutter/material.dart';
import 'package:quitespace/screens/home/discover_screen.dart';
import 'package:quitespace/screens/home/feed_screen.dart';
import 'package:quitespace/screens/notifications/notification_screen.dart';
import 'package:quitespace/screens/post/create_post_screen.dart';
import 'package:quitespace/screens/profile/profile_screen.dart';
import 'package:quitespace/services/firebase_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;

  final List<Widget> _screens = [
    FeedScreen(),
    ProfileScreen(userId: FirebaseService.currentUser?.uid),
    CreatePostScreen(),
    // DiscoverScreen(),
     // Placeholder for CreatePostScreen
    // NotificationsScreen(),
    
  ];

  Future<void> _navigateToCreatePost(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreatePostScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to open post creation: $e',
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _navigateToCreatePost(context);
          } else {
            setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
                 BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create',
          ),
        ],
      ),
    );
  }
}