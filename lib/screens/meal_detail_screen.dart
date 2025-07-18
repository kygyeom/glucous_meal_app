import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
    final String foodName;
    final String foodGroup;
    final double glucoseImpact;
    final Map<String, dynamic> nutrition;

    const MealDetailScreen({
        super.key,
        required this.foodName,
        required this.foodGroup,
        required this.glucoseImpact,
        required this.nutrition,
    });

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text(foodName)),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text('📂 그룹: $foodGroup', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 12),
                        Text('📉 혈당 영향 예상: ${glucoseImpact.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 24),
                        const Text('🍱 영양 정보', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('탄수화물: ${nutrition['carbs']}g'),
                        Text('단백질: ${nutrition['protein']}g'),
                        Text('지방: ${nutrition['fat']}g'),
                    ],
                ),
            ),
        );
    }
}
