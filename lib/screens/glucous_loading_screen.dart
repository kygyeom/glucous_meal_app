import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class GlucousLoadingOverlay extends StatelessWidget {
  const GlucousLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 라우트 자체 배경을 흰색으로
      body: AbsorbPointer(
        absorbing: true,
        child: SizedBox.expand(
          // 화면 전체를 확실히 덮기
          child: Stack(
            children: [
              // 중앙 로고 + 텍스트
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/glucous_logo.png',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'GlucoUS',
                      style: TextStyle(
                        color: Colors.black, // 흰 배경에 보이도록 검정
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // 하단 스피너
              const Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: SpinKitCircle(color: Color(0xFF00FFD1), size: 36.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
