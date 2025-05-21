import 'package:flutter/material.dart';
import 'package:quitespace/screens/home/discover_screen.dart';
import 'package:quitespace/screens/home/feed_screen.dart';
import 'package:quitespace/screens/notifications/notification_screen.dart';
import 'package:quitespace/screens/post/create_post_screen.dart';
import 'package:quitespace/screens/profile/profile_screen.dart';
import 'package:quitespace/services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    FeedScreen(),
    DiscoverScreen(),
    CreatePostScreen(),
    NotificationsScreen(),
    ProfileScreen(userId: FirebaseService.currentUser?.uid),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreatePostScreen()),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}