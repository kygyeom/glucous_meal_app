import 'package:flutter/material.dart';
import 'dart:math';
import 'package:glucous_meal_app/models/models.dart';
import 'package:glucous_meal_app/services/api_service.dart';
import 'package:glucous_meal_app/screens/glucous_loading_screen.dart';
import 'package:glucous_meal_app/screens/main.dart' as main_screen;
import 'package:video_player/video_player.dart';

/// Unified Onboarding Screen - All steps in one page with smooth transitions
/// Memory-efficient: No Navigator.push stacking
/// Steps 0-4: User profile onboarding
/// Steps 5-9: Feature demo screens
/// Step 10: Subscription (with registration)
class UnifiedOnboardingScreen extends StatefulWidget {
  const UnifiedOnboardingScreen({super.key});

  @override
  State<UnifiedOnboardingScreen> createState() => _UnifiedOnboardingScreenState();
}

class _UnifiedOnboardingScreenState extends State<UnifiedOnboardingScreen>
    with SingleTickerProviderStateMixin {

  // Current step index (0-10: onboarding + demos + subscription)
  int _currentStep = 0;

  // Video player for subscription screen
  VideoPlayerController? _videoController;

  // Beta code controller
  final TextEditingController _betaCodeController = TextEditingController();

  // Subscription plan selection
  String selectedPlan = 'basic';

  // Progress animation controller
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // Form data collected across steps
  String name = '';
  int? age;
  String gender = 'male';
  double? height;
  double? weight;
  String activityLevel = 'high';
  String diabetes = 'none';
  String goal = 'blood_sugar_control';
  List<String> selectedMeals = ['Lunch', 'Dinner'];
  String selectedMealMethod = 'Direct cooking';
  List<String> selectedRestrictions = ['None'];
  List<String> selectedAllergies = ['None'];
  double averageGlucose = 100.0;
  bool agreedToTerms = false;

  // Form keys for validation
  final _profileFormKey = GlobalKey<FormState>();
  final _conditionFormKey = GlobalKey<FormState>();
  final TextEditingController _averageGlucoseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _averageGlucoseController.dispose();
    _betaCodeController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // Smooth progress animation to next step
  void _goToStep(int step) {
    if (step < 0 || step > 10) return;

    setState(() {
      _currentStep = step;
    });

    // Initialize video controller when reaching subscription step
    if (step == 10 && _videoController == null) {
      _initializeVideoController();
    }

    // Animate progress bar
    final double targetProgress = (step + 1) / 11.0;
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: targetProgress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward(from: 0.0);
  }

  void _initializeVideoController() {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
    )..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController?.play();
          _videoController?.setLooping(true);
        }
      });
  }

  void _nextStep() {
    // Validate current step before proceeding
    if (_currentStep == 0) {
      // Validate profile form
      if (!_profileFormKey.currentState!.validate()) return;
    } else if (_currentStep == 3) {
      // Validate condition form (now step 3 instead of 4)
      if (!_conditionFormKey.currentState!.validate()) return;
      if (!agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('개인 정보 사용에 동의해주세요')),
        );
        return;
      }
    }

    if (_currentStep < 10) {
      _goToStep(_currentStep + 1);
    } else {
      // Step 10 is subscription - submit registration
      _submitRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  Future<void> _submitRegistration() async {
    final double bmi = weight! / pow(height! / 100, 2);

    final userProfile = UserProfile(
      name: name,
      age: age!,
      gender: gender,
      weight: weight!,
      height: height!,
      bmi: bmi,
      activityLevel: activityLevel,
      goal: goal,
      diabetes: diabetes,
      meals: selectedMeals,
      mealMethod: selectedMealMethod,
      dietaryRestrictions: selectedRestrictions,
      allergies: selectedAllergies,
      averageGlucose: averageGlucose,
    );

    // Show loading overlay
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GlucousLoadingOverlay(),
    );

    try {
      // Register user with backend
      await ApiService.registerUser(userProfile);

      // Fetch recommendations
      await ApiService.fetchRecommendations(userProfile);

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Use pushReplacement to dispose entire onboarding flow and navigate to Main
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => main_screen.Main(username: name),
        ),
      );
    } catch (e) {
      // Handle registration error
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('등록 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Animated progress bar
            _buildAnimatedProgressBar(),

            // Main content with smooth transitions
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildCurrentStep(),
              ),
            ),

            // Bottom button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Back button (hidden on first step)
              if (_currentStep > 0)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: _previousStep,
                )
              else
                const SizedBox(width: 48),

              const SizedBox(width: 12),

              // Progress bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    tween: Tween<double>(
                      begin: 0.0,
                      end: _progressAnimation.value,
                    ),
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                        minHeight: 8,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildProfileStep();
      case 1:
        return _buildLifestyleStep();
      case 2:
        return _buildMealInfoStep();
      case 3:
        return _buildConditionStep();
      case 4:
        return _buildSummaryStep();
      case 5:
        return _buildFoodSearchDemoStep();
      case 6:
        return _buildPredictionDemoStep();
      case 7:
        return _buildFoodExchangeDemoStep();
      case 8:
        return _buildBetaCodeStep();
      case 9:
        return _buildFreeTrialNotificationStep();
      case 10:
        return _buildSubscriptionStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildProfileStep() {
    return SingleChildScrollView(
      key: const ValueKey('profile'),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '당신에 대해 알려주세요',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 48),
            const Text("닉네임"),
            TextFormField(
              initialValue: name,
              onChanged: (val) => name = val,
              validator: (val) => val == null || val.isEmpty ? '닉네임을 입력하세요' : null,
            ),
            const SizedBox(height: 24),
            const Text("나이"),
            TextFormField(
              initialValue: age?.toString(),
              keyboardType: TextInputType.number,
              onChanged: (val) => age = int.tryParse(val),
              validator: (val) => val == null || val.isEmpty ? '나이를 입력하세요' : null,
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
                        color: selected ? const Color(0xFFF4F4F4) : Colors.grey[200],
                        border: Border.all(
                          color: selected ? Colors.black : Colors.transparent,
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
              initialValue: height?.toString(),
              keyboardType: TextInputType.number,
              onChanged: (val) => height = double.tryParse(val),
              validator: (val) => val == null || val.isEmpty ? '키를 입력하세요' : null,
            ),
            const SizedBox(height: 24),
            const Text("체중 (kg)"),
            TextFormField(
              initialValue: weight?.toString(),
              keyboardType: TextInputType.number,
              onChanged: (val) => weight = double.tryParse(val),
              validator: (val) => val == null || val.isEmpty ? '체중을 입력하세요' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleStep() {
    return SingleChildScrollView(
      key: const ValueKey('lifestyle'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Center(
            child: Text(
              '일상생활은 어떻게 보내시나요?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 48),
          const Text("활동 수준을 선택하세요"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: ['low', 'medium', 'high'].map((option) {
              final selected = activityLevel == option;
              final label = option == 'low'
                  ? '주로 앉아서 생활'
                  : option == 'medium'
                      ? '주 1회 이상 운동'
                      : '주 3회 이상 운동';
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => setState(() => activityLevel = option),
                selectedColor: const Color(0xFFF4F4F4),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text("당뇨 유형을 선택하세요"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['T1D', 'T2D', 'none'].map((option) {
              final selected = diabetes == option;
              final label = option == 'T1D'
                  ? '1형 당뇨'
                  : option == 'T2D'
                      ? '2형 당뇨'
                      : '없음';
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => setState(() => diabetes = option),
                selectedColor: const Color(0xFFF4F4F4),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text("목표를 선택하세요"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: ['blood_sugar_control', 'weight_loss', 'balanced'].map((option) {
              final selected = goal == option;
              final label = option == 'blood_sugar_control'
                  ? '혈당 조절'
                  : option == 'weight_loss'
                      ? '체중 관리'
                      : '균형 잡힌 식단';
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => setState(() => goal = option),
                selectedColor: const Color(0xFFF4F4F4),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMealInfoStep() {
    return SingleChildScrollView(
      key: const ValueKey('meal_info'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            '평소 어떻게 식사하시나요?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          const Text('주로 언제 식사하시나요?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((meal) {
              final selected = selectedMeals.contains(meal);
              final emoji = meal == 'Breakfast'
                  ? '🍳'
                  : meal == 'Lunch'
                      ? '🥗'
                      : meal == 'Dinner'
                          ? '🍽️'
                          : '🍪';
              final label = meal == 'Breakfast'
                  ? '아침'
                  : meal == 'Lunch'
                      ? '점심'
                      : meal == 'Dinner'
                          ? '저녁'
                          : '간식';

              return InkWell(
                onTap: () {
                  setState(() {
                    if (selected) {
                      if (selectedMeals.length > 1) {
                        selectedMeals.remove(meal);
                      }
                    } else {
                      selectedMeals.add(meal);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFF4F4F4) : Colors.grey[200],
                    border: Border.all(
                      color: selected ? Colors.black : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text('주로 어떻게 식사하시나요?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['Direct cooking', 'Eating out', 'Delivery based'].map((method) {
              final selected = selectedMealMethod == method;
              final label = method == 'Direct cooking'
                  ? '직접 조리'
                  : method == 'Eating out'
                      ? '외식'
                      : '배달';

              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => setState(() => selectedMealMethod = method),
                selectedColor: const Color(0xFFF4F4F4),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionStep() {
    return SingleChildScrollView(
      key: const ValueKey('condition'),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _conditionFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              '식이 제한 사항이 있으신가요?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const Text('식이 제한'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSelectionChip('Vegetarian', '채식', '🥕', selectedRestrictions),
                _buildSelectionChip('Halal', '할랄', '🐓', selectedRestrictions),
                _buildSelectionChip('Gluten-free', '글루텐 프리', '🌾', selectedRestrictions),
                _buildSelectionChip('None', '없음', '❌', selectedRestrictions),
              ],
            ),
            const SizedBox(height: 32),
            const Text('식품 알레르기'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['None', 'Dairy', 'Nuts', 'Shellfish', 'Meat', 'Seafood', 'Other']
                  .map((allergy) {
                final labels = {
                  'None': '없음',
                  'Dairy': '유제품',
                  'Nuts': '견과류',
                  'Shellfish': '갑각류',
                  'Meat': '육류',
                  'Seafood': '해산물',
                  'Other': '기타',
                };
                return _buildSelectionChip(allergy, labels[allergy]!, null, selectedAllergies);
              }).toList(),
            ),
            const SizedBox(height: 32),
            const Text('최근 평균 혈당을 입력하세요'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _averageGlucoseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '평균 혈당 (mg/dL)',
                hintText: '예: 100',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixText: 'mg/dL',
              ),
              onChanged: (val) => averageGlucose = double.tryParse(val) ?? 100.0,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '평균 혈당 값을 입력하세요';
                }
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return '유효한 숫자를 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CheckboxListTile(
              value: agreedToTerms,
              onChanged: (val) => setState(() => agreedToTerms = val ?? false),
              title: const Text('개인 정보 사용에 동의합니다.'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionChip(String value, String label, String? emoji, List<String> selectedList) {
    final selected = selectedList.contains(value);
    return InkWell(
      onTap: () {
        setState(() {
          if (value == 'None') {
            selectedList.clear();
            selectedList.add('None');
          } else {
            selectedList.remove('None');
            if (selected) {
              selectedList.remove(value);
              if (selectedList.isEmpty) {
                selectedList.add('None');
              }
            } else {
              selectedList.add(value);
            }
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF4F4F4) : Colors.grey[200],
          border: Border.all(
            color: selected ? Colors.black : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
            ],
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          Icon(Icons.check_circle, size: 100, color: Colors.green.shade400),
          const SizedBox(height: 24),
          const Text(
            '설정이 완료되었습니다!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'GlucoUS가 당신의 건강한 식생활을 도와드릴 준비가 되었습니다',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('이름', name),
                _buildSummaryRow('나이', '$age세'),
                _buildSummaryRow('성별', gender == 'male' ? '남성' : '여성'),
                _buildSummaryRow('키/체중', '${height}cm / ${weight}kg'),
                _buildSummaryRow('활동 수준', _translateActivityLevel(activityLevel)),
                _buildSummaryRow('당뇨', _translateDiabetes(diabetes)),
                _buildSummaryRow('목표', _translateGoal(goal)),
                _buildSummaryRow('평균 혈당', '${averageGlucose.toStringAsFixed(0)} mg/dL'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  String _translateActivityLevel(String level) {
    switch (level) {
      case 'low':
        return '주로 앉아서 생활';
      case 'medium':
        return '주 1회 이상 운동';
      case 'high':
        return '주 3회 이상 운동';
      default:
        return level;
    }
  }

  String _translateDiabetes(String type) {
    switch (type) {
      case 'T1D':
        return '1형 당뇨';
      case 'T2D':
        return '2형 당뇨';
      case 'none':
        return '없음';
      default:
        return type;
    }
  }

  String _translateGoal(String goalType) {
    switch (goalType) {
      case 'blood_sugar_control':
        return '혈당 조절';
      case 'weight_loss':
        return '체중 관리';
      case 'balanced':
        return '균형 잡힌 식단';
      default:
        return goalType;
    }
  }

  Widget _buildBottomButton() {
    // Disable button on step 3 if terms not agreed
    final bool isDisabled = _currentStep == 3 && !agreedToTerms;

    // Button text changes based on step
    String buttonText = '다음';
    if (_currentStep == 4) buttonText = '시작하기';
    if (_currentStep == 5 || _currentStep == 6 || _currentStep == 7) buttonText = '계속';
    if (_currentStep == 8) buttonText = '건너뛰기';
    if (_currentStep == 9) buttonText = '무료 체험 계속하기';
    if (_currentStep == 10) buttonText = '지금 시작하기';

    return Padding(
      padding: const EdgeInsets.all(24.0),
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
          onPressed: isDisabled ? null : _nextStep,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDisabled
                    ? [Colors.grey.shade300, Colors.grey.shade400]
                    : const [Color(0xFF00FFD1), Color(0xFF0076FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDisabled ? Colors.grey.shade600 : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // DEMO SCREEN BUILDERS

  Widget _buildFoodSearchDemoStep() {
    return SingleChildScrollView(
      key: const ValueKey('food_search_demo'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Center(
            child: Text(
              "GlucoUS의 AI\n식단 검색을 체험해보세요",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    '음식 정보를 찾고 계신가요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                IgnorePointer(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: '관심 있는 음식을 검색해보세요...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDemoFoodCard('그릴드 치킨 샐러드', '#혈당안정', Colors.white, Icons.food_bank),
                const SizedBox(height: 12),
                _buildDemoFoodCard('브로콜리 찜 & 퀴노아', '#건강한식사', Colors.green, Icons.eco),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoFoodCard(String title, String tag, Color iconBg, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: iconBg == Colors.white ? Colors.grey.shade300 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: iconBg == Colors.white ? null : Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconBg,
            child: Icon(icon, color: iconBg == Colors.white ? Colors.black : Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(tag, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionDemoStep() {
    return SingleChildScrollView(
      key: const ValueKey('prediction_demo'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            '귀하의 식단이\n얼마나 잘 맞는지 확인해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: 0.81,
                  strokeWidth: 20,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FFD1)),
                ),
              ),
              const Column(
                children: [
                  Text('81', style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
                  Text('매칭 점수', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text(
                  '이 식사는 당신의 건강 목표와\n잘 맞습니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodExchangeDemoStep() {
    return SingleChildScrollView(
      key: const ValueKey('food_exchange_demo'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            '더 나은 대체 식품을 찾아보세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _buildExchangeCard('🍚 흰 쌀밥', '🌾 현미밥', '혈당 영향 -30%'),
          const SizedBox(height: 16),
          _buildExchangeCard('🍞 흰 빵', '🥖 통곡물 빵', '섬유질 +150%'),
          const SizedBox(height: 16),
          _buildExchangeCard('🥤 탄산음료', '💧 무가당 음료', '당분 -100%'),
        ],
      ),
    );
  }

  Widget _buildExchangeCard(String from, String to, String benefit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(from, style: const TextStyle(fontSize: 18)),
          ),
          const Icon(Icons.arrow_forward, color: Colors.green),
          Expanded(
            child: Text(to, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(benefit, style: const TextStyle(fontSize: 12, color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget _buildBetaCodeStep() {
    return SingleChildScrollView(
      key: const ValueKey('beta_code'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          const Text(
            '베타 프로그램에 오신 것을 환영합니다!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              '베타 테스터로 무료 체험 코드를 받으셨다면\n아래에 코드를 입력하고\n계속 진행해 주세요.',
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('코드 입력', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _betaCodeController,
                decoration: InputDecoration(
                  hintText: '여기에 베타 코드를 입력하세요',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFreeTrialNotificationStep() {
    return SingleChildScrollView(
      key: const ValueKey('free_trial'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '무료 체험 종료 전에\n알려드릴게요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          _buildTimelineStep('오늘', '모든 기능을 비용 없이 자유롭게 이용하세요.', Colors.grey.shade400),
          const SizedBox(height: 20),
          _buildTimelineStep('3주차 — 알림', '무료 체험이 곧 종료될 때 알림을 보내드려요.', Colors.grey.shade600),
          const SizedBox(height: 20),
          _buildTimelineStep('4주차 — 결제 시작', '그때까지 무료 체험이 제공됩니다! 결제가 시작되기 전에 언제든 취소하시면 요금이 청구되지 않습니다.', Colors.black),
          const SizedBox(height: 32),
          const Text(
            '걱정하지 마세요—첫 결제 전에 미리 알려드릴게요.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String description, Color circleColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionStep() {
    return SingleChildScrollView(
      key: const ValueKey('subscription'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_videoController != null && _videoController!.value.isInitialized)
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
          else
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          const SizedBox(height: 24),
          const Text(
            '4주 무료 체험 시작하기',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildPlanCard(
                title: '베이직',
                price: '\$5.99 / 월',
                selected: selectedPlan == 'basic',
                onTap: () => setState(() => selectedPlan = 'basic'),
              ),
              const SizedBox(width: 12),
              _buildPlanCard(
                title: '프로',
                price: '\$12.00 / 월',
                selected: selectedPlan == 'pro',
                onTap: () => setState(() => selectedPlan = 'pro'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '첫 결제 전에 알림을 받으실 수 있습니다.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: selected ? Colors.black : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
