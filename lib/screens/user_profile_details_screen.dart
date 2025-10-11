import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:glucous_meal_app/models/models.dart';
import 'package:glucous_meal_app/services/api_service.dart';
import 'terms_and_conditions_screen.dart';
import 'privacy_policy_screen.dart';
import 'account_settings_screen.dart';
import 'edit_profile_dialogs.dart';

// Static mapping constants moved outside class for better performance
const _genderDisplayToDB = {
  '남성': 'male',
  '여성': 'female',
};
const _genderDbToDisplay = {
  'male': '남성',
  'female': '여성',
};

const _activityDisplayToDB = {
  '낮음': 'low',
  '보통': 'medium',
  '높음': 'high',
};
const _activityDbToDisplay = {
  'low': '낮음',
  'medium': '보통',
  'high': '높음',
};

const _goalDisplayToDB = {
  '혈당 조절': 'blood_sugar_control',
  '체중 감량': 'weight_loss',
  '균형 잡힌 식단': 'balanced',
};
const _goalDbToDisplay = {
  'blood_sugar_control': '혈당 조절',
  'weight_loss': '체중 감량',
  'balanced': '균형 잡힌 식단',
};

const _diabetesDisplayToDB = {
  '당뇨 없음': 'none',
  '1형 당뇨': 'T1D',
  '2형 당뇨': 'T2D',
};
const _diabetesDbToDisplay = {
  'none': '당뇨 없음',
  'T1D': '1형 당뇨',
  'T2D': '2형 당뇨',
};

/// 검색결과 상세와 같은 '틀' 안에 끼워 넣는 **내용 전용 위젯** (Scaffold 없음)
class UserProfileDetail extends StatefulWidget {
  final UserProfile? userProfile;
  final VoidCallback? onProfileUpdated;

  const UserProfileDetail({
    super.key,
    this.userProfile,
    this.onProfileUpdated,
  });

  @override
  State<UserProfileDetail> createState() => _UserProfileDetailState();
}

class _UserProfileDetailState extends State<UserProfileDetail> {
  late UserProfile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.userProfile;
  }

  @override
  void didUpdateWidget(UserProfileDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userProfile != oldWidget.userProfile) {
      setState(() {
        _currentProfile = widget.userProfile;
      });
    }
  }

  String _heightStr(double h) =>
      (h.roundToDouble() == h) ? '${h.toInt()}cm' : '${h.toStringAsFixed(1)}cm';

  String _weightStr(double w) =>
      (w.roundToDouble() == w) ? '${w.toInt()}kg' : '${w.toStringAsFixed(1)}kg';

  String _bmiStr(double bmi) => bmi.toStringAsFixed(1);

  // Convert database values to user-friendly text
  String _formatGender(String? gender) {
    if (gender == null || gender.isEmpty) return '설정 안됨';
    switch (gender.toLowerCase()) {
      case 'male':
        return '남성';
      case 'female':
        return '여성';
      default:
        return gender;
    }
  }

  String _formatActivityLevel(String? level) {
    if (level == null || level.isEmpty) return '설정 안됨';
    switch (level.toLowerCase()) {
      case 'low':
        return '낮음';
      case 'medium':
        return '보통';
      case 'high':
        return '높음';
      default:
        return level;
    }
  }

  String _formatGoal(String? goal) {
    if (goal == null || goal.isEmpty) return '설정 안됨';
    switch (goal.toLowerCase()) {
      case 'blood_sugar_control':
        return '혈당 조절';
      case 'weight_loss':
        return '체중 감량';
      case 'balanced':
        return '균형 잡힌 식단';
      default:
        return goal;
    }
  }

  String _formatDiabetes(String? diabetes) {
    if (diabetes == null || diabetes.isEmpty) return '설정 안됨';
    switch (diabetes.toUpperCase()) {
      case 'NONE':
        return '당뇨 없음';
      case 'T1D':
        return '1형 당뇨';
      case 'T2D':
        return '2형 당뇨';
      default:
        return diabetes;
    }
  }

  String _formatMealMethod(String? method) {
    if (method == null || method.isEmpty) return '설정 안됨';
    switch (method.toLowerCase()) {
      case 'direct cooking':
      case 'home_cooked':
        return '직접 조리';
      case 'delivery':
      case 'delivery based':
        return '배달';
      case 'eating_out':
      case 'eating out':
        return '외식';
      case 'meal_kit':
        return '밀키트';
      default:
        return method;
    }
  }

  String _formatMeals(List<String>? meals) {
    if (meals == null || meals.isEmpty) return '설정 안됨';
    return meals.map((meal) {
      switch (meal.toLowerCase()) {
        case 'breakfast':
          return '아침';
        case 'lunch':
          return '점심';
        case 'dinner':
          return '저녁';
        case 'snack':
          return '간식';
        default:
          return meal;
      }
    }).join(', ');
  }

  String _formatDietaryRestrictions(List<String>? restrictions) {
    if (restrictions == null || restrictions.isEmpty) return '없음';
    if (restrictions.length == 1 && restrictions[0].toLowerCase() == 'none') return '없음';
    return restrictions.where((r) => r.toLowerCase() != 'none').map((restriction) {
      switch (restriction.toLowerCase()) {
        case 'vegetarian':
          return '채식';
        case 'vegan':
          return '비건';
        case 'halal':
          return '할랄';
        case 'low_sodium':
          return '저염식';
        case 'low_carb':
          return '저탄수화물';
        case 'gluten-free':
        case 'gluten_free':
          return '글루텐 프리';
        default:
          return restriction;
      }
    }).join(', ');
  }

  String _formatAllergies(List<String>? allergies) {
    if (allergies == null || allergies.isEmpty) return '없음';
    if (allergies.length == 1 && allergies[0].toLowerCase() == 'none') return '없음';
    return allergies.where((a) => a.toLowerCase() != 'none').map((allergy) {
      switch (allergy.toLowerCase()) {
        case 'dairy':
        case 'milk':
          return '유제품';
        case 'eggs':
          return '계란';
        case 'peanuts':
          return '땅콩';
        case 'nuts':
        case 'tree_nuts':
          return '견과류';
        case 'soy':
          return '콩';
        case 'wheat':
          return '밀';
        case 'fish':
        case 'seafood':
          return '해산물';
        case 'shellfish':
          return '갑각류';
        case 'meat':
          return '육류';
        case 'other':
          return '기타';
        default:
          return allergy;
      }
    }).join(', ');
  }

  Future<void> _updateProfile(Map<String, dynamic> updates) async {
    try {
      final success = await ApiService.updateUserProfile(updates);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 성공적으로 업데이트되었습니다')),
        );
        widget.onProfileUpdated?.call();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 업데이트에 실패했습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  Future<void> _editName() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => EditTextDialog(
        title: '이름',
        initialValue: _currentProfile?.name ?? '',
      ),
    );
    if (result != null) {
      await _updateProfile({'name': result});
    }
  }

  Future<void> _editAge() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => EditTextDialog(
        title: '나이',
        initialValue: _currentProfile?.age.toString() ?? '',
        keyboardType: TextInputType.number,
      ),
    );
    if (result != null) {
      final age = int.tryParse(result);
      if (age != null) {
        await _updateProfile({'age': age});
      }
    }
  }

  Future<void> _editGender() async {
    final currentDisplay = _genderDbToDisplay[_currentProfile?.gender] ?? '남성';

    final result = await showDialog<String>(
      context: context,
      builder: (context) => EditSelectionDialog(
        title: '성별',
        currentValue: currentDisplay,
        options: const ['남성', '여성'],
      ),
    );

    if (result != null) {
      final dbValue = _genderDisplayToDB[result];
      if (dbValue != null) {
        await _updateProfile({'gender': dbValue});
      }
    }
  }

  Future<void> _editHeight() async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) => EditNumberDialog(
        title: '키',
        initialValue: _currentProfile?.height ?? 0,
        suffix: 'cm',
      ),
    );
    if (result != null) {
      await _updateProfile({'height': result});
    }
  }

  Future<void> _editWeight() async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) => EditNumberDialog(
        title: '체중',
        initialValue: _currentProfile?.weight ?? 0,
        suffix: 'kg',
      ),
    );
    if (result != null) {
      await _updateProfile({'weight': result});
    }
  }

  Future<void> _editActivityLevel() async {
    final currentDisplay = _activityDbToDisplay[_currentProfile?.activityLevel] ?? '보통';

    final result = await showDialog<String>(
      context: context,
      builder: (context) => EditSelectionDialog(
        title: '활동 수준',
        currentValue: currentDisplay,
        options: const ['낮음', '보통', '높음'],
      ),
    );

    if (result != null) {
      final dbValue = _activityDisplayToDB[result];
      if (dbValue != null) {
        await _updateProfile({'activity_level': dbValue});
      }
    }
  }

  Future<void> _editGoal() async {
    final currentDisplay = _goalDbToDisplay[_currentProfile?.goal] ?? '균형 잡힌 식단';

    final result = await showDialog<String>(
      context: context,
      builder: (context) => EditSelectionDialog(
        title: '목표',
        currentValue: currentDisplay,
        options: const ['혈당 조절', '체중 감량', '균형 잡힌 식단'],
      ),
    );

    if (result != null) {
      final dbValue = _goalDisplayToDB[result];
      if (dbValue != null) {
        await _updateProfile({'goal': dbValue});
      }
    }
  }

  Future<void> _editDiabetes() async {
    final currentDisplay = _diabetesDbToDisplay[_currentProfile?.diabetes] ?? '당뇨 없음';

    final result = await showDialog<String>(
      context: context,
      builder: (context) => EditSelectionDialog(
        title: '당뇨',
        currentValue: currentDisplay,
        options: const ['당뇨 없음', '1형 당뇨', '2형 당뇨'],
      ),
    );

    if (result != null) {
      final dbValue = _diabetesDisplayToDB[result];
      if (dbValue != null) {
        await _updateProfile({'diabetes': dbValue});
      }
    }
  }

  Future<void> _editAverageGlucose() async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) => EditNumberDialog(
        title: '평균 혈당',
        initialValue: _currentProfile?.averageGlucose ?? 0,
        suffix: 'mg/dL',
      ),
    );
    if (result != null) {
      await _updateProfile({'average_glucose': result});
    }
  }

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
    return RepaintBoundary(
      child: Padding(
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
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: '$label 수정',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final t = Theme.of(context).textTheme;
    return RepaintBoundary(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: t.bodyLarge),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    // Show message if no profile data
    if (_currentProfile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 64,
                color: c.outline,
              ),
              const SizedBox(height: 16),
              Text(
                '프로필 데이터 없음',
                style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '프로필을 생성하려면 온보딩 과정을 완료하세요.',
                style: t.bodyMedium?.copyWith(color: c.outline),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      children: [
        // 상단 타이틀 (AppBar 없이 내부에서 표기)
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '개인 정보',
            textAlign: TextAlign.left,
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),

        // Basic Info
        _fieldTile(context, '이름', _currentProfile?.name ?? '설정 안됨', onEdit: _editName),
        _fieldTile(context, '나이', _currentProfile?.age.toString() ?? '설정 안됨', onEdit: _editAge),
        _fieldTile(context, '성별', _formatGender(_currentProfile?.gender), onEdit: _editGender),
        _fieldTile(context, '키', _currentProfile != null ? _heightStr(_currentProfile!.height) : '설정 안됨', onEdit: _editHeight),
        _fieldTile(context, '체중', _currentProfile != null ? _weightStr(_currentProfile!.weight) : '설정 안됨', onEdit: _editWeight),
        _fieldTile(context, '체질량지수', _currentProfile != null ? _bmiStr(_currentProfile!.bmi) : '설정 안됨'),

        // Health Info
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('건강 정보', style: t.titleMedium?.copyWith(color: c.primary)),
        ),
        const SizedBox(height: 8),
        _fieldTile(context, '활동 수준', _formatActivityLevel(_currentProfile?.activityLevel), onEdit: _editActivityLevel),
        _fieldTile(context, '목표', _formatGoal(_currentProfile?.goal), onEdit: _editGoal),
        _fieldTile(context, '당뇨', _formatDiabetes(_currentProfile?.diabetes), onEdit: _editDiabetes),
        _fieldTile(context, '평균 혈당', _currentProfile != null ? '${_currentProfile!.averageGlucose.toStringAsFixed(1)} mg/dL' : '설정 안됨', onEdit: _editAverageGlucose),

        // Diet Preferences
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('식단 선호도', style: t.titleMedium?.copyWith(color: c.primary)),
        ),
        const SizedBox(height: 8),
        _fieldTile(context, '식사', _formatMeals(_currentProfile?.meals)),
        _fieldTile(context, '식사 방법', _formatMealMethod(_currentProfile?.mealMethod)),
        _fieldTile(context, '식이 제한', _formatDietaryRestrictions(_currentProfile?.dietaryRestrictions)),
        _fieldTile(context, '알레르기', _formatAllergies(_currentProfile?.allergies)),

        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('더보기', style: t.titleMedium?.copyWith(color: c.primary)),
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
                title: '이용 약관',
                icon: Icons.article_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TermsAndConditionsScreen(),
                  ),
                ),
              ),
              const Divider(height: 1),
              _actionTile(
                context,
                title: '개인정보 처리방침',
                icon: Icons.privacy_tip_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
              ),
              const Divider(height: 1),
              _actionTile(
                context,
                title: '고객 지원',
                icon: Icons.email_outlined,
                onTap: () => _openMail(context),
              ),
              const Divider(height: 1),
              _actionTile(
                context,
                title: '계정 설정',
                icon: Icons.settings_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AccountSettingsScreen(),
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
