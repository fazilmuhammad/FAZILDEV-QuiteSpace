import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:quitespace/services/firebase_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseService.auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>?;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseService.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(_userData!['zodiacImage'] ?? 'assets/default_profile.png'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Username: ${_userData!['username']}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('Email: ${_userData!['email']}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('Birth Date: ${_userData!['birthDate']}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('Zodiac Sign: ${_userData!['zodiacSign']}', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
    );
  }
}