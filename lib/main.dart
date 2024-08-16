import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:doczz/features/splash_screen.dart'; // Update with your actual path
import 'package:doczz/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: SplashScreen(), // Start with SplashScreen
    );
  }
}
