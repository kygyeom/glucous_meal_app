import 'package:flutter/material.dart';
import 'user_profile_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding_bg.png', // ← 파일 경로에 맞게 수정
              fit: BoxFit.cover,
            ),
          ),
          // 어두운 오버레이
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          // 내용
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 36,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        const LinearGradient(
                          begin: Alignment.topLeft, // ← ↘ 대각선 시작점
                          end: Alignment.bottomRight, // ← ↘ 대각선 끝점
                          colors: [Color(0xFF0076FF), Color(0xFF00FFD1)],
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                    child: const Text(
                      'Welcome to GlucoUS!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // 무시됨
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '당신의 식사가 더 이상 고민이 되지 않도록,\n당뇨를 위한 맞춤 식단과 혈당 예측을 한 곳에서.\nGlucoUS와 함께 건강한 식생활을 시작해보세요.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserProfileScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FFD1), Color(0xFF0076FF)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            '시작하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
