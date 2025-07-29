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

  List<String> selectedMeals = ['Lunch', 'Dinner'];
  String selectedMealMethod = 'Direct cooking';
  TextEditingController averageGlucoseController = TextEditingController();

  List<String> dietaryRestrictions = [
    'Vegetarian',
    'Halal',
    'Gluten-free',
    'None',
  ];
  List<String> selectedRestrictions = ['None']; // 항상 기본으로 'None' 선택

  void toggleDietary(String item) {
    setState(() {
      if (item == 'None') {
        // 'None' 선택 시 다른 모든 항목 해제하고 'None'만 유지
        selectedRestrictions = ['None'];
      } else {
        // 'None'을 제외한 항목 선택 시 'None' 제거
        if (selectedRestrictions.contains('None')) {
          selectedRestrictions.remove('None');
        }

        if (selectedRestrictions.contains(item)) {
          selectedRestrictions.remove(item);
          // 아무것도 선택되지 않으면 'None' 다시 선택
          if (selectedRestrictions.isEmpty) {
            selectedRestrictions.add('None');
          }
        } else {
          selectedRestrictions.add(item);
        }
      }
    });
  }

  List<String> allergyOptions = [
    'None',
    'Dairy',
    'Nuts',
    'Shellfish',
    'Meat',
    'Seafood',
    'Other',
  ];
  List<String> selectedAllergies = ['None'];

  void toggleAllergy(String item) {
    setState(() {
      if (item == 'None') {
        // '없음'을 선택한 경우 → 나머지 해제 후 '없음'만 선택
        selectedAllergies = ['None'];
      } else {
        // '없음'이 선택되어 있으면 제거
        selectedAllergies.remove('None');

        if (selectedAllergies.contains(item)) {
          selectedAllergies.remove(item);
          // 아무것도 선택 안된 경우 → '없음' 다시 선택
          if (selectedAllergies.isEmpty) {
            selectedAllergies.add('None');
          }
        } else {
          selectedAllergies.add(item);
        }
      }
    });
  }

  bool agreedToTerms = false;

  void toggleMeal(String meal) {
    setState(() {
      if (selectedMeals.contains(meal)) {
        // 마지막 하나면 삭제 못함
        if (selectedMeals.length == 1) return;
        selectedMeals.remove(meal);
      } else {
        selectedMeals.add(meal);
      }
    });
  }

  void submitData() {
    // Validity test
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double bmi =
        widget.weight / ((widget.height / 100) * (widget.height / 100));

    final profile = UserProfile(
      age: widget.age,
      gender: widget.gender,
      weight: widget.weight,
      height: widget.height,
      bmi: bmi,
      activityLevel: widget.activityLevel,
      goal: widget.goal == 'weight_loss'
          ? '체중 관리'
          : widget.goal == 'balanced'
          ? '균형 잡힌 식단'
          : '혈당 관리',
      diabetes: widget.diabetes == '없음'
          ? 'none'
          : widget.diabetes == '제1형 당뇨'
          ? 'type1'
          : 'type2',
      meals: selectedMeals,
      mealMethod: selectedMealMethod,
      dietaryRestrictions: selectedRestrictions,
      allergies: selectedAllergies,
      averageGlucose: double.tryParse(averageGlucoseController.text) ?? 0.0,
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
                backgroundColor: Colors.white,
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
            flex: 8,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.6,
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
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 3,
                children: [
                  buildChip(
                    label: '아침',
                    emoji: '🍳',
                    selected: selectedMeals.contains('Breakfast'),
                    onTap: () => toggleMeal('Breakfast'),
                  ),
                  buildChip(
                    label: '점심',
                    emoji: '🥗',
                    selected: selectedMeals.contains('Lunch'),
                    onTap: () => toggleMeal('Lunch'),
                  ),
                  buildChip(
                    label: '저녁',
                    emoji: '🍽️',
                    selected: selectedMeals.contains('Dinner'),
                    onTap: () => toggleMeal('Dinner'),
                  ),
                  buildChip(
                    label: '간식',
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
                children: ['직접 요리', '외식', '배달 위주']
                    .map(
                      (method) => buildChip(
                        label: method,
                        selected:
                            selectedMealMethod ==
                            (method == '직접 요리'
                                ? 'Direct cooking'
                                : method == '외식'
                                ? 'Eating out'
                                : 'Delivery based'),
                        onTap: () => setState(() {
                          selectedMealMethod = method == '직접 요리'
                              ? 'Direct cooking'
                              : method == '외식'
                              ? 'Eating out'
                              : 'Delivery based';
                        }),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 4),
              const Text(
                '주로 어떤 방식으로 식사를 준비하거나 구매하시나요?',
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
                children: dietaryRestrictions
                    .map(
                      (item) => buildChip(
                        label: item == 'Vegetarian'
                            ? '채식'
                            : item == 'Halal'
                            ? '할랄'
                            : item == 'Gluten-free'
                            ? '글루텐 프리'
                            : '제한 없음',
                        emoji: item == 'Vegetarian'
                            ? '🥕'
                            : item == 'Halal'
                            ? '🐓'
                            : item == 'Gluten-free'
                            ? '🌾'
                            : '❌',
                        selected: selectedRestrictions.contains(item),
                        onTap: () => toggleDietary(item),
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
                        label: item == 'None'
                            ? '없음'
                            : item == 'Dairy'
                            ? '유제품'
                            : item == 'Nuts'
                            ? '견과류'
                            : item == 'Shellfish'
                            ? '갑각류'
                            : item == 'Meat'
                            ? '육류'
                            : item == 'Seafood'
                            ? '해산물'
                            : '기타',
                        selected: selectedAllergies.contains(item),
                        onTap: () => toggleAllergy(item),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 4),
              const Text(
                '알레르기가 있는 음식을 선택해주세요.\n할랄, 채식주의자, 또는 비선호 음식이 있는 경우에도 체크해주세요.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text('최근 측정한 평균 혈당 수치를 입력해주세요.'),
              TextFormField(
                controller: averageGlucoseController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '예: 105',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? '평균 혈당을 입력해주세요' : null,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: agreedToTerms,
                onChanged: (val) =>
                    setState(() => agreedToTerms = val ?? false),
                title: const Text('개인정보 이용에 동의합니다.'),
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
                    '계속하기',
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
