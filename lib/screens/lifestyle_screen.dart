/*
import 'package:flutter/material.dart';
import 'package:glucous_meal_app/models/models.dart';
import 'summary_screen.dart';

class LifestyleScreen extends StatefulWidget {
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String activityLevel;
  final String goal;
  final String diabetes;

  const LifestyleScreen({
    super.key,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
    required this.diabetes, // ← 이 줄 추가
  });

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  final _formKey = GlobalKey<FormState>();

  List<String> selectedMeals = [];
  String selectedMealMethod = 'Direct cooking';

  List<String> dietaryRestrictions = [
    'Vegetarian',
    'Halal',
    'Gluten-free',
    'None',
  ];
  List<String> selectedRestrictions = [];

  List<String> allergyOptions = ['None', 'Dairy', 'Nuts', 'Shellfish', 'Other'];
  List<String> selectedAllergies = [];

  bool agreedToTerms = false;

  void toggleMeal(String meal) {
    setState(() {
      if (selectedMeals.contains(meal)) {
        selectedMeals.remove(meal);
      } else {
        selectedMeals.add(meal);
      }
    });
  }

  void toggleRestriction(String item) {
    setState(() {
      if (selectedRestrictions.contains(item)) {
        selectedRestrictions.remove(item);
      } else {
        selectedRestrictions.add(item);
      }
    });
  }

  void toggleAllergy(String item) {
    setState(() {
      if (selectedAllergies.contains(item)) {
        selectedAllergies.remove(item);
      } else {
        selectedAllergies.add(item);
      }
    });
  }

  void submitData() {
    // BMI 계산
    final double bmi =
        widget.weight / ((widget.height / 100) * (widget.height / 100));

    final profile = UserProfile(
      age: widget.age,
      gender: widget.gender == '남성' ? 'M' : 'F',
      weight: widget.weight,
      height: widget.height,
      bmi: bmi,
      activityLevel: widget.activityLevel == '낮음'
          ? 'low'
          : widget.activityLevel == '높음'
          ? 'high'
          : 'medium',
      goal: widget.goal == '체중 감량'
          ? 'weight_loss'
          : widget.goal == '균형 잡힌 식단'
          ? 'balanced'
          : 'blood_sugar_control',
      diabetes: widget.diabetes == '없음'
          ? 'none'
          : widget.diabetes == '제1형 당뇨'
          ? 'type1'
          : 'type2',
      meals: selectedMeals,
      mealMethod: selectedMealMethod,
      dietaryRestrictions: selectedRestrictions,
      allergies: selectedAllergies,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(userProfile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('라이프스타일 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                '이 정보를 기반으로 당신에게 맞는 식단을 추천합니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),
              const Text('🍳 주 식사 시간'),
              Wrap(
                spacing: 8.0,
                children: ['Breakfast', 'Lunch', 'Dinner', 'Snacks'].map((
                  meal,
                ) {
                  return FilterChip(
                    label: Text(meal),
                    selected: selectedMeals.contains(meal),
                    onSelected: (_) => toggleMeal(meal),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              const Text('주된 식사 방식'),
              DropdownButtonFormField<String>(
                value: selectedMealMethod,
                items: ['Direct cooking', 'Eating out', 'Delivery based']
                    .map(
                      (method) =>
                          DropdownMenuItem(value: method, child: Text(method)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedMealMethod = val!),
                decoration: const InputDecoration(
                  labelText: 'How do you acquire meals?',
                ),
              ),

              const SizedBox(height: 24),
              const Text('🥕 식사 제약 조건'),
              Wrap(
                spacing: 8.0,
                children: dietaryRestrictions.map((item) {
                  return FilterChip(
                    label: Text(item),
                    selected: selectedRestrictions.contains(item),
                    onSelected: (_) => toggleRestriction(item),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              const Text('음식 알레르기'),
              Column(
                children: allergyOptions.map((item) {
                  return CheckboxListTile(
                    title: Text(item),
                    value: selectedAllergies.contains(item),
                    onChanged: (_) => toggleAllergy(item),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('개인정보 이용 동의'),
                value: agreedToTerms,
                onChanged: (val) =>
                    setState(() => agreedToTerms = val ?? false),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: agreedToTerms ? submitData : null,
                child: const Text('결과 확인하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:glucous_meal_app/models/models.dart';
import 'summary_screen.dart';

class LifestyleScreen extends StatefulWidget {
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String activityLevel;
  final String goal;
  final String diabetes;

  const LifestyleScreen({
    super.key,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
    required this.diabetes,
  });

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  final _formKey = GlobalKey<FormState>();

  List<String> selectedMeals = [];
  String selectedMealMethod = 'Direct cooking';

  List<String> dietaryRestrictions = [
    'Vegetarian',
    'Halal',
    'Gluten-free',
    'None',
  ];
  List<String> selectedRestrictions = [];

  List<String> allergyOptions = ['None', 'Dairy', 'Nuts', 'Shellfish', 'Other'];
  List<String> selectedAllergies = [];

  bool agreedToTerms = false;

  void toggleMeal(String meal) {
    setState(() {
      if (selectedMeals.contains(meal)) {
        selectedMeals.remove(meal);
      } else {
        selectedMeals.add(meal);
      }
    });
  }

  void toggleRestriction(String item) {
    setState(() {
      if (selectedRestrictions.contains(item)) {
        selectedRestrictions.remove(item);
      } else {
        selectedRestrictions.add(item);
      }
    });
  }

  void toggleAllergy(String item) {
    setState(() {
      if (selectedAllergies.contains(item)) {
        selectedAllergies.remove(item);
      } else {
        selectedAllergies.add(item);
      }
    });
  }

  void submitData() {
    final double bmi =
        widget.weight / ((widget.height / 100) * (widget.height / 100));

    final profile = UserProfile(
      age: widget.age,
      gender: widget.gender == '남성' ? 'M' : 'F',
      weight: widget.weight,
      height: widget.height,
      bmi: bmi,
      activityLevel: widget.activityLevel == '낮음'
          ? 'low'
          : widget.activityLevel == '높음'
          ? 'high'
          : 'medium',
      goal: widget.goal == '체중 감량'
          ? 'weight_loss'
          : widget.goal == '균형 잡힌 식단'
          ? 'balanced'
          : 'blood_sugar_control',
      diabetes: widget.diabetes == '없음'
          ? 'none'
          : widget.diabetes == '제1형 당뇨'
          ? 'type1'
          : 'type2',
      meals: selectedMeals,
      mealMethod: selectedMealMethod,
      dietaryRestrictions: selectedRestrictions,
      allergies: selectedAllergies,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(userProfile: profile),
      ),
    );
  }

  Widget buildChip({
    required String label,
    required bool selected,
    required void Function() onTap,
    String? emoji,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE6F1FB) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF5DADE2) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFFF5F5F5),
                child: Text(emoji, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? const Color(0xFF2980B9) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.6,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2980B9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
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
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children: [
              buildProgressBar(),
              const SizedBox(height: 8),
              const Text(
                '이 정보를 기반으로 당신에게 맞는 식단을 추천합니다',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text('🍽️ 주 식사 시간'),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  buildChip(
                    label: 'Breakfast',
                    emoji: '🍳',
                    selected: selectedMeals.contains('Breakfast'),
                    onTap: () => toggleMeal('Breakfast'),
                  ),
                  buildChip(
                    label: 'Lunch',
                    emoji: '🥗',
                    selected: selectedMeals.contains('Lunch'),
                    onTap: () => toggleMeal('Lunch'),
                  ),
                  buildChip(
                    label: 'Dinner',
                    emoji: '🍽️',
                    selected: selectedMeals.contains('Dinner'),
                    onTap: () => toggleMeal('Dinner'),
                  ),
                  buildChip(
                    label: 'Snacks',
                    emoji: '🍪',
                    selected: selectedMeals.contains('Snacks'),
                    onTap: () => toggleMeal('Snacks'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('주된 식사 방식'),
              const SizedBox(height: 4),
              Wrap(
                children: ['Direct cooking', 'Eating out', 'Delivery based']
                    .map(
                      (method) => buildChip(
                        label: method,
                        selected: selectedMealMethod == method,
                        onTap: () =>
                            setState(() => selectedMealMethod = method),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 4),
              const Text(
                'How do you most often prepare or acquire your meals?',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text('식사 제약 조건'),
              Wrap(
                children: dietaryRestrictions
                    .map(
                      (item) => buildChip(
                        label: item,
                        emoji: item == 'Vegetarian'
                            ? '🥕'
                            : item == 'Halal'
                            ? '🐓'
                            : item == 'Gluten-free'
                            ? '🌾'
                            : '❌',
                        selected: selectedRestrictions.contains(item),
                        onTap: () => toggleRestriction(item),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              const Text('음식 알레르기'),
              Wrap(
                children: allergyOptions
                    .map(
                      (item) => buildChip(
                        label: item,
                        selected: selectedAllergies.contains(item),
                        onTap: () => toggleAllergy(item),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 4),
              const Text(
                'Please select any food allergies.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: agreedToTerms,
                onChanged: (val) =>
                    setState(() => agreedToTerms = val ?? false),
                title: const Text('개인정보 이용 동의'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: agreedToTerms ? submitData : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2980B9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Continue',
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
      ),
    );
  }
}
