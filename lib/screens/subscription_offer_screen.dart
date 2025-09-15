/*
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:glucous_meal_app/models/models.dart';
import 'package:glucous_meal_app/services/api_service.dart';
import 'glucous_loading_screen.dart';
import 'main.dart';

class SubscriptionOfferScreen extends StatefulWidget {
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String activityLevel;
  final String goal;
  final String diabetes;
  final List<String> meals;
  final String mealMethod;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final double? averageGlucose;

  const SubscriptionOfferScreen({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
    required this.diabetes,
    required this.meals,
    required this.mealMethod,
    required this.dietaryRestrictions,
    required this.allergies,
    required this.averageGlucose,
  });

  @override
  State<SubscriptionOfferScreen> createState() => _SubscriptionOfferScreen();
}

class _SubscriptionOfferScreen extends State<SubscriptionOfferScreen> {
  late VideoPlayerController _controller;
  String selectedPlan = 'basic'; // 'basic' or 'pro'

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.network(
            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 실제 영상 링크
          )
          ..initialize().then((_) {
            setState(() {});
            _controller.play();
            _controller.setLooping(true);
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void submit() {
    // 1. 로딩 오버레이 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GlucousLoadingOverlay(),
    );

    final double bmi = widget.weight / pow(widget.height / 100, 2);

    final userProfile = UserProfile(
      name: widget.name,
      age: widget.age,
      gender: widget.gender,
      weight: widget.weight,
      height: widget.height,
      bmi: bmi,
      activityLevel: widget.activityLevel,
      goal: widget.goal,
      diabetes: widget.diabetes,
      meals: widget.meals,
      mealMethod: widget.mealMethod,
      dietaryRestrictions: widget.dietaryRestrictions,
      allergies: widget.allergies,
      averageGlucose: widget.averageGlucose ?? 0.0,
    );

    ApiService.registerUser(userProfile);
    startSubscription();
    loadRecommendation(userProfile);
  }

  void startSubscription() {
    // 실제 결제 로직 연동 (Google Play / App Store)
    // final productId = selectedPlan == 'monthly'
    //     ? 'monthly_plan_with_trial'
    //     : 'yearly_plan_with_trial';

    // // InAppPurchase.instance.buyNonConsumable(...) 또는 구매 로직 연결
    // debugPrint("결제 시작: $productId");
  }

  void loadRecommendation(UserProfile userProfile) async {
    final double bmi = widget.weight / pow(widget.height / 100, 2);

    try {
      // 2. API 호출
      final recommendations = await ApiService.fetchRecommendations(
        userProfile,
      );

      // 3. 로딩 제거
      Navigator.of(context).pop();

      // 4. 결과 페이지로 이동
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              Main(username: '홍길동', recommendations: recommendations),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // 로딩 제거
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('추천 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),

            const SizedBox(height: 24),
            const Text(
              '4주 무료체험으로\n시작해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _buildPlanCard(
                    title: '베이직',
                    price: '5,999 원 / 월',
                    selected: selectedPlan == '',
                    onTap: () => setState(() => selectedPlan = 'monthly'),
                  ),
                  const SizedBox(width: 12),
                  _buildPlanCard(
                    title: '프로',
                    price: '12,000 원 / 월',
                    // badgeText: '10% 절약',
                    selected: selectedPlan == 'pro',
                    onTap: () => setState(() => selectedPlan = 'pro'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              '결제 전 알림을 보내드릴게요!',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00FFD1), Color(0xFF0076FF)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    child: const Center(
                      child: Text(
                        '지금 시작하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    String? badgeText,
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
              if (badgeText != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFC2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
*/

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:glucous_meal_app/models/models.dart';
import 'package:glucous_meal_app/services/api_service.dart';
import 'glucous_loading_screen.dart';
import 'main.dart';

class SubscriptionOfferScreen extends StatefulWidget {
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String activityLevel;
  final String goal;
  final String diabetes;
  final List<String> meals;
  final String mealMethod;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final double? averageGlucose;

  const SubscriptionOfferScreen({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
    required this.diabetes,
    required this.meals,
    required this.mealMethod,
    required this.dietaryRestrictions,
    required this.allergies,
    required this.averageGlucose,
  });

  @override
  State<SubscriptionOfferScreen> createState() => _SubscriptionOfferScreen();
}

class _SubscriptionOfferScreen extends State<SubscriptionOfferScreen> {
  late VideoPlayerController _controller;
  String selectedPlan = 'basic'; // 'basic' or 'pro'

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.network(
            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // placeholder video link
          )
          ..initialize().then((_) {
            setState(() {});
            _controller.play();
            _controller.setLooping(true);
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void submit() {
    // 1. Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GlucousLoadingOverlay(),
    );

    final double bmi = widget.weight / pow(widget.height / 100, 2);

    final userProfile = UserProfile(
      name: widget.name,
      age: widget.age,
      gender: widget.gender,
      weight: widget.weight,
      height: widget.height,
      bmi: bmi,
      activityLevel: widget.activityLevel,
      goal: widget.goal,
      diabetes: widget.diabetes,
      meals: widget.meals,
      mealMethod: widget.mealMethod,
      dietaryRestrictions: widget.dietaryRestrictions,
      allergies: widget.allergies,
      averageGlucose: widget.averageGlucose ?? 0.0,
    );

    ApiService.registerUser(userProfile);
    startSubscription();
    loadRecommendation(userProfile);
  }

  void startSubscription() {
    // Real payment logic (Google Play / App Store)
    // final productId = selectedPlan == 'monthly'
    //     ? 'monthly_plan_with_trial'
    //     : 'yearly_plan_with_trial';

    // InAppPurchase.instance.buyNonConsumable(...) or purchase logic
    // debugPrint("Purchase started: $productId");
  }

  void loadRecommendation(UserProfile userProfile) async {
    final double bmi = widget.weight / pow(widget.height / 100, 2);

    try {
      // 2. API call
      final recommendations = await ApiService.fetchRecommendations(
        userProfile,
      );

      // 3. Remove loading
      Navigator.of(context).pop();

      // 4. Navigate to results page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              Main(username: 'John Doe', recommendations: recommendations),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // remove loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Recommendation failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),

            const SizedBox(height: 24),
            const Text(
              'Start your 4-week free trial',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _buildPlanCard(
                    title: 'Basic',
                    price: '\$5.99 / month',
                    selected: selectedPlan == 'monthly',
                    onTap: () => setState(() => selectedPlan = 'monthly'),
                  ),
                  const SizedBox(width: 12),
                  _buildPlanCard(
                    title: 'Pro',
                    price: '\$12.00 / month',
                    // badgeText: 'Save 10%',
                    selected: selectedPlan == 'pro',
                    onTap: () => setState(() => selectedPlan = 'pro'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'You’ll get a reminder before your first charge.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00FFD1), Color(0xFF0076FF)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    child: const Center(
                      child: Text(
                        'Get Started Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    String? badgeText,
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
              if (badgeText != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFC2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
