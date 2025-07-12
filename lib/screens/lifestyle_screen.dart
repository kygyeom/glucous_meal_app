import 'package:flutter/material.dart';
import 'summary_screen.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  final _formKey = GlobalKey<FormState>();

  int? mealsPerDay;
  String mealTime = '규칙적';
  bool snacks = false;
  String foodCulture = '일반식';
  String cookingAbility = '직접 요리';
  String environment = '시간 여유 있음';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('생활 습관 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '하루 식사 횟수 (예: 3)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => mealsPerDay = int.tryParse(val),
              ),
              DropdownButtonFormField(
                value: mealTime,
                decoration: const InputDecoration(labelText: '식사 시간대'),
                items: ['규칙적', '불규칙']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => mealTime = val!),
              ),
              SwitchListTile(
                title: const Text('간식 자주 섭취'),
                value: snacks,
                onChanged: (val) => setState(() => snacks = val),
              ),
              DropdownButtonFormField(
                value: foodCulture,
                decoration: const InputDecoration(labelText: '식문화/제한사항'),
                items: ['일반식', '채식', '종교식', '알레르기 있음']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => foodCulture = val!),
              ),
              DropdownButtonFormField(
                value: cookingAbility,
                decoration: const InputDecoration(labelText: '식사 준비 가능 여부'),
                items: ['직접 요리', '주로 배달', '혼합']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => cookingAbility = val!),
              ),
              DropdownButtonFormField(
                value: environment,
                decoration: const InputDecoration(labelText: '직장/시간 환경'),
                items: ['시간 여유 있음', '매우 바쁨', '교대 근무']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => environment = val!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SummaryScreen(),
                    ),
                  );
                },
                child: const Text('결과 확인하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
