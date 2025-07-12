import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  final String mealName;

  const MealDetailScreen({super.key, required this.mealName});

  @override
  Widget build(BuildContext context) {
    // 가상의 혈당 반응 이미지
    final bloodSugarGraphUrl =
        'https://via.placeholder.com/300x150.png?text=예상+혈당+변화';

    return Scaffold(
      appBar: AppBar(title: Text(mealName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Image.network(bloodSugarGraphUrl),
            const SizedBox(height: 16),
            const Text(
              '영양 정보 (예시)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('탄수화물: 30g\n단백질: 25g\n지방: 10g'),
            const SizedBox(height: 24),
            const Text(
              '요리 레시피 (또는 밀키트)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('1. 닭가슴살을 구워 샐러드와 곁들입니다.\n2. 올리브오일, 발사믹 식초로 드레싱합니다.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 예: 쿠팡 링크 이동 (실제 앱에서는 external url launch 필요)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('식사 구매 링크는 추후 연결됩니다')),
                );
              },
              child: const Text('관련 밀키트/식사 구매 링크 보기'),
            )
          ],
        ),
      ),
    );
  }
}
