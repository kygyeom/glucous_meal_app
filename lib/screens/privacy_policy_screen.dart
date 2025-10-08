import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 처리방침'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '개인정보 처리방침',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '최종 업데이트: ${DateTime.now().year}년',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. 수집하는 정보',
              '우리는 귀하가 직접 제공하는 다음과 같은 정보를 수집합니다:\n\n'
              '• 개인 정보 (이름, 나이, 성별)\n'
              '• 건강 정보 (체중, 키, BMI, 혈당 수치, 당뇨 상태)\n'
              '• 식이 선호도 및 제한 사항\n'
              '• 활동 수준 및 건강 목표\n'
              '• 기기 식별자 및 사용 데이터',
            ),
            _buildSection(
              context,
              '2. 정보 사용 방법',
              '우리는 수집한 정보를 다음과 같이 사용합니다:\n\n'
              '• 맞춤형 혈당 예측 및 식단 권장 사항 제공\n'
              '• 서비스 개선 및 최적화\n'
              '• 계정 및 서비스에 대한 커뮤니케이션\n'
              '• 사용 패턴 및 트렌드 분석\n'
              '• 서비스의 보안 및 무결성 보장',
            ),
            _buildSection(
              context,
              '3. 데이터 저장 및 보안',
              '우리는 무단 접근, 변경, 공개 또는 파괴로부터 귀하의 개인 정보를 보호하기 위해 적절한 기술적 및 조직적 조치를 구현합니다. 귀하의 건강 데이터는 암호화되어 데이터베이스에 안전하게 저장됩니다.',
            ),
            _buildSection(
              context,
              '4. 정보 공유',
              '우리는 귀하의 개인 정보를 판매하지 않습니다. 다음과 같은 경우에만 귀하의 정보를 공유할 수 있습니다:\n\n'
              '• 귀하의 명시적 동의가 있는 경우\n'
              '• 법적 의무를 준수하기 위해\n'
              '• 우리의 권리를 보호하고 사기를 방지하기 위해\n'
              '• 앱 운영을 지원하는 서비스 제공업체와',
            ),
            _buildSection(
              context,
              '5. 귀하의 권리 및 선택',
              '귀하는 다음과 같은 권리가 있습니다:\n\n'
              '• 개인 정보 액세스\n'
              '• 정보 업데이트 또는 수정\n'
              '• 계정 및 관련 데이터 삭제\n'
              '• 마케팅 커뮤니케이션 거부\n'
              '• 데이터 사본 요청',
            ),
            _buildSection(
              context,
              '6. 데이터 보유',
              '우리는 귀하의 계정이 활성 상태이거나 서비스를 제공하는 데 필요한 기간 동안 귀하의 개인 정보를 보유합니다. 계정 설정 페이지를 통해 언제든지 계정 삭제를 요청할 수 있습니다.',
            ),
            _buildSection(
              context,
              '7. 아동의 개인정보 보호',
              'GlucoUS는 13세 미만 아동의 사용을 목적으로 하지 않습니다. 우리는 13세 미만 아동으로부터 개인 정보를 고의로 수집하지 않습니다. 13세 미만 아동으로부터 정보를 수집했다고 생각되는 경우 즉시 연락해 주십시오.',
            ),
            _buildSection(
              context,
              '8. 개인정보 처리방침 변경',
              '우리는 수시로 본 개인정보 처리방침을 업데이트할 수 있습니다. 본 페이지에 새로운 개인정보 처리방침을 게시하고 "최종 업데이트" 날짜를 갱신하여 중요한 변경 사항을 알려드립니다.',
            ),
            _buildSection(
              context,
              '9. 국제 데이터 전송',
              '귀하의 정보는 귀하의 국가 이외의 국가로 전송되어 처리될 수 있습니다. 우리는 본 개인정보 처리방침에 따라 귀하의 정보를 보호하기 위한 적절한 보호 조치가 마련되어 있는지 확인합니다.',
            ),
            _buildSection(
              context,
              '10. 문의하기',
              '본 개인정보 처리방침 또는 데이터 관행에 대한 질문이 있으시면 다음으로 연락해 주십시오:\n\n'
              '이메일: support@glucous.kr\n'
              '30일 이내에 답변해 드리겠습니다.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
