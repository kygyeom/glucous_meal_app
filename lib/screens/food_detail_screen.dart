/*
import 'package:flutter/material.dart';

/// 외부 서비스에서 상세 정보를 가져오는 로더 타입.
/// 예: (id) => HTTP GET /food?food_id=id 를 호출해서 FoodDetailData로 매핑
typedef FoodDetailLoader = Future<FoodDetailData> Function(String foodId);

/// 상세 정보 데이터 모델(서비스 결과를 이 형태로 맞춰 반환)
class FoodDetailData {
  final String? imageUrl; // 네트워크 이미지 URL
  final Map<String, dynamic>?
  nutrition; // {"calories_kcal": 320, "carbohydrate_g": 42, ... "sodium_mg": 520}
  final List<String>? ingredients; // ["Chicken breast", ...]
  final List<String>? restrictions; // 서버에 없으면 []

  const FoodDetailData({
    this.imageUrl,
    this.nutrition,
    this.ingredients,
    this.restrictions,
  });
}

/// Food detail screen
/// - embedded = true  : 프레임 공유(Scaffold 없이 본문만 렌더)
/// - embedded = false : 단독 페이지(Scaffold 포함)
class FoodDetailScreen extends StatelessWidget {
  final String foodName;
  final String foodId;
  final bool embedded;

  /// 외부에서 이미 값을 갖고 있다면 초기값으로 넘길 수 있음(즉시 표시)
  final Map<String, dynamic>? initialNutrition;
  final List<String>? initialIngredients;
  final List<String>? initialRestrictions;
  final String? initialImageUrl;

  /// ✅ 외부 ApiService/HTTP에 맞는 상세 호출을 여기로 주입
  final FoodDetailLoader? loadDetail;

  const FoodDetailScreen({
    super.key,
    required this.foodName,
    required this.foodId,
    this.embedded = false,
    this.initialNutrition,
    this.initialIngredients,
    this.initialRestrictions,
    this.initialImageUrl,
    this.loadDetail,
  });

  @override
  Widget build(BuildContext context) {
    final body = _FoodDetailBody(
      foodName: foodName,
      foodId: foodId,
      initialNutrition: initialNutrition,
      initialIngredients: initialIngredients,
      initialRestrictions: initialRestrictions,
      initialImageUrl: initialImageUrl,
      loadDetail: loadDetail,
    );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(title: Text(foodName)),
      body: SafeArea(child: body),
    );
  }
}

class _FoodDetailBody extends StatefulWidget {
  final String foodName;
  final String foodId;
  final Map<String, dynamic>? initialNutrition;
  final List<String>? initialIngredients;
  final List<String>? initialRestrictions;
  final String? initialImageUrl;
  final FoodDetailLoader? loadDetail;

  const _FoodDetailBody({
    required this.foodName,
    required this.foodId,
    this.initialNutrition,
    this.initialIngredients,
    this.initialRestrictions,
    this.initialImageUrl,
    this.loadDetail,
  });

  @override
  State<_FoodDetailBody> createState() => _FoodDetailBodyState();
}

class _FoodDetailBodyState extends State<_FoodDetailBody> {
  bool _loading = true;
  String? _error;

  String? _imageUrl;
  Map<String, String> _nutrition = {}; // 정제된 표기용(예: {"Calories":"320 kcal"})
  List<String> _ingredients = [];
  List<String> _restrictions = [];

  @override
  void initState() {
    super.initState();
    _hydrateFromInitial();
    _loadFromService();
  }

  void _hydrateFromInitial() {
    _imageUrl = _normalizeUrl(widget.initialImageUrl);

    if (widget.initialNutrition != null) {
      _nutrition = _normalizeNutrition(widget.initialNutrition!);
    }
    if (widget.initialIngredients != null) {
      _ingredients = List<String>.from(widget.initialIngredients!);
    }
    if (widget.initialRestrictions != null) {
      _restrictions = List<String>.from(widget.initialRestrictions!);
    }
  }

  Future<void> _loadFromService() async {
    try {
      setState(() => _loading = true);

      if (widget.loadDetail != null) {
        final data = await widget.loadDetail!(widget.foodId);

        final fetchedImage = _normalizeUrl(data.imageUrl);
        if ((_imageUrl == null || _imageUrl!.isEmpty) &&
            fetchedImage != null &&
            fetchedImage.isNotEmpty) {
          _imageUrl = fetchedImage;
        }

        if (_nutrition.isEmpty && data.nutrition != null) {
          _nutrition = _normalizeNutrition(data.nutrition!);
        }

        if (_ingredients.isEmpty && data.ingredients != null) {
          _ingredients = List<String>.from(data.ingredients!);
        }
        if (_restrictions.isEmpty && data.restrictions != null) {
          _restrictions = List<String>.from(data.restrictions!);
        }
      }

      // 그래도 이미지가 없다면 안전한 대체 이미지
      _imageUrl ??= _fallbackImageFor(widget.foodName);

      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Failed to load details";
      });
    }
  }

  // ─────────── Helpers ───────────

  /// 서버 스키마(main.py)의 nutrients를 자동으로 표기용 Map으로 변환
  /// - *_kcal → Calories
  /// - *_g    → g 단위 (Carbs/Protein/Fat/Fiber/Sugar/Sat. Fat)
  /// - *_mg   → mg 단위 (Sodium)
  Map<String, String> _normalizeNutrition(Map<String, dynamic> raw) {
    final out = <String, String>{};

    String fmtNum(dynamic v) {
      if (v == null) return "—";
      if (v is num) {
        final s = v.toString();
        return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
      }
      final s = v.toString().trim();
      return s.isEmpty ? "—" : s;
    }

    String prettyLabel(String core) {
      switch (core.toLowerCase()) {
        case 'calories':
          return '칼로리';
        case 'carbohydrate':
        case 'carb':
        case 'carbs':
          return '탄수화물';
        case 'protein':
          return '단백질';
        case 'fat':
          return '지방';
        case 'fiber':
          return '식이섬유';
        case 'sugar':
          return '당류';
        case 'sodium':
          return '나트륨';
        case 'saturatedfat':
        case 'saturated_fat':
          return '포화지방';
        default:
          // snake -> Title Case
          final parts = core.split(RegExp(r'[_\s]+'));
          return parts
              .map(
                (p) => p.isEmpty
                    ? p
                    : p[0].toUpperCase() + p.substring(1).toLowerCase(),
              )
              .join(' ');
      }
    }

    // 1) 접미사 패턴 우선 처리
    raw.forEach((k, v) {
      final key = k.toString();
      final lower = key.toLowerCase();

      if (lower.endsWith('_kcal')) {
        out['Calories'] = '${fmtNum(v)} kcal';
        return;
      }
      if (lower.endsWith('_g')) {
        final core = key.substring(0, key.length - 2); // remove _g
        final label = prettyLabel(core);
        out[label] = '${fmtNum(v)} g';
        return;
      }
      if (lower.endsWith('_mg')) {
        final core = key.substring(0, key.length - 3); // remove _mg
        final label = prettyLabel(core);
        out[label] = '${fmtNum(v)} mg';
        return;
      }
    });

    // 2) 부족한 표준 키 보완 (혹시 다른 형태로 넘어오는 백엔드를 대비)
    void pick(String label, List<String> aliases, {String? unit}) {
      if (out.containsKey(label)) return;
      for (final a in aliases) {
        if (raw.containsKey(a)) {
          final vv = fmtNum(raw[a]);
          out[label] = unit == null ? vv : '$vv $unit';
          return;
        }
      }
    }

    pick('Calories', ['calories', 'kcal'], unit: 'kcal');
    pick('Carbs', ['carbs', 'carbohydrates', 'carbohydrate'], unit: 'g');
    pick('Protein', ['protein'], unit: 'g');
    pick('Fat', ['fat', 'total_fat'], unit: 'g');
    pick('Fiber', ['fiber', 'dietary_fiber'], unit: 'g');
    pick('Sugar', ['sugar', 'sugars'], unit: 'g');
    pick('Sodium', ['sodium'], unit: 'mg');
    pick('Sat. Fat', ['saturated_fat', 'saturatedfat', 'sat_fat'], unit: 'g');

    return out;
  }

  String? _normalizeUrl(String? url) {
    if (url == null) return null;
    final u = url.trim();
    if (u.isEmpty) return null;
    if (u.startsWith('//')) return 'https:$u';
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      return 'https://$u';
    }
    return u;
  }

  /// 음식 이름으로 대체 이미지(HTTPS, hotlink 허용)
  String _fallbackImageFor(String query) {
    final q = Uri.encodeComponent(
      (query.isEmpty ? 'food' : query) + ',food,meal,plate',
    );
    return 'https://source.unsplash.com/512x512/?$q';
  }

  // ─────────── UI ───────────

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _loading
          ? const _Skeleton()
          : _error != null
          ? _ErrorView(message: _error!, onRetry: _loadFromService)
          : _Content(
              foodName: widget.foodName,
              foodId: widget.foodId,
              imageUrl: _imageUrl,
              nutrition: _nutrition,
              ingredients: _ingredients,
              restrictions: _restrictions,
            ),
    );
  }
}

class _Content extends StatelessWidget {
  final String foodName;
  final String foodId;
  final String? imageUrl;
  final Map<String, String> nutrition;
  final List<String> ingredients;
  final List<String> restrictions;

  const _Content({
    required this.foodName,
    required this.foodId,
    required this.imageUrl,
    required this.nutrition,
    required this.ingredients,
    required this.restrictions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(foodName: foodName, foodId: foodId, imageUrl: imageUrl),
          const SizedBox(height: 16),
          if (nutrition.isNotEmpty) _NutritionCard(nutrition: nutrition),
          if (nutrition.isNotEmpty) const SizedBox(height: 16),
          if (ingredients.isNotEmpty)
            _ChipsSection(title: "Ingredients", chips: ingredients),
          if (ingredients.isNotEmpty) const SizedBox(height: 16),
          if (restrictions.isNotEmpty)
            _ChipsSection(title: "Dietary Notes", chips: restrictions),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String foodName;
  final String foodId;
  final String? imageUrl;

  const _Header({required this.foodName, required this.foodId, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 84,
            height: 84,
            child: (imageUrl == null || imageUrl!.isEmpty)
                ? _ImagePlaceholder()
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    cacheWidth: 252, // 84 * 3 for 3x pixel density
                    cacheHeight: 252,
                    headers: const {"User-Agent": "Mozilla/5.0"},
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const _ImageLoadingSkeleton();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const _ImageErrorPlaceholder();
                    },
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                foodName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "ID: $foodId",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F4F8),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.grey),
      ),
    );
  }
}

class _ImageLoadingSkeleton extends StatelessWidget {
  const _ImageLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFEFF3F8));
  }
}

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDECEC),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.redAccent),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final Map<String, String> nutrition;

  const _NutritionCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    const preferred = ["Calories", "Carbs", "Protein", "Fat", "Fiber", "Sugar"];
    final keys = <String>[
      ...preferred.where(nutrition.containsKey),
      ...nutrition.keys.where((k) => !preferred.contains(k)).toList()..sort(),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        border: Border.all(color: const Color(0xFFE3E8EF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nutrition (per serving)",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: keys
                .map((k) => _MetricPill(label: k, value: nutrition[k] ?? "—"))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE3E8EF)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}

class _ChipsSection extends StatelessWidget {
  final String title;
  final List<String> chips;

  const _ChipsSection({required this.title, required this.chips});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE3E8EF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (c) => Chip(
                    label: Text(c),
                    backgroundColor: const Color(0xFFF7F9FB),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFFE3E8EF)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              _box(w: 84, h: 84),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(w: double.infinity, h: 18),
                    const SizedBox(height: 8),
                    _box(w: 120, h: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _box(w: double.infinity, h: 140, radius: 12),
          const SizedBox(height: 16),
          _box(w: double.infinity, h: 120, radius: 12),
        ],
      ),
    );
  }

  Widget _box({required double w, required double h, double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F8),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';

/// 외부 서비스에서 상세 정보를 가져오는 로더 타입.
/// 예: (id) => HTTP GET /food?food_id=id 를 호출해서 FoodDetailData로 매핑
typedef FoodDetailLoader = Future<FoodDetailData> Function(String foodId);

/// 상세 정보 데이터 모델(서비스 결과를 이 형태로 맞춰 반환)
class FoodDetailData {
  final String? imageUrl; // 네트워크 이미지 URL
  final Map<String, dynamic>?
  nutrition; // {"calories_kcal": 320, "carbohydrate_g": 42, ... "sodium_mg": 520}
  final List<String>? ingredients; // ["Chicken breast", ...]
  final List<String>? restrictions; // 없으면 []

  const FoodDetailData({
    this.imageUrl,
    this.nutrition,
    this.ingredients,
    this.restrictions,
  });
}

/// Food detail screen
/// - embedded = true  : 프레임 공유(Scaffold 없이 본문만 렌더)
/// - embedded = false : 단독 페이지(Scaffold 포함)
class FoodDetailScreen extends StatelessWidget {
  final String foodName;
  final String foodId;
  final bool embedded;

  /// 외부에서 이미 값을 갖고 있다면 초기값으로 넘길 수 있음(즉시 표시)
  final Map<String, dynamic>? initialNutrition;
  final List<String>? initialIngredients;
  final List<String>? initialRestrictions;
  final String? initialImageUrl;

  /// ✅ 외부 ApiService/HTTP에 맞는 상세 호출을 여기로 주입
  final FoodDetailLoader? loadDetail;

  const FoodDetailScreen({
    super.key,
    required this.foodName,
    required this.foodId,
    this.embedded = false,
    this.initialNutrition,
    this.initialIngredients,
    this.initialRestrictions,
    this.initialImageUrl,
    this.loadDetail,
  });

  @override
  Widget build(BuildContext context) {
    final body = _FoodDetailBody(
      foodName: foodName,
      foodId: foodId,
      initialNutrition: initialNutrition,
      initialIngredients: initialIngredients,
      initialRestrictions: initialRestrictions,
      initialImageUrl: initialImageUrl,
      loadDetail: loadDetail,
    );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(title: Text(foodName)),
      body: SafeArea(child: body),
    );
  }
}

class _FoodDetailBody extends StatefulWidget {
  final String foodName;
  final String foodId;
  final Map<String, dynamic>? initialNutrition;
  final List<String>? initialIngredients;
  final List<String>? initialRestrictions;
  final String? initialImageUrl;
  final FoodDetailLoader? loadDetail;

  const _FoodDetailBody({
    required this.foodName,
    required this.foodId,
    this.initialNutrition,
    this.initialIngredients,
    this.initialRestrictions,
    this.initialImageUrl,
    this.loadDetail,
  });

  @override
  State<_FoodDetailBody> createState() => _FoodDetailBodyState();
}

class _FoodDetailBodyState extends State<_FoodDetailBody> {
  bool _loading = true;
  String? _error;

  String? _imageUrl;
  Map<String, String> _nutrition = {}; // 표기용(예: {"Calories":"320 kcal"})
  List<String> _ingredients = [];
  List<String> _restrictions = [];

  @override
  void initState() {
    super.initState();
    _hydrateFromInitial();
    _loadFromService();
  }

  void _hydrateFromInitial() {
    _imageUrl = _normalizeUrl(widget.initialImageUrl);

    if (widget.initialNutrition != null) {
      _nutrition = _normalizeNutrition(widget.initialNutrition!);
      // 제약조건이 없다면 영양소 기반으로 추론
      if ((widget.initialRestrictions == null ||
          widget.initialRestrictions!.isEmpty)) {
        _restrictions = _deriveConstraints(
          widget.initialNutrition!,
          widget.initialIngredients ?? const [],
        );
      }
    }
    if (widget.initialIngredients != null) {
      _ingredients = List<String>.from(widget.initialIngredients!);
    }
    if (widget.initialRestrictions != null &&
        widget.initialRestrictions!.isNotEmpty) {
      _restrictions = _normalizeRestrictions(widget.initialRestrictions!);
    }
  }

  Future<void> _loadFromService() async {
    try {
      setState(() => _loading = true);

      if (widget.loadDetail != null) {
        final data = await widget.loadDetail!(widget.foodId);

        final fetchedImage = _normalizeUrl(data.imageUrl);
        if ((_imageUrl == null || _imageUrl!.isEmpty) &&
            fetchedImage != null &&
            fetchedImage.isNotEmpty) {
          _imageUrl = fetchedImage;
        }

        if (_nutrition.isEmpty && data.nutrition != null) {
          _nutrition = _normalizeNutrition(data.nutrition!);
        }

        if (_ingredients.isEmpty && data.ingredients != null) {
          _ingredients = List<String>.from(data.ingredients!);
        }

        // 서버가 restrictions를 주면 영어로 표준화, 없으면 영양소/재료로 추론
        if (_restrictions.isEmpty) {
          final fromServer = (data.restrictions ?? const []);
          if (fromServer.isNotEmpty) {
            _restrictions = _normalizeRestrictions(fromServer);
          } else {
            _restrictions = _deriveConstraints(
              data.nutrition ?? const {},
              data.ingredients ?? const [],
            );
          }
        }
      }

      // 그래도 이미지가 없다면 안전한 대체 이미지
      _imageUrl ??= _fallbackImageFor(widget.foodName);

      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Failed to load details";
      });
    }
  }

  // ─────────── Helpers ───────────

  /// 서버 nutrients를 표기용 Map으로 변환
  /// - *_kcal → Calories
  /// - *_g    → g 단위 (Carbs/Protein/Fat/Fiber/Sugar/Sat. Fat)
  /// - *_mg   → mg 단위 (Sodium)
  Map<String, String> _normalizeNutrition(Map<String, dynamic> raw) {
    final out = <String, String>{};

    String fmtNum(dynamic v) {
      if (v == null) return "—";
      if (v is num) {
        final s = v.toString();
        return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
      }
      final s = v.toString().trim();
      return s.isEmpty ? "—" : s;
    }

    String prettyLabel(String core) {
      switch (core.toLowerCase()) {
        case 'calories':
          return '칼로리';
        case 'carbohydrate':
        case 'carb':
        case 'carbs':
          return '탄수화물';
        case 'protein':
          return '단백질';
        case 'fat':
          return '지방';
        case 'fiber':
          return '식이섬유';
        case 'sugar':
          return '당류';
        case 'sodium':
          return '나트륨';
        case 'saturatedfat':
        case 'saturated_fat':
          return '포화지방';
        default:
          final parts = core.split(RegExp(r'[_\s]+'));
          return parts
              .map(
                (p) => p.isEmpty
                    ? p
                    : p[0].toUpperCase() + p.substring(1).toLowerCase(),
              )
              .join(' ');
      }
    }

    // 접미사 패턴 우선 처리
    raw.forEach((k, v) {
      final key = k.toString();
      final lower = key.toLowerCase();

      if (lower.endsWith('_kcal')) {
        out['Calories'] = '${fmtNum(v)} kcal';
        return;
      }
      if (lower.endsWith('_g')) {
        final core = key.substring(0, key.length - 2); // remove _g
        final label = prettyLabel(core);
        out[label] = '${fmtNum(v)} g';
        return;
      }
      if (lower.endsWith('_mg')) {
        final core = key.substring(0, key.length - 3); // remove _mg
        final label = prettyLabel(core);
        out[label] = '${fmtNum(v)} mg';
        return;
      }
    });

    // 부족한 표준 키 보완
    void pick(String label, List<String> aliases, {String? unit}) {
      if (out.containsKey(label)) return;
      for (final a in aliases) {
        if (raw.containsKey(a)) {
          final vv = fmtNum(raw[a]);
          out[label] = unit == null ? vv : '$vv $unit';
          return;
        }
      }
    }

    pick('Calories', ['calories', 'kcal'], unit: 'kcal');
    pick('Carbs', ['carbs', 'carbohydrates', 'carbohydrate'], unit: 'g');
    pick('Protein', ['protein'], unit: 'g');
    pick('Fat', ['fat', 'total_fat'], unit: 'g');
    pick('Fiber', ['fiber', 'dietary_fiber'], unit: 'g');
    pick('Sugar', ['sugar', 'sugars'], unit: 'g');
    pick('Sodium', ['sodium'], unit: 'mg');
    pick('Sat. Fat', ['saturated_fat', 'saturatedfat', 'sat_fat'], unit: 'g');

    return out;
  }

  // 제약조건(Constraints) 표준화: 한글/영문/변형을 영어로 정규화
  List<String> _normalizeRestrictions(List<String> raw) {
    final norm = <String>{};

    String canon(String s) =>
        s.toLowerCase().replaceAll(RegExp(r'[\s\-\_]+'), '');

    const mapping = <String, String>{
      // gluten
      'glutenfree': '글루텐 프리',
      '무글루텐': '글루텐 프리',
      '글루텐프리': '글루텐 프리',
      // dairy
      'dairyfree': '유제품 프리',
      '무유제품': '유제품 프리',
      '유제품무첨가': '유제품 프리',
      '락토프리': '유당 프리',
      '무유당': '유당 프리',
      'lactosefree': '유당 프리',
      // vegan/vegetarian
      'vegan': '비건',
      '비건': '비건',
      'vegetarian': '채식',
      '채식': '채식',
      // keto/paleo/whole30
      'keto': '키토',
      '키토': '키토',
      'paleo': '팔레오',
      '팔레오': '팔레오',
      'whole30': 'Whole30',
      // protein/carbs/fat/sugar/sodium/fiber/calorie
      '고단백': '고단백',
      'highprotein': '고단백',
      '저탄수': '저탄수화물',
      '저탄수화물': '저탄수화물',
      'lowcarb': '저탄수화물',
      '저지방': '저지방',
      'lowfat': '저지방',
      '저당': '저당',
      'lowsugar': '저당',
      '저나트륨': '저나트륨',
      'lowsodium': '저나트륨',
      '고섬유': '고섬유',
      'highfiber': '고섬유',
      '저칼로리': '저칼로리',
      'lowcalorie': '저칼로리',
      // religious
      'halal': '할랄',
      '할랄': '할랄',
      'kosher': '코셔',
      '코셔': '코셔',
      // allergens
      'nutfree': '견과류 프리',
      '견과류없음': '견과류 프리',
      'peanutfree': '땅콩 프리',
      '땅콩없음': '땅콩 프리',
      'eggfree': '계란 프리',
      '계란없음': '계란 프리',
      'shellfishfree': '갑각류 프리',
      '갑각류없음': '갑각류 프리',
      'seaffodfree': '해산물 프리',
      '해산물없음': '해산물 프리',
      'nopork': '돼지고기 제외',
      '돼지고기없음': '돼지고기 제외',
    };

    for (final r in raw) {
      final c = canon(r);
      if (c.isEmpty) continue;
      // 정확히 일치하거나 포함(예: 'gluten free')
      String? hit = mapping[c];
      hit ??= mapping.entries
          .firstWhere(
            (e) => c.contains(e.key),
            orElse: () => const MapEntry('', ''),
          )
          .value;
      norm.add((hit ?? '').isNotEmpty ? hit! : r); // 미정규화 항목은 원문 유지
    }

    return norm.toList()..sort();
  }

  /// 영양소/재료를 바탕으로 "추론" 제약조건 생성 (영어)
  List<String> _deriveConstraints(
    Map<String, dynamic> nutrition,
    List<String> ingredients,
  ) {
    final result = <String>{};

    num? _num(List<String> keys) {
      for (final k in keys) {
        if (nutrition.containsKey(k)) {
          final v = nutrition[k];
          if (v is num) return v;
          final p = num.tryParse(v.toString());
          if (p != null) return p;
        }
      }
      return null;
    }

    final cal = _num(['calories_kcal', 'kcal', 'calories']);
    final carb = _num(['carbohydrate_g', 'carbs_g', 'carbs']);
    final protein = _num(['protein_g', 'protein']);
    final fat = _num(['fat_g', 'fat']);
    final sugar = _num(['sugar_g', 'sugar']);
    final fiber = _num(['fiber_g', 'fiber']);
    final sodium = _num(['sodium_mg', 'sodium']);

    // 매우 보편적인 컷오프 (일반 1회 제공량 기준)
    if (cal != null && cal <= 300) result.add('저칼로리');
    if (carb != null && carb <= 20) result.add('저탄수화물');
    if (protein != null && protein >= 20) result.add('고단백');
    if (fat != null && fat <= 10) result.add('저지방');
    if (sugar != null && sugar <= 5) result.add('저당');
    if (fiber != null && fiber >= 5) result.add('고섬유');
    if (sodium != null && sodium <= 140) result.add('저나트륨');

    // 재료 키워드로 추가 시사점 (확정 불가이므로 보수적으로)
    final ingText = ingredients.join(' ').toLowerCase();
    bool notContainsAny(List<String> keys) =>
        !keys.any((k) => ingText.contains(k));

    // dairy-free 추정: 우유/치즈/버터 키워드가 없으면 굳이 단정하지 않음 → 패스
    // vegan/vegetarian도 보수적으로 패스

    return result.toList()..sort();
  }

  String? _normalizeUrl(String? url) {
    if (url == null) return null;
    final u = url.trim();
    if (u.isEmpty) return null;
    if (u.startsWith('//')) return 'https:$u';
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      return 'https://$u';
    }
    return u;
  }

  /// 음식 이름으로 대체 이미지(HTTPS, hotlink 허용)
  String _fallbackImageFor(String query) {
    final q = Uri.encodeComponent(
      (query.isEmpty ? 'food' : query) + ',food,meal,plate',
    );
    return 'https://source.unsplash.com/512x512/?$q';
  }

  // ─────────── UI ───────────

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _loading
          ? const _Skeleton()
          : _error != null
          ? _ErrorView(message: _error!, onRetry: _loadFromService)
          : _Content(
              foodName: widget.foodName,
              foodId: widget.foodId,
              imageUrl: _imageUrl,
              nutrition: _nutrition,
              ingredients: _ingredients,
              restrictions: _restrictions,
            ),
    );
  }
}

class _Content extends StatelessWidget {
  final String foodName;
  final String foodId;
  final String? imageUrl;
  final Map<String, String> nutrition;
  final List<String> ingredients;
  final List<String> restrictions;

  const _Content({
    required this.foodName,
    required this.foodId,
    required this.imageUrl,
    required this.nutrition,
    required this.ingredients,
    required this.restrictions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(foodName: foodName, foodId: foodId, imageUrl: imageUrl),
          const SizedBox(height: 16),
          if (nutrition.isNotEmpty) _NutritionCard(nutrition: nutrition),
          if (nutrition.isNotEmpty) const SizedBox(height: 16),
          if (ingredients.isNotEmpty)
            _ChipsSection(title: "Ingredients", chips: ingredients),
          if (ingredients.isNotEmpty) const SizedBox(height: 16),
          if (restrictions.isNotEmpty)
            _ChipsSection(title: "Constraints", chips: restrictions),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String foodName;
  final String foodId;
  final String? imageUrl;

  const _Header({required this.foodName, required this.foodId, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 84,
            height: 84,
            child: (imageUrl == null || imageUrl!.isEmpty)
                ? _ImagePlaceholder()
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    cacheWidth: 252, // 84 * 3 for 3x pixel density
                    cacheHeight: 252,
                    headers: const {"User-Agent": "Mozilla/5.0"},
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const _ImageLoadingSkeleton();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const _ImageErrorPlaceholder();
                    },
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                foodName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "ID: $foodId",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F4F8),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.grey),
      ),
    );
  }
}

class _ImageLoadingSkeleton extends StatelessWidget {
  const _ImageLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFEFF3F8));
  }
}

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDECEC),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.redAccent),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final Map<String, String> nutrition;

  const _NutritionCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    const preferred = ["Calories", "Carbs", "Protein", "Fat", "Fiber", "Sugar"];
    final keys = <String>[
      ...preferred.where(nutrition.containsKey),
      ...nutrition.keys.where((k) => !preferred.contains(k)).toList()..sort(),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        border: Border.all(color: const Color(0xFFE3E8EF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nutrition (per serving)",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: keys
                .map((k) => _MetricPill(label: k, value: nutrition[k] ?? "—"))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE3E8EF)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}

class _ChipsSection extends StatelessWidget {
  final String title;
  final List<String> chips;

  const _ChipsSection({required this.title, required this.chips});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE3E8EF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (c) => Chip(
                    label: Text(c),
                    backgroundColor: const Color(0xFFF7F9FB),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFFE3E8EF)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              _box(w: 84, h: 84),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(w: double.infinity, h: 18),
                    const SizedBox(height: 8),
                    _box(w: 120, h: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _box(w: double.infinity, h: 140, radius: 12),
          const SizedBox(height: 16),
          _box(w: double.infinity, h: 120, radius: 12),
        ],
      ),
    );
  }

  Widget _box({required double w, required double h, double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F8),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
