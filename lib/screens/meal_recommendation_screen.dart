import 'package:flutter/material.dart';
import 'package:glucous_meal_app/models/models.dart';
import 'package:glucous_meal_app/services/api_service.dart';
import 'meal_detail_screen.dart';
import 'onboarding_screen.dart';

class MealRecommendationScreen extends StatefulWidget {
  final UserProfile userProfile;

  const MealRecommendationScreen({super.key, required this.userProfile});

  @override
  State<MealRecommendationScreen> createState() =>
      _MealRecommendationScreenState();
}

class _MealRecommendationScreenState extends State<MealRecommendationScreen> {
  late Future<List<Recommendation>> futureRecommendations;

  @override
  void initState() {
    super.initState();
    futureRecommendations = fetchRecommendations(widget.userProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          '추천 식단',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Recommendation>>(
              future: futureRecommendations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  debugPrint('❗에러 발생: ${snapshot.error}');
                  debugPrint('📌 스택 트레이스: ${snapshot.stackTrace}');
                  return Center(
                    child: Text(
                      '에러 발생: ${snapshot.error}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      '추천 식단이 없습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                } else {
                  final recommendations = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      final rec = recommendations[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          title: Text(
                            rec.foodName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "탄수화물: ${rec.nutrition['carbs']}g\n"
                              "단백질: ${rec.nutrition['protein']}g\n지방: ${rec.nutrition['fat']}g\n"
                              "식이섬유: ${rec.nutrition['fiber']}g\n"
                              "나트륨: ${rec.nutrition['sodium_mg'] != null ? "${rec.nutrition['sodium_mg']}mg" : "정보없음"}\n"
                              "예상 혈당 변화량: ${rec.expectedDeltaG}mg/dl\n"
                              "예상 식후 최고 혈당: ${rec.expectedGMax}mg/dl\n",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          trailing: Text(
                            "${(rec.price + rec.shippingFee).toInt()}원 (배송비 포함)",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MealDetailScreen(
                                  foodName: rec.foodName,
                                  foodGroup: rec.foodGroup,
                                  // TODO: Fix this
                                  glucoseImpact: 10,
                                  nutrition: rec.nutrition,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                    (route) => false, // 기존의 모든 라우트 제거
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  '처음부터 다시하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
