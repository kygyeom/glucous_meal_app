import 'package:flutter/material.dart';
import 'package:glucous_meal_app/models/models.dart';
import 'meal_recommendation_screen.dart';
import 'dart:math' as math;

class SummaryScreen extends StatelessWidget {
    final UserProfile userProfile;

    const SummaryScreen({super.key, required this.userProfile});

    double get bmi => userProfile.bmi;

    double get bmr {
        if (userProfile.gender == 'M') {
            return 66.5 + (13.75 * weight) + (5.003 * height) - (6.75 * userProfile.age);
        } else {
            return 655.1 + (9.563 * weight) + (1.850 * height) - (4.676 * userProfile.age);
        }
    }

    double get maintenanceCalories {
        switch (userProfile.activityLevel) {
            case 'low':
                return bmr * 1.2;
            case 'high':
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

    double get height => _estimateHeightFromBMI(); // 임시 키 추정

    double get weight => _estimateWeightFromBMI();

double _estimateHeightFromBMI() {
    return math.sqrt(weight / bmi) * 100;
}

double _estimateWeightFromBMI() {
    return bmi * math.pow(1.70, 2); // 대략 170cm 기준
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

                        const Text('전달받은 유저 정보:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                        const SizedBox(height: 12),
                        Text('나이: ${userProfile.age}'),
                        Text('성별: ${userProfile.gender}'),
                        Text('BMI: ${userProfile.bmi.toStringAsFixed(1)}'),
                        Text('활동 수준: ${userProfile.activityLevel}'),
                        Text('건강 목표: ${userProfile.goal}'),
                        Text('당뇨병 유무: ${userProfile.diabetes}'),
                        Text('주 식사 시간: ${userProfile.meals.join(", ")}'),
                        Text('식사 방식: ${userProfile.mealMethod}'),
                        Text('식사 제약: ${userProfile.dietaryRestrictions.join(", ")}'),
                        Text('알레르기: ${userProfile.allergies.join(", ")}'),

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
                                    child: const Text('추천 식단 보기'),
                                    onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                        MealRecommendationScreen(userProfile: userProfile),
                                            ),
                                        );
                                    },
                                ),
                            ),
                    ],
                ),
            ),
        );
    }
}
