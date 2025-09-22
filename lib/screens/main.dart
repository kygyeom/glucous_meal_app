/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:glucous_meal_app/services/api_service.dart'
    show ApiService, FoodHit;
import 'package:glucous_meal_app/services/debouncer.dart';
import 'package:glucous_meal_app/screens/food_detail_screen.dart';

/// 서버 베이스 주소는 빌드타임 환경변수로 주입하세요.
/// 예) flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
const String kBackendBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

class Main extends StatefulWidget {
  final String username;

  const Main({super.key, required this.username});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final TextEditingController _controller = TextEditingController();

  // Search optimization state
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 350));
  final _results = ValueNotifier<List<FoodHit>>(<FoodHit>[]);
  bool _loading = false;
  String _lastQuery = '';

  // 같은 프레임 내에서 디테일을 임베드하기 위한 선택 아이템
  FoodHit? _selectedHit;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {}); // clear(X) 버튼 토글
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    _results.dispose();
    super.dispose();
  }

  void _onQueryChanged(String q) {
    final next = q.trim();
    if (next == _lastQuery) return; // 같은 질의는 무시
    _lastQuery = next;

    _debouncer(() async {
      if (_lastQuery.length < 2) {
        _results.value = const [];
        if (mounted) setState(() => _loading = false);
        return;
      }
      if (mounted) setState(() => _loading = true);

      final data = await ApiService.searchFoodsWithIds(_lastQuery);

      if (!mounted) return;
      if (_lastQuery == next) {
        _results.value = data;
        setState(() => _loading = false);
      }
    });
  }

  void _openDetail(FoodHit hit) => setState(() => _selectedHit = hit);
  void _closeDetail() => setState(() => _selectedHit = null);

  @override
  Widget build(BuildContext context) {
    final double topGap =
        MediaQuery.of(context).size.height * 0.18; // 검색 섹션을 위로 올리기

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        // 디테일 모드일 때만 뒤로가기 표시(같은 프레임에서 목록↔상세 전환)
        leading: _selectedHit != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _closeDetail,
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(
                Icons.person_outline,
                color: Colors.black,
              ), // 프로필 아이콘
              onPressed: () {
                // TODO: 프로필 화면으로 이동
              },
            ),
          ),
        ],
        // AppBar 하단: 그라데이션 바 + 문구(고정)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(86),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
              const SizedBox(height: 4),
              const Text(
                "You're not alone in this anymore :)",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '- ${widget.username} -',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        // 같은 프레임에서 Search <-> Detail 전환
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _selectedHit == null
              ? _buildSearchView(topGap)
              : _buildEmbeddedDetail(),
        ),
      ),
    );
  }

  /// 검색 화면
  Widget _buildSearchView(double topGap) {
    return SingleChildScrollView(
      key: const ValueKey('search'),
      padding: EdgeInsets.fromLTRB(16, topGap, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Want to know more about your meals?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // 🔍 검색 입력 박스
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
                        controller: _controller,
                        onChanged: _onQueryChanged,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: "Search for any food you're interested in",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        splashRadius: 18,
                        onPressed: () {
                          _controller.clear();
                          _onQueryChanged('');
                          _results.value = const [];
                          if (mounted) setState(() => _loading = false);
                        },
                      ),
                  ],
                ),
              ),

              // ⏳ 로딩 인디케이터
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFFD0E8FF),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00B8D4),
                    ),
                  ),
                ),

              // 🧠 자동완성 결과 리스트
              ValueListenableBuilder<List<FoodHit>>(
                valueListenable: _results,
                builder: (context, items, _) {
                  if (items.isEmpty) {
                    return const SizedBox(height: 8);
                  }
                  return Container(
                    height: 168, // 고정: 스크롤 충돌 방지
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context2, index) {
                        final hit = items[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            hit.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _openDetail(hit), // 같은 프레임에서 상세 열기
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// 디테일 화면(임베드) — 서버(main.py) 그대로 사용하여 직접 호출
  Widget _buildEmbeddedDetail() {
    final hit = _selectedHit!;
    return Container(
      key: const ValueKey('detail'),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: FoodDetailScreen(
          foodName: hit.name,
          foodId: hit.id,
          embedded: true,
          // ✅ ApiService를 건드리지 않고 main.py의 /food 엔드포인트를 직접 사용
          loadDetail: (id) async {
            final uri = Uri.parse(
              '$kBackendBase/food',
            ).replace(queryParameters: {'food_id': id});
            final res = await http.get(
              uri,
              headers: const {'Accept': 'application/json'},
            );
            if (res.statusCode < 200 || res.statusCode >= 300) {
              throw Exception('HTTP ${res.statusCode}: ${res.body}');
            }
            final Map<String, dynamic> data = json.decode(res.body);

            // 서버 스키마에 맞춰 그대로 매핑
            final imageUrl = (data['image_url'] as String?)?.trim();
            final ingredients =
                (data['ingredients'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const <String>[];
            final nutrients = (data['nutrients'] as Map?)
                ?.cast<String, dynamic>();

            return FoodDetailData(
              imageUrl: imageUrl,
              nutrition: nutrients,
              ingredients: ingredients,
              // /food 응답에는 restrictions 없음 → 빈 리스트
              restrictions: const [],
            );
          },
        ),
      ),
    );
  }
}
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HardwareKeyboard.clearState
import 'package:http/http.dart' as http;

import 'package:glucous_meal_app/services/api_service.dart'
    show ApiService, FoodHit;
import 'package:glucous_meal_app/services/debouncer.dart';
import 'package:glucous_meal_app/screens/food_detail_screen.dart';

/// 서버 베이스 주소 (필요 시 변경)
/// flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
const String kBackendBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

class Main extends StatefulWidget {
  final String username;

  const Main({super.key, required this.username});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();

  // Search state
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 350));
  final _results = ValueNotifier<List<FoodHit>>(<FoodHit>[]);
  bool _loading = false;
  String _lastQuery = '';

  // 같은 프레임에서 상세 표시
  FoodHit? _selectedHit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(() {
      if (mounted) setState(() {}); // clear(X) 버튼 토글
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _debouncer.dispose();
    _results.dispose();
    super.dispose();
  }

  // 디버그 핫리로드 직후 stuck key 방지
  @override
  void reassemble() {
    super.reassemble();
    _clearStuckKeys();
  }

  // 창이 다시 포커스를 얻으면 키 상태 초기화
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clearStuckKeys();
    }
  }

  void _clearStuckKeys() {
    try {
      // 일부 Flutter 버전엔 없을 수 있으니 try/catch
      HardwareKeyboard.instance.clearState();
    } catch (_) {}
  }

  void _onQueryChanged(String q) {
    final next = q.trim();
    if (next == _lastQuery) return; // 같은 질의 무시
    _lastQuery = next;

    _debouncer(() async {
      if (_lastQuery.length < 2) {
        _results.value = const [];
        if (mounted) setState(() => _loading = false);
        return;
      }
      if (mounted) setState(() => _loading = true);

      final data = await ApiService.searchFoodsWithIds(_lastQuery);

      if (!mounted) return;
      if (_lastQuery == next) {
        _results.value = data;
        setState(() => _loading = false);
      }
    });
  }

  void _openDetail(FoodHit hit) => setState(() => _selectedHit = hit);
  void _closeDetail() => setState(() => _selectedHit = null);

  @override
  Widget build(BuildContext context) {
    // 검색 영역을 화면 위쪽에 고정 느낌으로 배치 (안정적인 padding 값)
    final double topGap = MediaQuery.of(context).size.height * 0.18;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        // 상세 모드일 때만 뒤로가기
        leading: _selectedHit != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _closeDetail,
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: () {
                // TODO: 프로필 화면으로 이동
              },
            ),
          ),
        ],
        // AppBar 하단: 그라데이션 + 문구
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(86),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
              const SizedBox(height: 4),
              const Text(
                "You're not alone in this anymore :)",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '- ${widget.username} -',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        // 같은 프레임에서 Search <-> Detail 전환
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _selectedHit == null
              ? _buildSearchView(topGap)
              : _buildEmbeddedDetail(),
        ),
      ),
    );
  }

  /// 검색 화면
  Widget _buildSearchView(double topGap) {
    return SingleChildScrollView(
      key: const ValueKey('search'),
      padding: EdgeInsets.fromLTRB(16, topGap, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Want to know more about your meals?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // 🔍 검색 입력 박스
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
                        onTap: _clearStuckKeys, // 포커스 시 key state 정리
                        controller: _controller,
                        onChanged: _onQueryChanged,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: "Search for any food you're interested in",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        splashRadius: 18,
                        onPressed: () {
                          _controller.clear();
                          _onQueryChanged('');
                          _results.value = const [];
                          if (mounted) setState(() => _loading = false);
                        },
                      ),
                  ],
                ),
              ),

              // ⏳ 로딩 인디케이터
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFFD0E8FF),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00B8D4),
                    ),
                  ),
                ),

              // 🧠 자동완성 결과 리스트
              ValueListenableBuilder<List<FoodHit>>(
                valueListenable: _results,
                builder: (context, items, _) {
                  if (items.isEmpty) {
                    return const SizedBox(height: 8);
                  }
                  return Container(
                    height: 168, // 고정: 스크롤 충돌 방지
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context2, index) {
                        final hit = items[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            hit.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _openDetail(hit), // 같은 프레임에서 상세 열기
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// 디테일 화면(임베드) — main.py의 /food 사용 (ApiService 수정 없이)
  Widget _buildEmbeddedDetail() {
    final hit = _selectedHit!;
    return Container(
      key: const ValueKey('detail'),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: FoodDetailScreen(
          foodName: hit.name,
          foodId: hit.id,
          embedded: true,
          loadDetail: (id) async {
            final uri = Uri.parse(
              '$kBackendBase/food',
            ).replace(queryParameters: {'food_id': id});
            final res = await http.get(
              uri,
              headers: const {'Accept': 'application/json'},
            );
            if (res.statusCode < 200 || res.statusCode >= 300) {
              throw Exception('HTTP ${res.statusCode}: ${res.body}');
            }
            final Map<String, dynamic> data = json.decode(res.body);

            final imageUrl = (data['image_url'] as String?)?.trim();
            final ingredients =
                (data['ingredients'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const <String>[];
            final nutrients = (data['nutrients'] as Map?)
                ?.cast<String, dynamic>();

            return FoodDetailData(
              imageUrl: imageUrl,
              nutrition: nutrients,
              ingredients: ingredients,
              // 서버 응답에 제약조건이 없으면 빈 리스트
              restrictions: const [],
            );
          },
        ),
      ),
    );
  }
}
