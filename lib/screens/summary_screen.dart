import 'package:flutter/material.dart';
import 'package:glucous_meal_app/models/models.dart';
import 'meal_recommendation_screen.dart';
import 'dart:math' as math;

const Map<String, String> mealTranslations = {
  'Breakfast': '아침',
  'Lunch': '점심',
  'Dinner': '저녁',
  'Snacks': '간식',
};

const Map<String, String> mealMethodTranslations = {
  'Direct cooking': '직접 요리',
  'Eating out': '외식',
  'Delivery based': '배달 위주',
};

const Map<String, String> diabetesTranslations = {
  'type1': '제1형 당뇨',
  'type2': '제2형 당뇨',
  'none': '없음',
};

const Map<String, String> dietaryRestrictionTranslations = {
  'Vegetarian': '채식',
  'Halal': '할랄',
  'Gluten-free': '글루텐 프리',
  'None': '제한 없음',
};

const Map<String, String> allergyTranslations = {
  'None': '없음',
  'Dairy': '유제품',
  'Nuts': '견과류',
  'Shellfish': '갑각류',
  'Meat': '고기',
  'Seafood': '해산물',
  'Other': '기타',
};

const Map<String, String> activityTranslations = {
  'low': '주로 앉아서 생활',
  'medium': '주 1회 이상 운동',
  'high': '주 3회 이상 운동',
};

const Map<String, String> goalTranslations = {
  'weight_loss': '체중 감량',
  'balanced': '균형 잡힌 식단',
  'blood_sugar_control': '혈당 조절',
};

class SummaryScreen extends StatelessWidget {
  final UserProfile userProfile;

  const SummaryScreen({super.key, required this.userProfile});

  String _translate(String english, String type) {
    switch (type) {
      case 'meal':
        return mealTranslations[english] ?? english;
      case 'meal method':
        return mealMethodTranslations[english] ?? english;
      case 'diabetes':
        return diabetesTranslations[english] ?? english;
      case 'dietary':
        return dietaryRestrictionTranslations[english] ?? english;
      case 'allergy':
        return allergyTranslations[english] ?? english;
      case 'activity':
        return activityTranslations[english] ?? english;
      case 'goal':
        return goalTranslations[english] ?? english;
      default:
        return english;
    }
  }

  double get bmi => userProfile.bmi;

  double get bmr {
    if (userProfile.gender == 'M') {
      return 66.5 +
          (13.75 * weight) +
          (5.003 * height) -
          (6.75 * userProfile.age);
    } else {
      return 655.1 +
          (9.563 * weight) +
          (1.850 * height) -
          (4.676 * userProfile.age);
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

  double get height => _estimateHeightFromBMI();
  double get weight => _estimateWeightFromBMI();

  double _estimateHeightFromBMI() {
    return math.sqrt(weight / bmi) * 100;
  }

  double _estimateWeightFromBMI() {
    return bmi * math.pow(1.70, 2);
  }

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
            flex: 8, // 전체의 약 80% 차지
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.8, // 진행도 (예: 0.25)
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            buildProgressBar(context),
            const Text(
              '당신의 건강 요약 정보입니다',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildInfoRow('나이', '${userProfile.age}세'),
            _buildInfoRow('성별', userProfile.gender == 'M' ? '남성' : '여성'),
            _buildInfoRow(
              '활동 수준',
              _translate(userProfile.activityLevel, 'activity'),
            ),
            _buildInfoRow('건강 목표', _translate(userProfile.goal, 'goal')),
            _buildInfoRow(
              '당뇨병 유무',
              _translate(userProfile.diabetes, 'diabetes'),
            ),
            _buildInfoRow('최근 평균 혈당', '${userProfile.averageGlucose}'),
            _buildInfoRow('BMI', '${bmi.toStringAsFixed(1)} ($bmiComment)'),
            _buildInfoRow('기초 대사량 (BMR)', '${bmr.toStringAsFixed(0)} kcal'),
            _buildInfoRow(
              '하루 권장 섭취 칼로리',
              '${maintenanceCalories.toStringAsFixed(0)} kcal',
            ),
            const SizedBox(height: 24),
            const Text(
              '기타 입력 정보',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              '주 식사 시간',
              userProfile.meals.map((m) => _translate(m, 'meal')).join(', '),
            ),
            _buildInfoRow(
              '식사 방식',
              _translate(userProfile.mealMethod, 'meal method'),
            ),
            _buildInfoRow(
              '식사 제약',
              userProfile.dietaryRestrictions
                  .map((r) => _translate(r, 'dietary'))
                  .join(', '),
            ),
            _buildInfoRow(
              '알레르기',
              userProfile.allergies
                  .map((a) => _translate(a, 'allergy'))
                  .join(', '),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              '이 정보를 기반으로 당신에게 적합한 식단을 추천해드릴게요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: remove this
                  debugPrint('🔍 userProfile 정보: ${userProfile.averageGlucose}', wrapWidth: 1024);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MealRecommendationScreen(userProfile: userProfile),
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
                  '추천 식단 보기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
