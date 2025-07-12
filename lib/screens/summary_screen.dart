import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  // 예시값. 실제론 이전 화면에서 입력받은 값을 전달받아야 함.
  final double heightCm = 170;
  final double weightKg = 65;
  final int age = 28;
  final String gender = '남성';
  final String activityLevel = '중간';

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  double get bmr {
    if (gender == '남성') {
      return 66.5 + (13.75 * weightKg) + (5.003 * heightCm) - (6.75 * age);
    } else {
      return 655.1 + (9.563 * weightKg) + (1.850 * heightCm) - (4.676 * age);
    }
  }

  double get maintenanceCalories {
    switch (activityLevel) {
      case '낮음':
        return bmr * 1.2;
      case '높음':
        return bmr * 1.725;
      default:
        return bmr * 1.55;
    }
  }

  String get bmiComment {
    if (bmi < 18.5) return '체중이 부족해요';
    if (bmi < 23) return '정상 체중이에요';
    if (bmi < 25) return '과체중이에요';
    return '비만 상태예요';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('건강 정보 요약')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '당신의 BMI는 ${bmi.toStringAsFixed(1)} 입니다.',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(bmiComment, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 24),
            Text(
              '기초 대사량 (BMR): ${bmr.toStringAsFixed(0)} kcal',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '하루 권장 섭취 칼로리: ${maintenanceCalories.toStringAsFixed(0)} kcal',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              '이 정보를 기반으로\n당신에게 적합한 식단을 추천해드릴게요.',
              style: TextStyle(fontSize: 18),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 식단 추천 화면으로 이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('식단 추천은 다음 단계에서 구현됩니다')),
                  );
                },
                child: const Text('식단 추천받기'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
