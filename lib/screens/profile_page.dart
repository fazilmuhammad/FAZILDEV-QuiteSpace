import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quitespace/services/firebase_service.dart';
import 'auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseService.auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseService.firestore
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>? ?? {};
          setState(() {
            _userData = data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _userData = {};
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data: ${e.toString()}')),
      );
    }
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
          : _hasError
              ? Center(child: Text('Error loading profile data'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _getProfileImage(),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildProfileItem('Username', _userData?['username']),
                      SizedBox(height: 10),
                      _buildProfileItem('Email', _userData?['email'] ?? FirebaseService.auth.currentUser?.email),
                      SizedBox(height: 10),
                      _buildProfileItem('Birth Date', _userData?['birthDate']),
                      SizedBox(height: 10),
                      _buildProfileItem('Zodiac Sign', _userData?['zodiacSign']),
                      SizedBox(height: 20),
                      if (_userData?.isEmpty ?? true)
                        Center(
                          child: Text(
                            'Profile information not found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  ImageProvider _getProfileImage() {
    // Check for zodiacImage first
    if (_userData?['zodiacImage'] != null) {
      return AssetImage(_userData!['zodiacImage']);
    }
    // Then check for coverImage if needed
    if (_userData?['coverImage'] != null) {
      return AssetImage(_userData!['coverImage']);
    }
    // Default image
    return AssetImage('assets/zodiac/default_profile.png');
  }

  Widget _buildProfileItem(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value ?? 'Not specified',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}