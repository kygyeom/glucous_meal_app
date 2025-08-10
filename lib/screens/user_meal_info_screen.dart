// 파일: lifestyle_meal_screen.dart
import 'package:flutter/material.dart';
import 'user_meal_condition_screen.dart';

class UserMealInfoScreen extends StatefulWidget {
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String activityLevel;
  final String goal;
  final String diabetes;

  const UserMealInfoScreen({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
    required this.diabetes,
  });

  @override
  State<UserMealInfoScreen> createState() => _UserMealInfoScreenState();
}

class _UserMealInfoScreenState extends State<UserMealInfoScreen> {
  List<String> selectedMeals = ['Lunch', 'Dinner'];
  String selectedMealMethod = 'Direct cooking';

  void toggleMeal(String meal) {
    setState(() {
      if (selectedMeals.contains(meal)) {
        if (selectedMeals.length == 1) return;
        selectedMeals.remove(meal);
      } else {
        selectedMeals.add(meal);
      }
    });
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
            flex: 8,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.4,
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            buildProgressBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  const Text(
                    '평소에 식사는 어떻게 하시나요?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  const Text('주 식사 시간'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 3,
                    children: [
                      buildChip('아침', '🍳'),
                      buildChip('점심', '🥗'),
                      buildChip('저녁', '🍽️'),
                      buildChip('간식', '🍪'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('주된 식사 방식'),
                  const SizedBox(height: 4),
                  Wrap(
                    children: ['직접 요리', '외식', '배달 위주']
                        .map((method) => buildChip(
                              method == '직접 요리'
                                  ? 'Direct cooking'
                                  : method == '외식'
                                      ? 'Eating out'
                                      : 'Delivery based',
                              null,
                              label: method,
                              isMethod: true,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserMealConditionScreen(
                          name: widget.name,
                          age: widget.age,
                          gender: widget.gender,
                          height: widget.height,
                          weight: widget.weight,
                          activityLevel: widget.activityLevel,
                          goal: widget.goal,
                          diabetes: widget.diabetes,
                          meals: selectedMeals,
                          mealMethod: selectedMealMethod,
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
                        '다음 페이지',
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

  Widget buildChip(String value, String? emoji, {String? label, bool isMethod = false}) {
    final bool selected = isMethod
        ? selectedMealMethod == value
        : selectedMeals.contains(value);
    return GestureDetector(
      onTap: () => setState(() {
        if (isMethod) {
          selectedMealMethod = value;
        } else {
          toggleMeal(value);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Color(0xFFF4F4F4) : Colors.grey[200],
          border: Border.all(color: selected ? Colors.black : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null)
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Text(emoji, style: const TextStyle(fontSize: 14)),
              ),
            if (emoji != null) const SizedBox(width: 8),
            Text(
              label ?? value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
