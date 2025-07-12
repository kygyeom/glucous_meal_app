import 'package:flutter/material.dart';
import 'package:glucous_meal_app/models/models.dart';
import 'package:glucous_meal_app/services/api_service.dart';
import 'meal_detail_screen.dart';

class MealRecommendationScreen extends StatefulWidget {
  final UserProfile userProfile;

  const MealRecommendationScreen({super.key, required this.userProfile});

  @override
  State<MealRecommendationScreen> createState() => _MealRecommendationScreenState();
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
      appBar: AppBar(title: const Text('추천 식단')),
      body: FutureBuilder<List<Recommendation>>(
        future: futureRecommendations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('추천 식단이 없습니다.'));
          } else {
            final recommendations = snapshot.data!;
            return ListView.builder(
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final rec = recommendations[index];
                return ListTile(
                  title: Text(rec.foodName),
                  subtitle: Text('탄수화물: ${rec.nutrition['carbs']}g / 예상 혈당 영향: ${rec.expectedGlucoseImpact}'),
                  trailing: Text(rec.foodGroup),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealDetailScreen(
                          foodName: rec.foodName,
                          foodGroup: rec.foodGroup,
                          glucoseImpact: rec.expectedGlucoseImpact,
                          nutrition: rec.nutrition,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
