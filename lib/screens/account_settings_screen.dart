import 'package:flutter/material.dart';
import 'package:glucous_meal_app/services/api_service.dart';
import 'package:glucous_meal_app/services/uuid_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  GoogleSignInAccount? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);
      await _googleSignIn.signIn();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google 계정이 연결되었습니다')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignOut() async {
    try {
      setState(() => _isLoading = true);
      await _googleSignIn.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google 계정 연결이 해제되었습니다')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 실패: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Clear local data and navigate to login/onboarding
      await _googleSignIn.signOut();

      // Navigate to onboarding screen and clear navigation stack
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: const Text(
          '정말 계정을 삭제하시겠습니까? 이 작업은 취소할 수 없습니다. 모든 데이터가 영구적으로 삭제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        setState(() => _isLoading = true);

        // Get UUID and delete account from backend
        final uuid = await UUIDService.getOrCreateUUID();

        // Call delete API (you'll need to implement this in your backend)
        final response = await ApiService.deleteUserAccount(uuid);

        if (mounted) {
          // Clear local data
          await _googleSignIn.signOut();

          // Navigate to onboarding screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('계정이 삭제되었습니다')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('계정 삭제 실패: $error')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 설정'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Google Account Section
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Google 계정',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_currentUser != null) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundImage: _currentUser!.photoUrl != null
                                  ? NetworkImage(_currentUser!.photoUrl!)
                                  : null,
                              child: _currentUser!.photoUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(_currentUser!.displayName ?? '이름 없음'),
                            subtitle: Text(_currentUser!.email),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _handleGoogleSignOut,
                              icon: const Icon(Icons.link_off),
                              label: const Text('Google 계정 연결 해제'),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Google 계정을 연결하여 기기 간 데이터를 동기화하고 추가 기능을 사용하세요.',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _handleGoogleSignIn,
                              icon: const Icon(Icons.account_circle),
                              label: const Text('Google 계정 연결'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Sign Out Section
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('로그아웃'),
                    subtitle: const Text('계정에서 로그아웃합니다'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _handleSignOut,
                  ),
                ),

                // Delete Account Section
                Card(
                  color: Colors.red.shade50,
                  child: ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
                    title: Text(
                      '계정 삭제',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    subtitle: const Text(
                      '계정과 모든 데이터를 영구적으로 삭제합니다',
                    ),
                    trailing: Icon(Icons.chevron_right, color: Colors.red.shade700),
                    onTap: _handleDeleteAccount,
                  ),
                ),

                const SizedBox(height: 24),

                // Info Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '계정 정보',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '계정 데이터는 안전하게 암호화되어 저장됩니다. '
                    '계정을 삭제하면 모든 개인 데이터, 건강 기록 및 설정이 서버에서 영구적으로 삭제됩니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
