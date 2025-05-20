import 'package:flutter/material.dart';
import 'package:quitespace/constant/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This will be generated

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quite Space',
      theme: AppTheme.themeData, // Use your custom theme
      home: Scaffold(),
    );
  }
}



 