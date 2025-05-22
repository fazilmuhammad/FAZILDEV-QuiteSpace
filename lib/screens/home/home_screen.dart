import 'package:flutter/material.dart';
import 'package:quitespace/screens/home/feed_screen.dart';
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

       bottomNavigationBar:      BottomNavigationBar(
               currentIndex: _currentIndex,
        onTap: (index) {
            setState(() => _currentIndex = index);
          
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items:  [
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: _currentIndex == 0 ? Color(0xFFA7EFC1) : Colors.white,
              child: Icon(Icons.home_outlined, color: Colors.black),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: _currentIndex == 1 ? Color(0xFFF6D6D6) : Colors.white,
              child: Icon(Icons.person_outline, color: Colors.black),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon:  CircleAvatar(
              backgroundColor: _currentIndex == 2 ? Color(0xFF91E5F6) : Colors.white,
              child: Icon(Icons.add, color: Colors.black),
            ),
            label: '',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   onTap: (index) {
      //       setState(() => _currentIndex = index);
          
      //   },
      //   type: BottomNavigationBarType.fixed,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //            BottomNavigationBarItem(
      //       icon: Icon(Icons.add),
      //       label: 'Create',
      //     ),
      //   ],
      // ),
    );
  }
}