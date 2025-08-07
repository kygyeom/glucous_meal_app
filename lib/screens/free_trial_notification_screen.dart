import 'package:flutter/material.dart';
import 'subscription_offer_screen.dart';

class FreeTrialNotificationScreen extends StatefulWidget {
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

  const FreeTrialNotificationScreen({
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
  State<FreeTrialNotificationScreen> createState() => _FreeTrialNotificationScreen();
}

class _FreeTrialNotificationScreen extends State<FreeTrialNotificationScreen> {
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
            flex: 8,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 1.0,
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

  Widget buildStep(String title, String description, Color circleColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            buildProgressBar(context),
            const SizedBox(height: 16),

            // 제목
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Text(
                  '무료체험이 종료되기전에\n알림으로 알려드릴게요',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 안내 내용
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  buildStep('오늘', '모든 기능을 무제한으로 체험해 보세요', Colors.grey.shade400),
                  const SizedBox(height: 20),
                  buildStep('3주 후 - 알림', '무료체험 기간이 곧 끝난다고 알려 드릴게요', Colors.grey.shade600),
                  const SizedBox(height: 20),
                  buildStep(
                    '4주 후 - 결제 시작',
                    '무료체험을 즐겨보세요! 결제일 전에 취소하면 요금이 청구되지 않습니다.',
                    Colors.black,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 하단 고정 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '결제전 알림을 보내드릴게요!',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubscriptionOfferScreen(
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
                            '무료로 계속하기',
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
                  const SizedBox(height: 12), // 바닥 여유
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
