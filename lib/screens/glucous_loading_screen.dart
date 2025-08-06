import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class GlucousLoadingOverlay extends StatelessWidget {
  const GlucousLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: Container(
        color: const Color(0xFF121212), // 다크 톤 배경
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/glucous_logo.png',
                    width: 120, // 화면 비율 고려한 크기
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'GlucoUS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: SpinKitCircle(
                color: Color(0xFF00FFD1),
                size: 36.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
