import 'package:flutter/material.dart';
import 'research_result_screen.dart';

class UserLifestyleScreen extends StatefulWidget {
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;

  const UserLifestyleScreen({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
  });

  @override
  State<UserLifestyleScreen> createState() => _UserLifestyleScreenState();
}

class _UserLifestyleScreenState extends State<UserLifestyleScreen> {
  String activityLevel = 'high';
  String diabetes = 'none';
  String goal = 'blood_sugar_control';

  final List<String> activityOptions = ['low', 'medium', 'high'];
  final List<String> diabetesOptions = ['T1D', 'T2D', 'none'];
  final List<String> goalOptions = [
    'blood_sugar_control',
    'weight_loss',
    'balanced',
  ];

  Widget buildProgressBar() {
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
                widthFactor: 0.2,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildProgressBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  const Center(
                    child: Text(
                      '당신은 어떻게 생활하시나요?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  const Text("활동량을 선택해주세요"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: activityOptions.map((option) {
                      final selected = activityLevel == option;
                      final label = option == 'low'
                          ? '주로 앉아서 생활'
                          : option == 'medium'
                          ? '주 1회 이상 운동'
                          : '주 3회 이상 운동';
                      return ChoiceChip(
                        label: Text(label),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => activityLevel = option),
                        selectedColor: const Color(0xFFF4F4F4),
                        labelStyle: TextStyle(
                          color: selected ? Colors.black : Colors.black,
                        ),
                        showCheckmark: false,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text("당뇨 유형을 선택해주세요"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: diabetesOptions.map((option) {
                      final selected = diabetes == option;
                  
                      // 값(option)에 따라 라벨을 매핑
                      String displayLabel;
                      switch (option) {
                        case 'T1D':
                          displayLabel = '제1형 당뇨';
                          break;
                        case 'T2D':
                          displayLabel = '제2형 당뇨';
                          break;
                        case 'none':
                          displayLabel = '없음';
                          break;
                        default:
                          displayLabel = option; // fallback
                      }
                  
                      return ChoiceChip(
                        label: Text(displayLabel),
                        selected: selected,
                        onSelected: (_) {
                          if (!selected) {
                            setState(() => diabetes = option);
                          }
                        },
                        selectedColor: const Color(0xFFF4F4F4),
                        labelStyle: TextStyle(
                          color: selected ? Colors.black : Colors.black,
                        ),
                        showCheckmark: false,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text("목표를 선택해주세요"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: goalOptions.map((option) {
                      final selected = goal == option;
                      final label = option == 'blood_sugar_control'
                          ? '혈당 관리'
                          : option == 'weight_loss'
                          ? '체중 관리'
                          : '균형 잡힌 식단';
                      return ChoiceChip(
                        label: Text(label),
                        selected: selected,
                        onSelected: (_) => setState(() => goal = option),
                        selectedColor: const Color(0xFFF4F4F4),
                        labelStyle: TextStyle(
                          color: selected ? Colors.black : Colors.black,
                        ),
                        showCheckmark: false,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResearchResultScreen(
                          name: widget.name,
                          age: widget.age,
                          gender: widget.gender,
                          height: widget.height,
                          weight: widget.weight,
                          activityLevel: activityLevel,
                          diabetes: diabetes,
                          goal: goal,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
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
}
