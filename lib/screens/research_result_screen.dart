/*
import 'package:flutter/material.dart';
import 'user_meal_info_screen.dart';

class ResearchResultScreen extends StatefulWidget {
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String activityLevel;
  final String diabetes;
  final String goal;

  const ResearchResultScreen({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.diabetes,
    required this.goal,
  });

  @override
  State<ResearchResultScreen> createState() => _ResearchResultScreenState();
}

class _ResearchResultScreenState extends State<ResearchResultScreen> {
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
                widthFactor: 0.3,
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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildProgressBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                children: [
                  SizedBox(height: screenHeight * 0.08),
                  const Text(
                    'Nutritional therapy based on the food exchange system has been shown to improve blood glucose control.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'HbA1c',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueAccent.shade100,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.transparent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Average reduction of 0.5–1.0%',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Previous Studies',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Diabetes Care, Volume 42, Issue 5, May 2019, Pages 731–754\n',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                  const Text(
                    'Meng, Yan et al. Diabetes Research and Clinical Practice 131 (2017): 124–131.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '※ This information is based on general research findings and individual results may vary. '
                    'For medical decisions, please consult with a healthcare professional.',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserMealInfoScreen(
                          name: widget.name,
                          age: widget.age,
                          gender: widget.gender,
                          height: widget.height,
                          weight: widget.weight,
                          activityLevel: widget.activityLevel,
                          diabetes: widget.diabetes,
                          goal: widget.goal,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
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
                        'Next',
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
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'user_meal_info_screen.dart';

class ResearchResultScreen extends StatefulWidget {
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String activityLevel;
  final String diabetes;
  final String goal;

  const ResearchResultScreen({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.diabetes,
    required this.goal,
  });

  @override
  State<ResearchResultScreen> createState() => _ResearchResultScreenState();
}

class _ResearchResultScreenState extends State<ResearchResultScreen> {
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
                widthFactor: 0.3,
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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildProgressBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                children: [
                  SizedBox(height: screenHeight * 0.08),
                  const Text(
                    '식품교환표에 기반한 영양 치료는 혈당 조절을 개선하는 데 효과가 있는 것으로 보고되었습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '당화혈색소(HbA1c)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueAccent.shade100,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.transparent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '평균 0.5–1.0% 감소',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '선행 연구',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Diabetes Care, 42권 5호, 2019년 5월, 731–754쪽\n',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                  const Text(
                    'Meng, Yan 외. Diabetes Research and Clinical Practice, 131권 (2017): 124–131쪽.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '※ 본 정보는 일반적인 연구 결과를 바탕으로 하며, 개인별 결과는 다를 수 있습니다. '
                    '의학적 의사결정은 반드시 의료 전문가와 상담하세요.',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserMealInfoScreen(
                          name: widget.name,
                          age: widget.age,
                          gender: widget.gender,
                          height: widget.height,
                          weight: widget.weight,
                          activityLevel: widget.activityLevel,
                          diabetes: widget.diabetes,
                          goal: widget.goal,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
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
                        '다음',
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
            ),
          ],
        ),
      ),
    );
  }
}
