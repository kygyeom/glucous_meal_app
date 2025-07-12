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

  List<String> dietaryRestrictions = ['Vegetarian', 'Halal', 'Gluten-free', 'None'];
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
    final double bmi = widget.weight / ((widget.height / 100) * (widget.height / 100));

    final profile = UserProfile(
      age: widget.age,
      gender: widget.gender == '남성' ? 'M' : 'F',
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
              const Text('이 정보를 기반으로 당신에게 맞는 식단을 추천합니다',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 24),
              const Text('🍳 주 식사 시간'),
              Wrap(
                spacing: 8.0,
                children: ['Breakfast', 'Lunch', 'Dinner', 'Snacks'].map((meal) {
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
                    .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                    .toList(),
                onChanged: (val) => setState(() => selectedMealMethod = val!),
                decoration: const InputDecoration(labelText: 'How do you acquire meals?'),
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
                onChanged: (val) => setState(() => agreedToTerms = val ?? false),
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
