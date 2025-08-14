import 'package:flutter/material.dart';
import 'beta_test_code_screen.dart';

class FoodExchangeTestScreen extends StatefulWidget {
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

  const FoodExchangeTestScreen({
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
  State<FoodExchangeTestScreen> createState() => _FoodExchangeTestScreen();
}

class _FoodExchangeTestScreen extends State<FoodExchangeTestScreen> {
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
                widthFactor: 0.8,
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
                  '마음에 드는 식재료로\n교환하기',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 테두리 박스
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: IgnorePointer(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '식재료 교환하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 재료 태그
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _IngredientChip(icon: '🍚', label: '현미밥'),
                            SizedBox(width: 8),
                            _IngredientChip(icon: '🍗', label: '닭가슴살'),
                            SizedBox(width: 8),
                            _IngredientChip(icon: '🥬', label: '브로콜리'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 카드 2개 (같은 크기, 화면 가로 채움)
                        Row(
                          children: const [
                            Expanded(
                              child: _FoodCard(
                                title: 'Grilled Chicken',
                                calories: '350',
                                carbs: '40g',
                                highlighted: true,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _FoodCard(
                                title: 'Prawn mix salad',
                                calories: '350',
                                carbs: '40g',
                                highlighted: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 48,
                child: ElevatedButton(
                  clipBehavior: Clip.antiAlias, // ⬅️ 버튼 경계 밖으로 안 나가게
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24), // 버튼 모양
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.25),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BetaTestCodeScreen(
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
                        '식단 교환하기',
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

class _IngredientChip extends StatelessWidget {
  final String icon;
  final String label;

  const _IngredientChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Text(icon, style: const TextStyle(fontSize: 16)),
      label: Text(label),
      backgroundColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final String title;
  final String calories;
  final String carbs;
  final bool highlighted;

  const _FoodCard({
    required this.title,
    required this.calories,
    required this.carbs,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: highlighted ? Colors.grey.shade300 : Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Calories  $calories'),
          Text('Carb       $carbs'),
          const SizedBox(height: 12),
          if (highlighted)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '더 알아보기',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
