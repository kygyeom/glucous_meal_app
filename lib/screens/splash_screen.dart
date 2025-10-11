import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:glucous_meal_app/services/api_service.dart';
import 'package:glucous_meal_app/screens/onboarding_screen.dart';
import 'package:glucous_meal_app/screens/main.dart' as main_screen;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final userExists = await ApiService.checkUserExists();

      if (!mounted) return;

      if (userExists) {
        final profile = await ApiService.fetchUserProfile();
        final username = profile?.name ?? 'User';

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => main_screen.Main(username: username),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AbsorbPointer(
        absorbing: true,
        child: SizedBox.expand(
          child: Stack(
            children: [
              // 중앙 로고 + 텍스트
              Center(
                child: RepaintBoundary(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/glucous_logo.png',
                        width: 120,
                        height: 120,
                        cacheWidth: 360, // 120 * 3 for 3x density
                        cacheHeight: 360,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'GlucoUS',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 하단 스피너
              const Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: RepaintBoundary(
                  child: SpinKitCircle(color: Color(0xFF00FFD1), size: 36.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
