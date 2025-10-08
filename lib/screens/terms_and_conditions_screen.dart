import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이용 약관'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이용 약관',
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
              '1. 약관의 동의',
              'GlucoUS("앱")에 접속하고 사용함으로써, 귀하는 본 계약의 조건과 규정에 구속되는 것에 동의합니다. 본 약관에 동의하지 않는 경우, 앱을 사용하지 마십시오.',
            ),
            _buildSection(
              context,
              '2. 서비스 이용',
              'GlucoUS는 혈당 예측 및 식단 관리 서비스를 제공합니다. 본 앱은 정보 제공 및 교육 목적으로만 사용되며 전문 의료 조언을 대체할 수 없습니다. 귀하는 모든 관련 법률 및 규정에 따라 앱을 사용하는 데 동의합니다.',
            ),
            _buildSection(
              context,
              '3. 사용자 계정',
              '귀하는 계정과 비밀번호의 기밀을 유지할 책임이 있습니다. 귀하는 귀하의 계정에서 발생하는 모든 활동에 대한 책임을 수락하는 데 동의합니다.',
            ),
            _buildSection(
              context,
              '4. 건강 정보',
              '본 앱은 귀하가 제공하는 정보를 기반으로 혈당 예측 및 식단 권장 사항을 제공합니다. 이 정보는 전문 의료 조언, 진단 또는 치료를 대체하지 않습니다. 의학적 상태에 관한 질문이 있는 경우 항상 의사 또는 기타 자격을 갖춘 의료 제공자의 조언을 구하십시오.',
            ),
            _buildSection(
              context,
              '5. 데이터 수집 및 사용',
              '우리는 서비스를 제공하기 위해 귀하의 개인 건강 정보를 수집하고 처리합니다. 앱을 사용함으로써 귀하는 개인정보 처리방침에 설명된 대로 귀하의 정보를 수집, 사용 및 공유하는 것에 동의합니다.',
            ),
            _buildSection(
              context,
              '6. 구독 및 결제',
              'GlucoUS는 구독 기반 서비스를 제공합니다. 귀하는 구독과 관련된 모든 요금을 지불하는 데 동의합니다. 구독은 갱신일 이전에 취소하지 않는 한 자동으로 갱신됩니다.',
            ),
            _buildSection(
              context,
              '7. 지적 재산권',
              '앱의 모든 콘텐츠, 기능 및 기능은 GlucoUS가 소유하며 국제 저작권, 상표, 특허, 영업 비밀 및 기타 지적 재산권 법률에 의해 보호됩니다.',
            ),
            _buildSection(
              context,
              '8. 책임의 제한',
              'GlucoUS는 귀하의 앱 사용 또는 사용 불가로 인해 발생하는 간접적, 우발적, 특별, 결과적 또는 징벌적 손해에 대해 책임을 지지 않습니다.',
            ),
            _buildSection(
              context,
              '9. 약관 변경',
              '우리는 언제든지 이 약관을 수정할 권리를 보유합니다. 중요한 변경 사항이 있을 경우 사용자에게 알려드립니다. 변경 사항이 게시된 후 앱을 계속 사용하면 해당 변경 사항을 수락하는 것으로 간주됩니다.',
            ),
            _buildSection(
              context,
              '10. 연락처 정보',
              '본 이용 약관에 대한 질문이 있으시면 support@glucous.kr로 문의해 주십시오.',
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
