import 'package:flutter/material.dart';
import 'lifestyle_screen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  int? age;
  double? height;
  double? weight;

  String gender = 'M';
  String activityLevel = 'high';
  String diabetes = '없음';
  String goal = 'blood_sugar_control';

  final List<String> genderOptions = ['M', 'F'];
  final List<String> activityOptions = [
    'low',
    'medium',
    'high',
  ];
  final List<String> diabetesOptions = [
    '제1형 당뇨',
    '제2형 당뇨',
    '없음',
  ];
  final List<String> goalOptions = [
    'blood_sugar_control',
    'weight_loss',
    'balanced',
  ];

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
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children: [
              buildProgressBar(context),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  '당신에 대해 알려주세요',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Text("나이를 입력해주세요"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (val) => age = int.tryParse(val),
                validator: (val) =>
                    val == null || val.isEmpty ? '나이를 입력해주세요' : null,
              ),
              const SizedBox(height: 4),
              const Text(
                "나이를 연 단위로 입력해주세요.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text("성별을 선택해주세요"),
              const SizedBox(height: 8),
              Row(
                children: genderOptions.map((option) {
                  final selected = gender == option;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => gender = option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFF4F4F4)
                              : Colors.grey[200],
                          border: Border.all(
                            color: selected ? Colors.black : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            option == 'M' ? '남성' : '여성',
                            style: TextStyle(
                              color: selected ? Colors.black : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text("키를 입력해주세요 (cm)"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (val) => height = double.tryParse(val),
                validator: (val) =>
                    val == null || val.isEmpty ? '키를 입력해주세요' : null,
              ),
              const SizedBox(height: 24),
              const Text("몸무게를 입력해주세요 (kg)"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (val) => weight = double.tryParse(val),
                validator: (val) =>
                    val == null || val.isEmpty ? '몸무게를 입력해주세요' : null,
              ),
              const SizedBox(height: 24),
              const Text("활동량을 선택해주세요"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
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
                    onSelected: (_) => setState(() => activityLevel = option),
                    selectedColor: const Color(0xFFF4F4F4),
                    labelStyle: TextStyle(
                      color: selected ? Colors.black : Colors.black,
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
                  return ChoiceChip(
                    label: Text(option),
                    selected: selected,
                    onSelected: (_) {
                      // 이미 선택된 항목을 다시 눌러도 해제되지 않도록 조건 추가
                      if (!selected) {
                        setState(() => diabetes = option);
                      }
                    },
                    selectedColor: const Color(0xFFF4F4F4),
                    labelStyle: TextStyle(
                      color: selected ? Colors.black : Colors.black,
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
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LifestyleScreen(
                            age: age!,
                            gender: gender,
                            height: height!,
                            weight: weight!,
                            activityLevel: activityLevel,
                            diabetes: diabetes,
                            goal: goal,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    '계속하기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
