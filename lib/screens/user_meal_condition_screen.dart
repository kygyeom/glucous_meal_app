import 'package:flutter/material.dart';
import 'package:glucous_meal_app/models/models.dart';
import 'summary_screen.dart';

class UserMealConditionScreen extends StatefulWidget {
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
  State<UserMealConditionScreen> createState() => _UserMealConditionScreenState();
}

class _UserMealConditionScreenState extends State<UserMealConditionScreen> {
  final _formKey = GlobalKey<FormState>();

  List<String> dietaryRestrictions = ['Vegetarian', 'Halal', 'Gluten-free', 'None'];
  List<String> selectedRestrictions = ['None'];

  List<String> allergyOptions = ['None', 'Dairy', 'Nuts', 'Shellfish', 'Meat', 'Seafood', 'Other'];
  List<String> selectedAllergies = ['None'];

  bool agreedToTerms = false;

  void toggleSelection(String item, List<String> selectedList, void Function(List<String>) updateState) {
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

  void submitData() {
    final double bmi = widget.weight / ((widget.height / 100) * (widget.height / 100));

    final profile = UserProfile(
      age: widget.age,
      gender: widget.gender,
      weight: widget.weight,
      height: widget.height,
      bmi: bmi,
      activityLevel: widget.activityLevel,
      goal: widget.goal == 'weight_loss' ? '체중 관리' : widget.goal == 'balanced' ? '균형 잡힌 식단' : '혈당 관리',
      diabetes: widget.diabetes == '없음' ? 'none' : widget.diabetes == '제1형 당뇨' ? 'type1' : 'type2',
      meals: widget.meals,
      mealMethod: widget.mealMethod,
      dietaryRestrictions: selectedRestrictions,
      allergies: selectedAllergies,
      averageGlucose: 0.0, // 혈당 입력 제거, 기본값 고정
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(userProfile: profile),
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
                widthFactor: 1.0,
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
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  children: [
                    const SizedBox(height: 16),
                    const Text('제약조건이 있으신가요?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    const Text('식사 제약 조건'),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 3,
                      physics: const NeverScrollableScrollPhysics(),
                      children: dietaryRestrictions.map((item) => buildChip(
                        item,
                        selectedRestrictions.contains(item),
                        () => toggleSelection(item, selectedRestrictions, (v) => selectedRestrictions = v),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text('음식 알레르기'),
                    Wrap(
                      children: allergyOptions.map((item) => buildChip(
                        item,
                        selectedAllergies.contains(item),
                        () => toggleSelection(item, selectedAllergies, (v) => selectedAllergies = v),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '알레르기가 있는 음식을 선택해주세요.\n할랄, 채식주의자, 또는 비선호 음식이 있는 경우에도 체크해주세요.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: agreedToTerms,
                      onChanged: (val) => setState(() => agreedToTerms = val ?? false),
                      title: const Text('개인정보 이용에 동의합니다.'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: agreedToTerms ? submitData : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
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

  Widget buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF4F4F4) : Colors.grey[200],
          border: Border.all(color: selected ? Colors.black : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
