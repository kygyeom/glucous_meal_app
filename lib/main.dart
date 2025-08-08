import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const GlucoUSApp());
}

class GlucoUSApp extends StatelessWidget {
  const GlucoUSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlucoUS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'NotoSans'),
      home: OnboardingScreen(),
    );
  }
}
