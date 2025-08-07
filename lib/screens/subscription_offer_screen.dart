// import 'package:flutter/material.dart';
// 
// class SubscriptionOfferScreen extends StatefulWidget {
//   final String name;
//   final int age;
//   final String gender;
//   final double height;
//   final double weight;
//   final String activityLevel;
//   final String goal;
//   final String diabetes;
//   final List<String> meals;
//   final String mealMethod;
//   final List<String> dietaryRestrictions;
//   final List<String> allergies;
//   final double? averageGlucose;
// 
//   const SubscriptionOfferScreen({
//     super.key,
//     required this.name,
//     required this.age,
//     required this.gender,
//     required this.height,
//     required this.weight,
//     required this.activityLevel,
//     required this.goal,
//     required this.diabetes,
//     required this.meals,
//     required this.mealMethod,
//     required this.dietaryRestrictions,
//     required this.allergies,
//     required this.averageGlucose,
//   });
// 
//   @override
//   State<SubscriptionOfferScreen> createState() => _SubscriptionOfferScreen();
// }
// 
// class _SubscriptionOfferScreen extends State<SubscriptionOfferScreen> {
// 
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // 데모 영상 placeholder
//             Container(
//               height: 280,
//               width: double.infinity,
//               color: Colors.black,
//               alignment: Alignment.center,
//               child: const Text(
//                 '데모 영상',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
// 
//             const SizedBox(height: 24),
// 
//             const Text(
//               '4주 무료체험으로\n시작해보세요',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
// 
//             const SizedBox(height: 24),
// 
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Column(
//                         children: [
//                           Text(
//                             '월간 구독',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(height: 4),
//                           Text('4,999 원 / 월'),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           const Text(
//                             '연간 구독',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 4),
//                           const Text('3,999 원 / 월'),
//                           const SizedBox(height: 8),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 4,
//                               horizontal: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Text(
//                               '10% 절약',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
// 
//             const Spacer(),
// 
//             const Text(
//               '결제 전 알림을 보내드릴게요!',
//               style: TextStyle(color: Colors.grey),
//             ),
// 
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                     padding: EdgeInsets.zero,
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                   ),
//                   child: Ink(
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Color(0xFF00FFD1), Color(0xFF0076FF)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.all(Radius.circular(24)),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         '지금 시작하기',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';

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
  String selectedPlan = 'monthly'; // 'monthly' or 'yearly'

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 실제 영상 링크
    )..initialize().then((_) {
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
 
  void startSubscription() {
    // 실제 결제 로직 연동 (Google Play / App Store)
    // final productId = selectedPlan == 'monthly'
    //     ? 'monthly_plan_with_trial'
    //     : 'yearly_plan_with_trial';

    // // InAppPurchase.instance.buyNonConsumable(...) 또는 구매 로직 연결
    // debugPrint("결제 시작: $productId");
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
                : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),

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
                    title: '월간 구독',
                    price: '4,999 원 / 월',
                    selected: selectedPlan == 'monthly',
                    onTap: () => setState(() => selectedPlan = 'monthly'),
                  ),
                  const SizedBox(width: 12),
                  _buildPlanCard(
                    title: '연간 구독',
                    price: '3,999 원 / 월',
                    badgeText: '10% 절약',
                    selected: selectedPlan == 'yearly',
                    onTap: () => setState(() => selectedPlan = 'yearly'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('결제 전 알림을 보내드릴게요!',
                style: TextStyle(fontSize: 13, color: Colors.grey)),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: startSubscription,
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
            )
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
              Text(price,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              if (badgeText != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
              ]
            ],
          ),
        ),
      ),
    );
  }
}
