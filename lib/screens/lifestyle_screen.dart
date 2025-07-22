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
          color: selected ? Color(0xFFF4F4F4) : Colors.grey[200],
          border: Border.all(
            color: selected ? Colors.black : Colors.transparent,
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
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
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
                widthFactor: 0.6, // 진행도 (예: 0.25)
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
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children: [
              buildProgressBar(context),
              const SizedBox(height: 8),
              const Text(
                '이 정보를 기반으로 당신에게 맞는 식단을 추천합니다',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                '주 식사 시간',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,  // 간격 줄임
                crossAxisSpacing: 8, // 간격 줄임
                childAspectRatio: 3,
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
              const Text(
                '식사 제약 조건',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3,
                physics: NeverScrollableScrollPhysics(),
                children: dietaryRestrictions.map(
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
                ).toList(),
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
                    backgroundColor: Colors.black,
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
