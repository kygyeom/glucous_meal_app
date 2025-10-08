/*
import 'package:flutter/material.dart';
import 'free_trial_notification_screen.dart';

class BetaTestCodeScreen extends StatefulWidget {
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String activityLevel;
  final String goal;
  final String diabetes;
  final List<String> meals;
  final String mealMethod;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final double? averageGlucose;

  const BetaTestCodeScreen({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
    required this.diabetes,
    required this.meals,
    required this.mealMethod,
    required this.dietaryRestrictions,
    required this.allergies,
    required this.averageGlucose,
  });

  @override
  State<BetaTestCodeScreen> createState() => _BetaTestCodeScreen();
}

class _BetaTestCodeScreen extends State<BetaTestCodeScreen> {
  final TextEditingController codeController = TextEditingController();

  Widget buildProgressBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildProgressBar(context),
            const SizedBox(height: 32),

            // Title
            const Text(
              'Welcome to the Beta Program!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'If you’ve received a free trial code\nas one of our beta testers,\nplease enter it below to continue.',
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Code input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Your Code',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      hintText: 'Type your beta code here',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FreeTrialNotificationScreen(
                            name: widget.name,
                            age: widget.age,
                            gender: widget.gender,
                            weight: widget.weight,
                            height: widget.height,
                            activityLevel: widget.activityLevel,
                            goal: widget.goal,
                            diabetes: widget.diabetes,
                            meals: widget.meals,
                            mealMethod: widget.mealMethod,
                            dietaryRestrictions: widget.dietaryRestrictions,
                            allergies: widget.allergies,
                            averageGlucose: widget.averageGlucose,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Don’t have a code?',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle code input
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00FFD1), Color(0xFF0076FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        child: const Center(
                          child: Text(
                            'Apply Code & Start Free Trial',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'free_trial_notification_screen.dart';

class BetaTestCodeScreen extends StatefulWidget {
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String activityLevel;
  final String goal;
  final String diabetes;
  final List<String> meals;
  final String mealMethod;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final double? averageGlucose;

  const BetaTestCodeScreen({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
    required this.diabetes,
    required this.meals,
    required this.mealMethod,
    required this.dietaryRestrictions,
    required this.allergies,
    required this.averageGlucose,
  });

  @override
  State<BetaTestCodeScreen> createState() => _BetaTestCodeScreen();
}

class _BetaTestCodeScreen extends State<BetaTestCodeScreen> {
  final TextEditingController codeController = TextEditingController();

  Widget buildProgressBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildProgressBar(context),
            const SizedBox(height: 32),

            // Title
            const Text(
              '베타 프로그램에 오신 것을 환영합니다!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                '베타 테스터로 무료 체험 코드를 받으셨다면\n아래에 코드를 입력하고\n계속 진행해 주세요.',
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Code input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '코드 입력',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      hintText: '여기에 베타 코드를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FreeTrialNotificationScreen(
                            name: widget.name,
                            age: widget.age,
                            gender: widget.gender,
                            weight: widget.weight,
                            height: widget.height,
                            activityLevel: widget.activityLevel,
                            goal: widget.goal,
                            diabetes: widget.diabetes,
                            meals: widget.meals,
                            mealMethod: widget.mealMethod,
                            dietaryRestrictions: widget.dietaryRestrictions,
                            allergies: widget.allergies,
                            averageGlucose: widget.averageGlucose,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      '코드가 없으신가요?',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle code input
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00FFD1), Color(0xFF0076FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        child: const Center(
                          child: Text(
                            '코드 적용하고 무료 체험 시작',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
