import 'package:flutter/material.dart';
import 'dart:math';
import 'package:glucous_meal_app/models/models.dart';
import 'food_search_test_screen.dart';
import 'glucous_loading_screen.dart';

class UserMealConditionScreen extends StatefulWidget {
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

  const UserMealConditionScreen({
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
  });

  @override
  State<UserMealConditionScreen> createState() =>
      _UserMealConditionScreenState();
}

class _UserMealConditionScreenState extends State<UserMealConditionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool agreedToTerms = false;
  final TextEditingController averageGlucoseController =
      TextEditingController();

  List<String> dietaryRestrictions = [
    'Vegetarian',
    'Halal',
    'Gluten-free',
    'None',
  ];
  List<String> selectedRestrictions = ['None'];

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

  final Map<String, String> allergyLabels = {
    'None': '없음',
    'Dairy': '유제품',
    'Nuts': '견과류',
    'Shellfish': '갑각류',
    'Meat': '육류',
    'Seafood': '해산물',
    'Other': '기타',
  };

  void toggleSelection(
    String item,
    List<String> selectedList,
    void Function(List<String>) updateState,
  ) {
    setState(() {
      if (item == 'None') {
        updateState(['None']);
      } else {
        selectedList.remove('None');
        if (selectedList.contains(item)) {
          selectedList.remove(item);
          if (selectedList.isEmpty) {
            updateState(['None']);
          } else {
            updateState(List.from(selectedList));
          }
        } else {
          selectedList.add(item);
          updateState(List.from(selectedList));
        }
      }
    });
  }

  void submitData() async {
    final double bmi = widget.weight / pow(widget.height / 100, 2);

    final userProfile = UserProfile(
      name: widget.name,
      age: widget.age,
      gender: widget.gender,
      weight: widget.weight,
      height: widget.height,
      bmi: bmi,
      activityLevel: widget.activityLevel,
      goal: widget.goal,
      diabetes: widget.diabetes,
      meals: widget.meals,
      mealMethod: widget.mealMethod,
      dietaryRestrictions: selectedRestrictions,
      allergies: selectedAllergies,
      averageGlucose: double.tryParse(averageGlucoseController.text) ?? 100.0,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GlucousLoadingOverlay(),
    );
  }

  Widget buildChip(
    String value,
    bool selected,
    VoidCallback onTap, {
    String? emoji,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF4F4F4) : Colors.grey[200],
          border: Border.all(
            color: selected ? Colors.black : Colors.transparent,
          ),
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
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                widthFactor: 0.5,
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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                buildProgressBar(context),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          '식이 제한 사항이 있으신가요?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('식이 제한'),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 3,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            buildChip(
                              '채식',
                              selectedRestrictions.contains('Vegetarian'),
                              () {
                                toggleSelection(
                                  'Vegetarian',
                                  selectedRestrictions,
                                  (v) => selectedRestrictions = v,
                                );
                              },
                              emoji: '🥕',
                            ),
                            buildChip(
                              '할랄',
                              selectedRestrictions.contains('Halal'),
                              () {
                                toggleSelection(
                                  'Halal',
                                  selectedRestrictions,
                                  (v) => selectedRestrictions = v,
                                );
                              },
                              emoji: '🐓',
                            ),
                            buildChip(
                              '글루텐 프리',
                              selectedRestrictions.contains('Gluten-free'),
                              () {
                                toggleSelection(
                                  'Gluten-free',
                                  selectedRestrictions,
                                  (v) => selectedRestrictions = v,
                                );
                              },
                              emoji: '🌾',
                            ),
                            buildChip(
                              '없음',
                              selectedRestrictions.contains('None'),
                              () {
                                toggleSelection(
                                  'None',
                                  selectedRestrictions,
                                  (v) => selectedRestrictions = v,
                                );
                              },
                              emoji: '❌',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('식품 알레르기'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: allergyOptions.map((item) {
                            return buildChip(
                              allergyLabels[item] ?? item,
                              selectedAllergies.contains(item),
                              () => toggleSelection(
                                item,
                                selectedAllergies,
                                (v) => selectedAllergies = v,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '식품 알레르기가 있으시면 선택하세요.\n할랄, 채식 또는 식품 선호도도 포함해주세요.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        const Text('최근 평균 혈당을 입력하세요'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: averageGlucoseController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '평균 혈당 (mg/dL)',
                            hintText: '예: 100',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixText: 'mg/dL',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '평균 혈당 값을 입력하세요';
                            }
                            final parsed = double.tryParse(value);
                            if (parsed == null || parsed <= 0) {
                              return '유효한 숫자를 입력하세요';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          value: agreedToTerms,
                          onChanged: (val) =>
                              setState(() => agreedToTerms = val ?? false),
                          title: const Text(
                            '개인 정보 사용에 동의합니다.',
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (!agreedToTerms) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'You must agree to the use of personal data.',
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }

                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodSearchTestScreen(
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
                              dietaryRestrictions: selectedRestrictions,
                              allergies: selectedAllergies,
                              averageGlucose:
                                  double.tryParse(
                                    averageGlucoseController.text,
                                  ) ??
                                  100.0,
                            ),
                          ),
                        );
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor: agreedToTerms
                              ? null
                              : Colors.grey.shade400,
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ).copyWith(
                          backgroundColor: agreedToTerms
                              ? MaterialStateProperty.resolveWith(
                                  (states) => null,
                                )
                              : MaterialStateProperty.all(Colors.grey.shade400),
                          foregroundColor: MaterialStateProperty.all(
                            Colors.white,
                          ),
                        ),
                    child: Ink(
                      decoration: agreedToTerms
                          ? const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF00FFD1), Color(0xFF0076FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(24),
                              ),
                            )
                          : const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            '다음',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
          if (isLoading)
            const Opacity(
              opacity: 0.6,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
