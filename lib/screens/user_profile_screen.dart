import 'package:flutter/material.dart';
import 'user_lifestyle_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  int? age;
  double? height;
  double? weight;
  String gender = 'male';
  String name = '';

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
                widthFactor: 0.1,
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
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    const Center(
                      child: Text(
                        '당신에 대해 알려주세요',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    const Text("닉네임"),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      onChanged: (val) => name = val,
                      validator: (val) => val == null || val.isEmpty
                          ? '닉네임을 입력하세요'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    const Text("나이"),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (val) => age = int.tryParse(val),
                      validator: (val) => val == null || val.isEmpty
                          ? '나이를 입력하세요'
                          : null,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "나이를 연 단위로 입력하세요.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    const Text("성별"),
                    const SizedBox(height: 8),
                    Row(
                      children: ['male', 'female'].map((option) {
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
                                  color: selected
                                      ? Colors.black
                                      : Colors.transparent,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  option == 'male' ? '남성' : '여성',
                                  style: const TextStyle(
                                    color: Colors.black,
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
                    const Text("키 (cm)"),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (val) => height = double.tryParse(val),
                      validator: (val) => val == null || val.isEmpty
                          ? '키를 입력하세요'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    const Text("체중 (kg)"),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (val) => weight = double.tryParse(val),
                      validator: (val) => val == null || val.isEmpty
                          ? '체중을 입력하세요'
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
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
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserLifestyleScreen(
                            name: name,
                            age: age!,
                            gender: gender,
                            height: height!,
                            weight: weight!,
                          ),
                        ),
                      );
                    }
                  },
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
                        '다음',
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
