// lib/screens/food_detail_screen.dart
import 'package:flutter/material.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodName;

  const FoodDetailScreen({super.key, required this.foodName});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late final TextEditingController _searchCtrl;

  // ✅ TODO: 실제 API 결과로 교체하세요.
  // 영양성분 샘플
  final Map<String, String> _nutrients = const {
    '칼로리': '350 kcal',
    '탄수화물': '40 g',
    '단백질': '30 g',
    '지방': '15 g',
    '당류': '3 g',
    '식이섬유': '4 g',
    '나트륨': '400 mg',
    '영양소 점수': '8/10 점',
  };

  // 식재료/제약조건 샘플
  final List<Map<String, dynamic>> _ingredients = const [
    {'name': '곡물', 'count': 1, 'icon': Icons.rice_bowl},
    {'name': '단백질', 'count': 2, 'icon': Icons.egg_alt},
    {'name': '채소', 'count': 1, 'icon': Icons.eco},
  ];
  final List<Map<String, dynamic>> _restrictions = const [
    {'name': '곡물', 'count': 1, 'icon': Icons.no_food},
    {'name': '단백질', 'count': 2, 'icon': Icons.block},
    {'name': '채소', 'count': 1, 'icon': Icons.block},
  ];

  int _satisfaction = 1; // 0:싫어요, 1:보통, 2:좋아요

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.foodName);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            // 상단 그라데이션 바
            Container(
              height: 6,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                gradient: LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF00FFD1)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              '음식정보가 궁금하신가요?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            // 검색창
            Container(
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
                      controller: _searchCtrl,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: '서브웨이',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        // TODO: value로 검색 → 상세 데이터 로드
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 이미지 + 타이틀 영역
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 좌: 이미지
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 6,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                        color: Color(0x14000000),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      // ✅ TODO: 저작권/출처 확인된 이미지로 교체
                      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 우: 텍스트
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FIXME: 사진 제거, 저작권 문제',
                        style: TextStyle(fontSize: 12, color: Colors.redAccent),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.foodName.isEmpty ? '그릴 치킨 샐러드' : widget.foodName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Low-carb, high-protein for blood sugar control',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          // TODO: 외부 쇼핑 링크/자세히 보기 연결
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          side: const BorderSide(color: Colors.black87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('구매 정보 알아보기'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 섹션: 영양소 정보
            const _SectionTitle('영양소 정보'),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.6,
              children: _nutrients.entries.map((e) {
                return _InfoTile(title: e.key, value: e.value);
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 섹션: 식재료 구성
            const _SectionTitle('식재료 구성'),
            const SizedBox(height: 10),
            ..._ingredients.map(
              (m) => _RowItem(
                icon: m['icon'] as IconData,
                label: m['name'] as String,
                count: m['count'] as int,
              ),
            ),

            const SizedBox(height: 20),

            // 섹션: 제약조건
            const _SectionTitle('제약조건'),
            const SizedBox(height: 10),
            ..._restrictions.map(
              (m) => _RowItem(
                icon: m['icon'] as IconData,
                label: m['name'] as String,
                count: m['count'] as int,
              ),
            ),

            const SizedBox(height: 24),

            // 만족도 이모지
            const _SectionTitle('음식이 마음에 드시나요?'),
            const SizedBox(height: 8),
            Row(
              children: [
                _EmojiChip(
                  selected: _satisfaction == 2,
                  label: '😄',
                  onTap: () => setState(() => _satisfaction = 2),
                ),
                const SizedBox(width: 8),
                _EmojiChip(
                  selected: _satisfaction == 1,
                  label: '🙂',
                  onTap: () => setState(() => _satisfaction = 1),
                ),
                const SizedBox(width: 8),
                _EmojiChip(
                  selected: _satisfaction == 0,
                  label: '😕',
                  onTap: () => setState(() => _satisfaction = 0),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '이모지를 선택해 주세요',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 28),

            // CTA 버튼
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 혈당 예측 화면으로 이동
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF00FFD1)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      '혈당 예측하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── Sub Widgets ─────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9E9E9)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  const _RowItem({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE9E9E9)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmojiChip extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _EmojiChip({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF4A90E2) : Colors.black12,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
