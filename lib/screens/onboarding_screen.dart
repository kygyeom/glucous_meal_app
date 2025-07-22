/*
import 'package:flutter/material.dart';
import 'user_info_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Widget buildProgressBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Spacer(flex: 1), // 10% 여백
          Expanded(
            flex: 8, // 전체의 약 80% 차지
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.2, // 진행도 (예: 0.25)
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(flex: 1), // 나머지 10% 여백
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            buildProgressBar(context), // ✅ 항상 상단 고정
            SizedBox(height: screenHeight * 0.02),
            const Text(
              'Personalized Blood Sugar\nControl with Food Freedom',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            SizedBox(height: screenHeight * 0.035),
            Container(
              height: screenHeight * 0.22,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Healthy food illustrations',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personalized Meal Suggestions',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tailored to your lifestyle and health goals.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Note',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 40, height: 40, color: Color(0xFFF4F4F4)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'This service provides general wellness information and is not a medical service for diagnosis or treatment. Please consult a healthcare professional if you have any specific medical concerns.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserInfoScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'user_info_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Widget buildProgressBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Spacer(flex: 1),
          Expanded(
            flex: 8,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            buildProgressBar(context),
            SizedBox(height: screenHeight * 0.02),
            const Text(
              '자유로운 식사로\n개인 맞춤 혈당 관리',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            SizedBox(height: screenHeight * 0.035),
            Container(
              height: screenHeight * 0.22,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '건강한 식단 이미지',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '개인 맞춤 식사 추천',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '당신의 라이프스타일과 건강 목표에 맞게 설계됩니다.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '알림',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 40, height: 40, color: Color(0xFFF4F4F4)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '이 서비스는 일반적인 건강 정보 제공을 목적으로 하며, 진단이나 치료를 위한 의학 서비스가 아닙니다. 구체적인 건강 문제가 있을 경우 전문가와 상담하세요.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserInfoScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  '계속하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}
