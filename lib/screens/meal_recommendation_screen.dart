import 'package:flutter/material.dart';
import 'meal_detail_screen.dart';

class MealRecommendationScreen extends StatelessWidget {
  const MealRecommendationScreen({super.key});

  final List<Map<String, dynamic>> mockMeals = const [
    {
      'name': '닭가슴살 샐러드',
      'description': '고단백 + 저탄수화물',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': '귀리 현미밥과 생선구이',
      'description': '혈당 안정에 좋은 전통식',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': '두부 버섯 스튜',
      'description': '채식 기반 저혈당 식단',
      'image': 'https://via.placeholder.com/150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('추천 식사 목록')),
      body: ListView.builder(
        itemCount: mockMeals.length,
        itemBuilder: (context, index) {
          final meal = mockMeals[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: Image.network(meal['image'], width: 60, height: 60),
              title: Text(meal['name']),
              subtitle: Text(meal['description']),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MealDetailScreen(mealName: meal['name']),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
