import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Configure image cache to prevent buffer overflow on Android
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MB
  PaintingBinding.instance.imageCache.maximumSize = 100; // 100 images

  runApp(const GlucoUSApp());
}

class GlucoUSApp extends StatelessWidget {
  const GlucoUSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlucoUS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSans',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          foregroundColor: Colors.black,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
