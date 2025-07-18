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
            appBar: AppBar(
                title: const Text('기본 정보 입력'),
            ),
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
                            )
                        ],
                    ),
                ),
            ),
        );
    }
}
