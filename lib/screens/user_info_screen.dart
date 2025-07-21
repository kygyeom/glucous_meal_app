/*
import 'package:flutter/material.dart';
import 'lifestyle_screen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  String? name;
  int? age;
  String gender = '남성';
  double? height;
  double? weight;
  String activityLevel = '중간';
  String diabetes = '없음';
  String goal = '혈당 안정';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기본 정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '이름 (선택)'),
                onChanged: (val) => name = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '나이'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? '나이를 입력하세요' : null,
                onChanged: (val) => age = int.tryParse(val),
              ),
              DropdownButtonFormField(
                value: gender,
                decoration: const InputDecoration(labelText: '성별'),
                items: ['남성', '여성']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => gender = val!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '키 (cm)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => height = double.tryParse(val),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '몸무게 (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => weight = double.tryParse(val),
              ),
              DropdownButtonFormField(
                value: activityLevel,
                decoration: const InputDecoration(labelText: '활동 수준'),
                items: ['낮음', '중간', '높음']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => activityLevel = val!),
              ),
              DropdownButtonFormField(
                value: diabetes,
                decoration: const InputDecoration(labelText: '당뇨 유무'),
                items: ['없음', '제2형 당뇨', '제1형 당뇨']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => diabetes = val!),
              ),
              DropdownButtonFormField(
                value: goal,
                decoration: const InputDecoration(labelText: '목표'),
                items: ['혈당 안정', '다이어트', '식사 균형']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => goal = val!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // 다음 화면으로 이동
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
                child: const Text('다음'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

/*
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

  String gender = 'Male';
  String activityLevel = 'Mainly sitting';
  String diabetes = 'Type 1';
  String goal = 'Blood sugar control';

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> activityOptions = [
    'Mainly sitting',
    '1+ times/week',
    '3+ times/week',
  ];
  final List<String> diabetesOptions = [
    'Type 1',
    'Type 2',
    'Pre-diabetic',
    'General user',
  ];
  final List<String> goalOptions = [
    'Blood sugar control',
    'Weight management',
    'Balanced diet',
  ];

  final Color selectedColor = Colors.lightBlue.shade100;
  final Color selectedTextColor = Colors.blue.shade700;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            children: [
              const Center(
                child: Text(
                  'Tell us your story',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Enter your age"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (val) => age = int.tryParse(val),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter your age' : null,
              ),
              const SizedBox(height: 4),
              const Text(
                "Please provide your age in years.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text("Select your gender"),
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
                          color: selected ? selectedColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: selected
                                  ? selectedTextColor
                                  : Colors.black,
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
              const Text("Enter your height (cm)"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (val) => height = double.tryParse(val),
              ),
              const SizedBox(height: 24),
              const Text("Enter your weight (kg)"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (val) => weight = double.tryParse(val),
              ),
              const SizedBox(height: 24),
              const Text("Assess your activity level"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: activityOptions.map((option) {
                  final selected = activityLevel == option;
                  return ChoiceChip(
                    label: Text(option),
                    selected: selected,
                    onSelected: (_) => setState(() => activityLevel = option),
                    selectedColor: selectedColor,
                    labelStyle: TextStyle(
                      color: selected ? selectedTextColor : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text("Select your diabetes type"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: diabetesOptions.map((option) {
                  final selected = diabetes == option;
                  return ChoiceChip(
                    label: Text(option),
                    selected: selected,
                    onSelected: (_) => setState(() => diabetes = option),
                    selectedColor: selectedColor,
                    labelStyle: TextStyle(
                      color: selected ? selectedTextColor : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text("Select your goal"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: goalOptions.map((option) {
                  final selected = goal == option;
                  return ChoiceChip(
                    label: Text(option),
                    selected: selected,
                    onSelected: (_) => setState(() => goal = option),
                    selectedColor: selectedColor,
                    labelStyle: TextStyle(
                      color: selected ? selectedTextColor : Colors.black,
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
                      borderRadius: BorderRadius.circular(12),
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
                    'Continue',
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
*/

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

  String gender = 'Male';
  String activityLevel = 'Mainly sitting';
  String diabetes = 'Type 1';
  String goal = 'Blood sugar control';

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> activityOptions = [
    'Mainly sitting',
    '1+ times/week',
    '3+ times/week',
  ];
  final List<String> diabetesOptions = [
    'Type 1',
    'Type 2',
    'Pre-diabetic',
    'General user',
  ];
  final List<String> goalOptions = [
    'Blood sugar control',
    'Weight management',
    'Balanced diet',
  ];

  Widget buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                  widthFactor: 0.3,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black,
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
              const Center(
                child: Text(
                  'Tell us your story',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Enter your age"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (val) => age = int.tryParse(val),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter your age' : null,
              ),
              const SizedBox(height: 4),
              const Text(
                "Please provide your age in years.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text("Select your gender"),
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
                            option,
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
              const Text("Enter your height (cm)"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (val) => height = double.tryParse(val),
              ),
              const SizedBox(height: 24),
              const Text("Enter your weight (kg)"),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (val) => weight = double.tryParse(val),
              ),
              const SizedBox(height: 24),
              const Text("Assess your activity level"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: activityOptions.map((option) {
                  final selected = activityLevel == option;
                  return ChoiceChip(
                    label: Text(option),
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
              const Text("Select your diabetes type"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: diabetesOptions.map((option) {
                  final selected = diabetes == option;
                  return ChoiceChip(
                    label: Text(option),
                    selected: selected,
                    onSelected: (_) => setState(() => diabetes = option),
                    selectedColor: const Color(0xFFF4F4F4),
                    labelStyle: TextStyle(
                      color: selected ? Colors.black : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text("Select your goal"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: goalOptions.map((option) {
                  final selected = goal == option;
                  return ChoiceChip(
                    label: Text(option),
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
                    'Continue',
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
