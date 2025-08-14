import 'package:flutter/material.dart';
import 'package:glucous_meal_app/services/api_service.dart'; // ✅ 상세 API 사용
import 'glucous_loading_screen.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodName;
  final String foodId;

  const FoodDetailScreen({
    super.key,
    required this.foodName,
    required this.foodId,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late final TextEditingController _searchCtrl;

  // ✅ 서버 데이터 바인딩용 상태
  Map<String, String>? _nutrientsUi; // '칼로리': '123 kcal' 등
  List<Map<String, dynamic>> _ingredientsUi = []; // {name, count, icon}
  List<Map<String, dynamic>> _restrictionsUi = [];
  String? _imageUrl; // ✅ 추가: 서버에서 받은 이미지 URL
  bool _loading = true;
  bool _overlay = false;
  String? _error;

  int _satisfaction = 1; // 0:싫어요, 1:보통, 2:좋아요

  Future<T> _withFullscreenLoading<T>(Future<T> Function() task) async {
    if (mounted) setState(() => _overlay = true);
    try {
      return await task();
    } finally {
      if (mounted) setState(() => _overlay = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.foodName);

    // 화면이 첫 프레임 렌더링된 이후에 로딩 화면을 띄우도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _withFullscreenLoading(() => _fetchFoodDetailById(widget.foodId));
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchFoodDetailById(String id) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await ApiService.fetchFoodDetail(id);

      // 영양소 → 화면 문자열
      final n = detail.nutrients;
      final ui = <String, String>{
        '칼로리': '${_fmt(n['calories_kcal'], 0)} kcal',
        '탄수화물': '${_fmt(n['carbohydrate_g'])} g',
        '단백질': '${_fmt(n['protein_g'])} g',
        '지방': '${_fmt(n['fat_g'])} g',
        '당류': '${_fmt(n['sugar_g'])} g',
        '식이섬유': '${_fmt(n['fiber_g'])} g',
        '나트륨': '${_fmt(n['sodium_mg'], 0)} mg',
        // '영양소 점수': '아직 지원하지 않습니다',
      };

      // 식재료 리스트 → UI 아이템
      final ingUi = detail.ingredients
          .map(
            (name) => {
              'name': name,
              'count': 1,
              'icon': Icons.eco, // 필요시 카테고리별 아이콘 매핑
            },
          )
          .toList();

      // 간단 제약조건(키워드 기반 탐지)
      final restrUi = _deriveRestrictions(detail.ingredients);

      // ✅ 이미지 URL 반영 (detail.imageUrl 또는 image_url 형태 둘 다 대응)
      final String? imageUrl = (() {
        try {
          // 모델 클래스에 imageUrl 필드가 있다고 가정
          final dynamic v = (detail as dynamic).imageUrl;
          if (v is String && v.trim().isNotEmpty) return v.trim();
        } catch (_) {}
        try {
          // 혹시 Map 형태로 오는 경우 대비
          final dynamic v = (detail as dynamic)['image_url'];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        } catch (_) {}
        return null;
      })();

      if (!mounted) return;
      setState(() {
        _nutrientsUi = ui;
        _ingredientsUi = ingUi;
        _restrictionsUi = restrUi;
        _imageUrl = imageUrl; // ✅ 이미지 세팅
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '음식 정보를 불러오지 못했습니다';
        _loading = false;
      });
    }
  }

  String _fmt(num? x, [int frac = 1]) => (x ?? 0).toStringAsFixed(frac);

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
      key: ValueKey(widget.foodId),
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
        child: Stack(
          children: [
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
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
                                  // 필요 시 이름 재검색 로직 추가
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

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
                              child: _buildFoodImage(), // ✅ 이미지 위젯 분리
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.foodName.isEmpty
                                      ? '음식'
                                      : widget.foodName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 36),
                                    side: const BorderSide(
                                      color: Colors.black87,
                                    ),
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
                            // 예: Navigator.push(..., MaterialPageRoute(builder: (_) => PredictScreen(foodId: widget.foodId)));
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
            if (_overlay) const GlucousLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  // ✅ 이미지 빌더: URL이 없거나 로딩/에러일 때 깔끔하게 처리
  Widget _buildFoodImage() {
    final url = (_imageUrl ?? '').trim();
    if (url.isEmpty) {
      // placeholder
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
      // 로딩 표시
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      // 에러 시 placeholder
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
