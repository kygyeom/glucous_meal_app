//import 'package:flutter/material.dart';
//import 'package:glucous_meal_app/models/models.dart';
//
//
//class Main extends StatelessWidget {
//  final String username;
//  final List<Recommendation> recommendations;
//
//  const Main({
//    super.key,
//    required this.username,
//    required this.recommendations,
//  });
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      backgroundColor: Colors.white,
//      appBar: AppBar(
//        backgroundColor: Colors.white,
//        elevation: 0,
//        automaticallyImplyLeading: false, // 뒤로가기 제거
//        actions: [
//          Padding(
//            padding: const EdgeInsets.only(right: 12), // 오른쪽에 살짝 여백만 주기
//            child: IconButton(
//              icon: const Icon(Icons.menu, color: Colors.black),
//              onPressed: () {},
//            ),
//          ),
//        ],
//      ),
//      body: SafeArea(
//        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: [
//            // 🔵 그라데이션 선
//            const SizedBox(height: 20),
//            Padding(
//              padding: const EdgeInsets.symmetric(horizontal: 16),
//              child: Container(
//                height: 6,
//                decoration: const BoxDecoration(
//                  borderRadius: BorderRadius.all(Radius.circular(8)),
//                  gradient: LinearGradient(
//                    colors: [Color(0xFF4A90E2), Color(0xFF00FFD1)],
//                    begin: Alignment.centerLeft,
//                    end: Alignment.centerRight,
//                  ),
//                ),
//              ),
//            ),
//            const SizedBox(height: 20),
//            const Text(
//              '더 이상 혼자 관리하지\n않아도 괜찮아요 :)',
//              textAlign: TextAlign.center,
//              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//            ),
//            const SizedBox(height: 6),
//            Text(
//              '- $username -',
//              style: const TextStyle(fontSize: 14, color: Colors.grey),
//            ),
//            const SizedBox(height: 24),
//            const Text(
//              '음식 정보가 궁금하신가요?',
//              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//            ),
//            const SizedBox(height: 12),
//            Padding(
//              padding: const EdgeInsets.symmetric(horizontal: 24),
//              child: Container(
//                decoration: BoxDecoration(
//                  border: Border.all(color: Colors.black, width: 1),
//                  borderRadius: BorderRadius.circular(12),
//                ),
//                padding: const EdgeInsets.symmetric(horizontal: 12),
//                child: const Row(
//                  children: [
//                    Icon(Icons.search, color: Colors.grey),
//                    SizedBox(width: 8),
//                    Expanded(
//                      child: TextField(
//                        decoration: InputDecoration(
//                          hintText: 'Search your interesting foods...',
//                          border: InputBorder.none,
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//            ),
//            const SizedBox(height: 28),
//            const Text(
//              '당신을 위한 오늘의 추천 식단',
//              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//            ),
//            const SizedBox(height: 16),
//            Flexible(
//              fit: FlexFit.tight,
//              child: Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 16),
//                child: GridView.builder(
//                  padding: const EdgeInsets.only(bottom: 32),
//                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                    crossAxisCount: 3,
//                    crossAxisSpacing: 12,
//                    mainAxisSpacing: 12,
//                    childAspectRatio: 0.85,
//                  ),
//                  itemCount: recommendations.length,
//                  itemBuilder: (context, index) {
//                    final meal = recommendations[index];
//                    return Container(
//                      decoration: BoxDecoration(
//                        border: Border.all(color: Colors.black, width: 1),
//                        borderRadius: BorderRadius.circular(10),
//                      ),
//                      padding: const EdgeInsets.all(8),
//                      child: Column(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: [
//                          Text(
//                            meal.foodName,
//                            textAlign: TextAlign.center,
//                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//                          ),
//                          const SizedBox(height: 12),
//                          Column(
//                            children: [
//                              Text('Calories', style: TextStyle(color: Colors.grey.shade700)),
//                              Text('${meal.nutrition['calories']}', style: const TextStyle(fontWeight: FontWeight.w500)),
//                            ],
//                          ),
//                          const SizedBox(height: 8),
//                          Column(
//                            children: [
//                              Text('Carb', style: TextStyle(color: Colors.grey.shade700)),
//                              Text('${meal.nutrition['carbs']}', style: const TextStyle(fontWeight: FontWeight.w500)),
//                            ],
//                          ),
//                        ],
//                      ),
//                    );
//                  },
//                ),
//              ),
//            )
//          ],
//        ),
//      ),
//    );
//  }
//}

import 'package:flutter/material.dart';
import 'package:glucous_meal_app/models/models.dart';
import 'package:glucous_meal_app/services/api_service.dart';

class Main extends StatefulWidget {
  final String username;
  final List<Recommendation> recommendations;

  const Main({
    super.key,
    required this.username,
    required this.recommendations,
  });

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final TextEditingController _controller = TextEditingController();
  List<String> searchResults = [];

  // ✅ API Service를 사용하는 검색 함수
  void searchFoods(String query) async {
    if (query.length < 2) {
      setState(() => searchResults = []);
      return;
    }

    final results = await ApiService.searchFoods(query);
    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 6,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF00FFD1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '더 이상 혼자 관리하지\n않아도 괜찮아요 :)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '- ${widget.username} -',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              '음식 정보가 궁금하신가요?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: searchFoods,
                        decoration: const InputDecoration(
                          hintText: 'Search your interesting foods...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔽 자동완성 결과 표시
            if (searchResults.isNotEmpty)
              Container(
                height: 150,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(searchResults[index]),
                      onTap: () {
                        // 🍽️ 선택한 음식 클릭 시 처리 (추후 상세 화면 연결 가능)
                        print('Selected: ${searchResults[index]}');
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),
            const Text(
              '당신을 위한 오늘의 추천 식단',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 32),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: widget.recommendations.length,
                  itemBuilder: (context, index) {
                    final meal = widget.recommendations[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            meal.foodName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              Text('Calories', style: TextStyle(color: Colors.grey.shade700)),
                              Text('${meal.nutrition['calories']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              Text('Carb', style: TextStyle(color: Colors.grey.shade700)),
                              Text('${meal.nutrition['carbs']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
