import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quitespace/screens/auth/login_page.dart';
import 'package:quitespace/screens/home/home_screen.dart';


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomeScreen(); // Your main app page after login
        } else {
          return LoginPage();
        }
      },
    );
  }
}