import 'package:flutter/material.dart';
import 'package:glucous_meal_app/models/models.dart';

class RecDetailScreen extends StatefulWidget {
  final Recommendation rec;

  const RecDetailScreen({super.key, required this.rec});

  @override
  State<RecDetailScreen> createState() => _RecDetailScreenState();
}

class _RecDetailScreenState extends State<RecDetailScreen> {
  late final TextEditingController _searchCtrl;

  Map<String, String>? _nutrientsUi; // '칼로리': '123 kcal' 등
  List<Map<String, dynamic>> _ingredientsUi = []; // {name, count, icon}
  List<Map<String, dynamic>> _restrictionsUi = [];
  String? _imageUrl; // Recommendation에는 없으니 null/placeholder
  bool _loading = true;
  String? _error;

  int _satisfaction = 1; // 0:싫어요, 1:보통, 2:좋아요

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.rec.foodName);
    _prepareUiFromRecommendation(); // ✅ 서버 대신 추천 데이터 바인딩
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// 괄호 밖에서만 , / \n 를 구분자로 분리 (중첩 괄호 지원)
  List<String> _splitIngredientsOutsideParens(String s) {
    final out = <String>[];
    var buf = StringBuffer();
    final stack = <String>[]; // 닫는 괄호 스택

    String? closingFor(String ch) {
      switch (ch) {
        case '(':
          return ')';
        case '[':
          return ']';
        case '{':
          return '}';
        case '（':
          return '）'; // 전각 괄호도 지원
        case '［':
          return '］';
        case '｛':
          return '｝';
      }
      return null;
    }

    bool isSep(String ch) => ch == ',' || ch == '/' || ch == '\n' || ch == '，';

    for (var i = 0; i < s.length; i++) {
      final ch = s[i];

      // 여는 괄호
      final close = closingFor(ch);
      if (close != null) {
        stack.add(close);
        buf.write(ch);
        continue;
      }

      // 닫는 괄호
      if (stack.isNotEmpty && ch == stack.last) {
        stack.removeLast();
        buf.write(ch);
        continue;
      }

      // 바깥에서만 구분자 처리
      if (isSep(ch) && stack.isEmpty) {
        out.add(buf.toString().trim());
        buf = StringBuffer();
        continue;
      }

      buf.write(ch);
    }

    if (buf.isNotEmpty) out.add(buf.toString().trim());
    return out.where((e) => e.isNotEmpty).toList();
  }

  // Recommendation -> 화면 표시용 데이터로 변환
  void _prepareUiFromRecommendation() {
    try {
      final n = widget.rec.nutrition;

      // 영양소 → 화면 문자열
      final ui = <String, String>{
        '칼로리': '${_fmt(n['calories'], 0)} kcal',
        '탄수화물': '${_fmt(n['carbs'])} g',
        '단백질': '${_fmt(n['protein'])} g',
        '지방': '${_fmt(n['fat'])} g',
        '당류': '${_fmt(n['sugar'])} g',
        '식이섬유': '${_fmt(n['fiber'])} g',
        '나트륨': '${_fmt(n['sodium'], 0)} mg',
        // 추천 모델의 예측값도 보이게 하고 싶다면 아래 두 줄 활성화
        // '예상 ΔG': _fmt(),
        // '예상 Gmax': _fmt(),
      };

      // 식재료 문자열 → 리스트
      final ingredientList = _splitIngredientsOutsideParens(
        widget.rec.ingredients,
      );

      final ingUi = ingredientList
          .map((name) => {'name': name, 'count': 1, 'icon': Icons.eco})
          .toList();

      final restrUi = _deriveRestrictions(ingredientList);

      final allergyText = (widget.rec.allergies ?? '').trim();
      if (allergyText.isNotEmpty) {
        final allergyList = allergyText
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        for (final allergy in allergyList) {
          // 이미 _deriveRestrictions에서 추가된 동일 항목은 중복 방지
          if (!restrUi.any((m) => m['name'] == allergy)) {
            restrUi.add({'name': allergy, 'count': 1, 'icon': Icons.block});
          }
        }
      }

      setState(() {
        _nutrientsUi = ui;
        _ingredientsUi = ingUi;
        _restrictionsUi = restrUi;
        _imageUrl = null; // Recommendation에 이미지가 없으므로 placeholder 사용
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '추천 데이터를 해석하는 중 오류가 발생했습니다';
        _loading = false;
      });
    }
  }

  String _fmt(Object? x, [int frac = 1]) {
    if (x == null) return (0).toStringAsFixed(frac);
    if (x is num) return x.toStringAsFixed(frac);
    final v = double.tryParse(x.toString());
    return (v ?? 0).toStringAsFixed(frac);
  }

  List<Map<String, dynamic>> _deriveRestrictions(List<String> ingredients) {
    final text = ingredients.map((e) => e.toLowerCase()).join(', ');

    final rules = <String, List<String>>{
      '글루텐(곡물)': ['wheat', 'barley', 'rye', 'malt', 'gluten'],
      '유제품': ['milk', 'cheese', 'butter', 'cream', 'yogurt', 'casein', 'whey'],
      '달걀': ['egg', 'albumen'],
      '견과류': [
        'almond',
        'walnut',
        'cashew',
        'peanut',
        'hazelnut',
        'pistachio',
        'nut',
      ],
      '갑각류/해산물': [
        'shrimp',
        'prawn',
        'crab',
        'lobster',
        'shellfish',
        'clam',
        'oyster',
      ],
      '육류': ['beef', 'pork', 'chicken', 'lamb', 'bacon', 'ham'],
      '대두': ['soy', 'soya', 'soybean'],
    };

    final List<Map<String, dynamic>> out = [];
    rules.forEach((label, kws) {
      final c = kws.where((k) => text.contains(k)).length;
      if (c > 0) out.add({'name': label, 'count': c, 'icon': Icons.block});
    });
    return out;
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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            : ListView(
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

                  // 검색창(이름으로 재검색하고 싶을 때 사용)
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
                              // 필요 시 검색 이벤트 바인딩
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 디버그: 그룹/가격 정보
                  Text(
                    '가격: ${_fmt(widget.rec.price, 0)}원 (배송비 ${_fmt(widget.rec.shippingFee, 0)}원 포함)',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  // 이미지 + 타이틀
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          child:
                              _buildFoodImage(), // ✅ 이미지 위젯 (URL 없으면 placeholder)
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.rec.foodName.isEmpty
                                  ? '음식'
                                  : widget.rec.foodName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton(
                              onPressed: () {},
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
                    children: (_nutrientsUi ?? const {}).entries
                        .map((e) => _InfoTile(title: e.key, value: e.value))
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // 섹션: 식재료 구성
                  const _SectionTitle('식재료 구성'),
                  const SizedBox(height: 10),
                  ..._ingredientsUi.map(
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
                  ..._restrictionsUi.map(
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
                        // 예: Navigator.push(...);
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

  /// ✅ 이미지 빌더: Recommendation에는 이미지가 없으므로 placeholder 처리
  Widget _buildFoodImage() {
    final url = (_imageUrl ?? '').trim();
    if (url.isEmpty) {
      return Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stack) {
        return Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      },
    );
  }
}

/// ───────────────────── Sub Widgets (그대로) ─────────────────────

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
