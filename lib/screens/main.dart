import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HardwareKeyboard.clearState
import 'package:http/http.dart' as http;

import 'package:glucous_meal_app/services/api_service.dart'
    show ApiService, FoodHit;
import 'package:glucous_meal_app/services/debouncer.dart';
import 'package:glucous_meal_app/screens/food_detail_screen.dart';

// ✅ 새 프로필 '내용 위젯'
import 'package:glucous_meal_app/screens/user_profile_details_screen.dart';
import 'package:glucous_meal_app/models/models.dart';

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
  // Nutrition input controllers
  final TextEditingController _carbohydrateController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();

  // Prediction state
  bool _predicting = false;
  Map<String, double>? _predictionResult;

  // 같은 프레임에서 상세 표시
  FoodHit? _selectedHit;

  // ✅ 프로필 모드 플래그 (검색 상세와 동일 '틀' 사용)
  bool _showProfile = false;

  // ✅ 실제 유저 프로필 데이터
  UserProfile? _userProfile;
  bool _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserProfile(); // 앱 시작 시 유저 프로필 로드
  }

  // 유저 프로필 로드
  Future<void> _loadUserProfile() async {
    if (_loadingProfile) return;

    print("🔄 Starting to load user profile...");
    setState(() => _loadingProfile = true);

    try {
      final profile = await ApiService.fetchUserProfile();
      print("📥 Received profile: $profile");

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _loadingProfile = false;
        });

        if (profile != null) {
          print("✅ Profile loaded successfully: name=${profile.name}, age=${profile.age}");
        } else {
          print("⚠️ Profile is null");
        }
      }
    } catch (e, stackTrace) {
      print("❌ Error in _loadUserProfile: $e");
      print("❌ Stack trace: $stackTrace");

      if (mounted) {
        setState(() => _loadingProfile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _carbohydrateController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
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
      HardwareKeyboard.instance.clearState();
    } catch (_) {}
  }

  Future<void> _predictGlucose() async {
    // Validate inputs
    final carb = double.tryParse(_carbohydrateController.text);
    final cal = double.tryParse(_caloriesController.text);
    final protein = double.tryParse(_proteinController.text);
    final fat = double.tryParse(_fatController.text);

    if (carb == null || cal == null || protein == null || fat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 영양 정보를 올바르게 입력해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if user profile is loaded
    if (_userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용자 프로필을 불러오는 중입니다. 잠시 후 다시 시도해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _predicting = true);

    try {
      print("🔄 Starting glucose prediction...");
      print("📊 Input: carb=$carb, cal=$cal, protein=$protein, fat=$fat");

      final result = await ApiService.predictGlucose(
        carbohydrateG: carb,
        caloriesKcal: cal,
        proteinG: protein,
        fatG: fat,
      );

      if (!mounted) return;

      setState(() {
        _predicting = false;
        _predictionResult = result;
      });

      if (result != null) {
        print("✅ Prediction successful: $result");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('혈당 예측이 완료되었습니다!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("❌ Prediction error: $e");
      if (!mounted) return;
      setState(() => _predicting = false);

      String errorMessage = '예측에 실패했습니다';
      if (e.toString().contains('사용자 등록이 필요')) {
        errorMessage = '사용자 등록이 필요합니다. 앱을 재시작하고 프로필을 설정해주세요.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '서버에 연결할 수 없습니다. 서버가 실행 중인지 확인해주세요.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _openDetail(FoodHit hit) => setState(() {
    _selectedHit = hit;
    _showProfile = false;
  });

  void _openProfile() => setState(() {
    _selectedHit = null;
    _showProfile = true;
  });

  void _closeAny() => setState(() {
    _selectedHit = null;
    _showProfile = false;
  });

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
        // 상세/프로필 모드일 때만 뒤로가기
        leading: (_selectedHit != null || _showProfile)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _closeAny,
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: _openProfile, // ✅ 같은 틀로 프로필 열기
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
                "이제 혼자가 아니에요 :)",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '- 홍길동 -',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        // 같은 프레임에서 Search <-> Detail <-> Profile 전환
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: (_selectedHit != null)
              ? _buildEmbeddedFoodDetail()
              : (_showProfile)
              ? _buildEmbeddedProfile()
              : _buildSearchView(topGap),
        ),
      ),
    );
  }

  /// 혈당 예측 입력 화면
  Widget _buildSearchView(double topGap) {
    return SingleChildScrollView(
      key: const ValueKey('glucose_input'),
      padding: EdgeInsets.fromLTRB(16, topGap, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "영양 정보를 입력하고 혈당을 예측하세요",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),

              // 탄수화물 입력
              _buildNutritionInput(
                label: "탄수화물 (g)",
                controller: _carbohydrateController,
                icon: Icons.grain,
              ),
              const SizedBox(height: 16),

              // 칼로리 입력
              _buildNutritionInput(
                label: "칼로리 (kcal)",
                controller: _caloriesController,
                icon: Icons.local_fire_department,
              ),
              const SizedBox(height: 16),

              // 단백질 입력
              _buildNutritionInput(
                label: "단백질 (g)",
                controller: _proteinController,
                icon: Icons.egg,
              ),
              const SizedBox(height: 16),

              // 지방 입력
              _buildNutritionInput(
                label: "지방 (g)",
                controller: _fatController,
                icon: Icons.water_drop,
              ),
              const SizedBox(height: 24),

              // 예측 버튼
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _predicting ? null : _predictGlucose,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: _predicting
                          ? const LinearGradient(
                              colors: [Colors.grey, Colors.grey],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF00FFD1), Color(0xFF0076FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                    ),
                    child: Center(
                      child: _predicting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              '혈당 예측',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              // 예측 결과 표시
              if (_predictionResult != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue.shade50,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '예측 결과',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultRow(
                        '최대 혈당',
                        '${_predictionResult!['max_glucose']!.toStringAsFixed(1)} mg/dL',
                        Colors.red.shade700,
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        '혈당 변화량',
                        '${_predictionResult!['delta_glucose']!.toStringAsFixed(1)} mg/dL',
                        Colors.orange.shade700,
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        '현재 평균 혈당',
                        '${_predictionResult!['average_glucose']!.toStringAsFixed(1)} mg/dL',
                        Colors.blue.shade700,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// (기존) 음식 디테일 임베드
  Widget _buildEmbeddedFoodDetail() {
    final hit = _selectedHit!;
    return Container(
      key: const ValueKey('food_detail'),
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
              restrictions: const [],
            );
          },
        ),
      ),
    );
  }

  /// ✅ 프로필 디테일 임베드 (틀은 위와 동일, 내용만 UserProfileDetail)
  Widget _buildEmbeddedProfile() {
    return Container(
      key: const ValueKey('profile_detail'),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: _loadingProfile
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('프로필 로딩 중...'),
                  ],
                ),
              )
            : UserProfileDetail(
                userProfile: _userProfile,
                onProfileUpdated: _loadUserProfile,
              ),
      ),
    );
  }
}
