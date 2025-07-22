/*
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
*/

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
      backgroundColor: const Color(0xFFF4F4F4),
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
      body: FutureBuilder<List<Recommendation>>(
        future: futureRecommendations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '에러 발생: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                '추천 식단이 없습니다.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          } else {
            final recommendations = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        '탄수화물: ${rec.nutrition['carbs']}g\n예상 혈당 영향: ${rec.expectedGlucoseImpact}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                    trailing: Text(
                      rec.foodGroup,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
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
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
