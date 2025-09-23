/*
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// (선택) 프로필 초기값 전달용
class UserProfileDetailsArgs {
  final String? name;
  final int? age;
  final double? heightCm;
  final String? gender;
  const UserProfileDetailsArgs({
    this.name,
    this.age,
    this.heightCm,
    this.gender,
  });
}

/// 스크린: 스샷 느낌(담백한 화이트, 라벨은 옅은 회색, 값은 크게, 우측 연필 아이콘)
class UserProfileDetailsScreen extends StatelessWidget {
  static const routeName = '/user_profile_details';
  const UserProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    // 네임드 라우트 arguments 수신 (없으면 기본값)
    final args =
        ModalRoute.of(context)?.settings.arguments as UserProfileDetailsArgs?;
    final name = args?.name ?? 'Jaehyun';
    final age = args?.age ?? 25;
    final height = args?.heightCm ?? 176.1;
    final gender = args?.gender ?? 'Male';

    String heightStr(double h) => (h.roundToDouble() == h)
        ? '${h.toInt()}cm'
        : '${h.toStringAsFixed(1)}cm';

    Widget fieldTile(String label, String value, {VoidCallback? onEdit}) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.outlineVariant.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: t.labelMedium?.copyWith(color: c.outline),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: t.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit $label',
              ),
            ],
          ),
        ),
      );
    }

    ListTile actionTile({
      required String title,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title, style: t.bodyLarge),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );
    }

    Future<void> openMail() async {
      final uri = Uri(
        scheme: 'mailto',
        path: 'support@glucous.kr',
        query: 'subject=GlucoUS%20Support&body=Hello,',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('메일 앱을 열 수 없습니다.')));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Personal Details')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          fieldTile('Name', name),
          fieldTile('Age', '$age'),
          fieldTile('Height', heightStr(height)),
          fieldTile('Gender', gender),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'More',
              style: t.titleMedium?.copyWith(color: c.primary),
            ),
          ),
          const SizedBox(height: 6),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                actionTile(
                  title: 'Terms and Conditions',
                  icon: Icons.article_outlined,
                  onTap: () => Navigator.of(context).pushNamed('/terms'),
                ),
                const Divider(height: 1),
                actionTile(
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => Navigator.of(context).pushNamed('/privacy'),
                ),
                const Divider(height: 1),
                actionTile(
                  title: 'Support Email',
                  icon: Icons.email_outlined,
                  onTap: openMail,
                ),
                const Divider(height: 1),
                actionTile(
                  title: 'Account',
                  icon: Icons.person_outline,
                  onTap: () => Navigator.of(context).pushNamed('/account'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 프로필 값 전달용(없어도 기본값으로 동작)
class UserProfileDetailArgs {
  final String? name;
  final int? age;
  final double? heightCm;
  final String? gender;
  const UserProfileDetailArgs({
    this.name,
    this.age,
    this.heightCm,
    this.gender,
  });
}

/// 검색결과 상세와 같은 '틀' 안에 끼워 넣는 **내용 전용 위젯** (Scaffold 없음)
class UserProfileDetail extends StatelessWidget {
  final String name;
  final int age;
  final double heightCm;
  final String gender;

  const UserProfileDetail({
    super.key,
    this.name = 'Jaehyun',
    this.age = 25,
    this.heightCm = 176.1,
    this.gender = 'Male',
  });

  String _heightStr(double h) =>
      (h.roundToDouble() == h) ? '${h.toInt()}cm' : '${h.toStringAsFixed(1)}cm';

  Future<void> _openMail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@glucous.kr',
      query: 'subject=GlucoUS%20Support&body=Hello,',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('메일 앱을 열 수 없습니다.')));
      }
    }
  }

  Widget _fieldTile(
    BuildContext context,
    String label,
    String value, {
    VoidCallback? onEdit,
  }) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.outlineVariant.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: t.labelMedium?.copyWith(color: c.outline)),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: t.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit $label',
            ),
          ],
        ),
      ),
    );
  }

  ListTile _actionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final t = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: t.bodyLarge),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return ListView(
      children: [
        // 상단 타이틀 (AppBar 없이 내부에서 표기)
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Personal Details',
            textAlign: TextAlign.left,
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),

        _fieldTile(context, 'Name', name),
        _fieldTile(context, 'Age', '$age'),
        _fieldTile(context, 'Height', _heightStr(heightCm)),
        _fieldTile(context, 'Gender', gender),

        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('More', style: t.titleMedium?.copyWith(color: c.primary)),
        ),
        const SizedBox(height: 6),

        // 액션 카드
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _actionTile(
                context,
                title: 'Terms and Conditions',
                icon: Icons.article_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const _SimpleDocPage(title: 'Terms and Conditions'),
                  ),
                ),
              ),
              const Divider(height: 1),
              _actionTile(
                context,
                title: 'Privacy Policy',
                icon: Icons.privacy_tip_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const _SimpleDocPage(title: 'Privacy Policy'),
                  ),
                ),
              ),
              const Divider(height: 1),
              _actionTile(
                context,
                title: 'Support Email',
                icon: Icons.email_outlined,
                onTap: () => _openMail(context),
              ),
              const Divider(height: 1),
              _actionTile(
                context,
                title: 'Account',
                icon: Icons.person_outline,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _SimpleDocPage(title: 'Account'),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// 간단 문서용 페이지(임시)
class _SimpleDocPage extends StatelessWidget {
  final String title;
  const _SimpleDocPage({required this.title});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            '$title page\n(Replace with your real content)',
            textAlign: TextAlign.center,
            style: t.titleMedium,
          ),
        ),
      ),
    );
  }
}
