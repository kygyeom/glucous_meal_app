import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HardwareKeyboard.clearState
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:glucous_meal_app/services/api_service.dart'
    show ApiService, FoodHit;
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

  // Image analysis state
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _analyzingImage = false;
  Map<String, dynamic>? _imageAnalysisResult;

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

  Future<void> _loadUserProfile() async {
    if (_loadingProfile) return;

    setState(() => _loadingProfile = true);

    try {
      final profile = await ApiService.fetchUserProfile();

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _loadingProfile = false;
        });
      }
    } catch (e) {
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

  @override
  void reassemble() {
    super.reassemble();
    try {
      HardwareKeyboard.instance.clearState();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      try {
        HardwareKeyboard.instance.clearState();
      } catch (_) {}
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('혈당 예측이 완료되었습니다!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
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

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이미지 선택'),
          content: const Text('이미지를 가져올 방법을 선택하세요'),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('카메라'),
              onPressed: () {
                Navigator.of(context).pop();
                _pickAndAnalyzeImage(ImageSource.camera);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('갤러리'),
              onPressed: () {
                Navigator.of(context).pop();
                _pickAndAnalyzeImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return false;

      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('권한 필요'),
          content: const Text('이 기능을 사용하려면 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('설정 열기'),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
      return false;
    }

    return false;
  }

  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    try {
      // Request appropriate permissions
      bool hasPermission = false;

      if (source == ImageSource.camera) {
        hasPermission = await _requestPermission(Permission.camera);
      } else {
        // For gallery, request photos permission
        if (Platform.isAndroid) {
          // Android 13+ uses READ_MEDIA_IMAGES
          if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
            hasPermission = true;
          } else {
            hasPermission = await _requestPermission(Permission.photos) ||
                           await _requestPermission(Permission.storage);
          }
        } else {
          hasPermission = await _requestPermission(Permission.photos);
        }
      }

      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('권한이 거부되었습니다'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Pick image from selected source
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _analyzingImage = true;
        _imageAnalysisResult = null;
      });

      // Upload and analyze image
      final uri = Uri.parse('$kBackendBase/analyze-image');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));

        print('✅ Image analysis successful!');
        final foods = result['foods'] as List<dynamic>? ?? [];
        final totalNutrition = result['total_nutrition'] as Map<String, dynamic>?;

        print('🍽️ Detected ${foods.length} food items:');
        for (var food in foods) {
          print('   - ${food['food_name']} (confidence: ${food['confidence']})');
        }
        print('📊 Total Nutrition: $totalNutrition');

        setState(() {
          _analyzingImage = false;
          _imageAnalysisResult = result;
        });

        // Auto-fill nutrition fields from total nutrition (sum of all foods)
        if (totalNutrition != null) {
          _carbohydrateController.text = totalNutrition['carbohydrate_g']?.toString() ?? '';
          _caloriesController.text = totalNutrition['calories_kcal']?.toString() ?? '';
          _proteinController.text = totalNutrition['protein_g']?.toString() ?? '';
          _fatController.text = totalNutrition['fat_g']?.toString() ?? '';

          print('✅ Auto-filled nutrition fields with total values');
        }

        // Show success message with count of detected foods
        String message = foods.length == 1
            ? '${foods[0]['food_name']}이(가) 인식되었습니다!'
            : '${foods.length}가지 음식이 인식되었습니다!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        print('❌ Analysis failed with status: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        throw Exception('이미지 분석 실패: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _analyzingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 분석 중 오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

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
    // final double topGap = MediaQuery.of(context).size.height * 0.18;
    // final double topGap = MediaQuery.of(context).size.height * 0.18;
    final double topGap = 0;

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
    return RepaintBoundary(
      child: SingleChildScrollView(
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

                // 이미지 업로드 버튼
                OutlinedButton.icon(
                  onPressed: _analyzingImage ? null : _showImageSourceDialog,
                  icon: _analyzingImage
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt),
                  label: Text(_analyzingImage ? '이미지 분석 중...' : '사진으로 영양 정보 입력'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF00FFD1), width: 2),
                    foregroundColor: const Color(0xFF0076FF),
                  ),
                ),

                // 이미지 분석 결과 표시 (다중 음식 지원)
                if (_imageAnalysisResult != null) ...[
                  const SizedBox(height: 16),
                  RepaintBoundary(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade50, Colors.green.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.green.shade400, width: 2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.restaurant, color: Colors.green.shade700, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'AI 분석 완료 (${(_imageAnalysisResult!['foods'] as List).length}개 음식)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 모든 인식된 음식 표시 (개별 영양 정보 포함)
                          ...(_imageAnalysisResult!['foods'] as List).asMap().entries.map((entry) {
                            final int index = entry.key;
                            final food = entry.value as Map<String, dynamic>;
                            final nutrition = food['estimated_nutrition'] as Map<String, dynamic>?;

                            return Column(
                              children: [
                                if (index > 0) const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade700,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              food['food_name'] ?? 'Unknown',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade900,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            food['confidence'] == 'high'
                                                ? Icons.star
                                                : food['confidence'] == 'medium'
                                                    ? Icons.star_half
                                                    : Icons.star_border,
                                            color: Colors.amber.shade700,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                      if (food['description'] != null &&
                                          food['description'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          food['description'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],

                                      // 개별 음식의 영양 정보 표시
                                      if (nutrition != null) ...[
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.restaurant_menu,
                                                    color: Colors.grey.shade600, size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '영양 정보',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 6,
                                                children: [
                                                  _buildSmallNutritionChip(
                                                    '칼로리',
                                                    '${nutrition['calories_kcal']?.toStringAsFixed(0) ?? '0'}',
                                                    'kcal',
                                                    Colors.red.shade100,
                                                    Colors.red.shade700,
                                                  ),
                                                  _buildSmallNutritionChip(
                                                    '탄수화물',
                                                    '${nutrition['carbohydrate_g']?.toStringAsFixed(1) ?? '0'}',
                                                    'g',
                                                    Colors.orange.shade100,
                                                    Colors.orange.shade700,
                                                  ),
                                                  _buildSmallNutritionChip(
                                                    '단백질',
                                                    '${nutrition['protein_g']?.toStringAsFixed(1) ?? '0'}',
                                                    'g',
                                                    Colors.blue.shade100,
                                                    Colors.blue.shade700,
                                                  ),
                                                  _buildSmallNutritionChip(
                                                    '지방',
                                                    '${nutrition['fat_g']?.toStringAsFixed(1) ?? '0'}',
                                                    'g',
                                                    Colors.purple.shade100,
                                                    Colors.purple.shade700,
                                                  ),
                                                  if (nutrition['sugar_g'] != null && nutrition['sugar_g'] > 0)
                                                    _buildSmallNutritionChip(
                                                      '당류',
                                                      '${nutrition['sugar_g']?.toStringAsFixed(1) ?? '0'}',
                                                      'g',
                                                      Colors.pink.shade100,
                                                      Colors.pink.shade700,
                                                    ),
                                                  if (nutrition['fiber_g'] != null && nutrition['fiber_g'] > 0)
                                                    _buildSmallNutritionChip(
                                                      '식이섬유',
                                                      '${nutrition['fiber_g']?.toStringAsFixed(1) ?? '0'}',
                                                      'g',
                                                      Colors.green.shade100,
                                                      Colors.green.shade700,
                                                    ),
                                                  if (nutrition['sodium_mg'] != null && nutrition['sodium_mg'] > 0)
                                                    _buildSmallNutritionChip(
                                                      '나트륨',
                                                      '${nutrition['sodium_mg']?.toStringAsFixed(0) ?? '0'}',
                                                      'mg',
                                                      Colors.amber.shade100,
                                                      Colors.amber.shade700,
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),

                          const SizedBox(height: 16),

                          // 총 영양 정보 표시
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.summarize, color: Colors.blue.shade700, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      '총 영양 정보 (자동 입력됨)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildNutritionSummary(_imageAnalysisResult!['total_nutrition']),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

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
                        borderRadius: const BorderRadius.all(
                          Radius.circular(24),
                        ),
                      ),
                      child: Center(
                        child: _predicting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
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
                  RepaintBoundary(
                    child: Container(
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
                  ),
                ],
              ],
            ),
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
    return RepaintBoundary(
      child: Container(
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
      ),
    );
  }

  Widget _buildNutritionSummary(Map<String, dynamic>? nutrition) {
    if (nutrition == null) return const SizedBox();

    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        _buildNutritionChip('칼로리', '${nutrition['calories_kcal']?.toStringAsFixed(0) ?? '0'} kcal'),
        _buildNutritionChip('탄수화물', '${nutrition['carbohydrate_g']?.toStringAsFixed(1) ?? '0'} g'),
        _buildNutritionChip('단백질', '${nutrition['protein_g']?.toStringAsFixed(1) ?? '0'} g'),
        _buildNutritionChip('지방', '${nutrition['fat_g']?.toStringAsFixed(1) ?? '0'} g'),
      ],
    );
  }

  Widget _buildNutritionChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallNutritionChip(
    String label,
    String value,
    String unit,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 9,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// (기존) 음식 디테일 임베드
  Widget _buildEmbeddedFoodDetail() {
    final hit = _selectedHit!;
    return RepaintBoundary(
      child: Container(
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
      ),
    );
  }

  /// ✅ 프로필 디테일 임베드 (틀은 위와 동일, 내용만 UserProfileDetail)
  Widget _buildEmbeddedProfile() {
    return RepaintBoundary(
      child: Container(
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
      ),
    );
  }
}
