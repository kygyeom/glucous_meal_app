import 'package:flutter/foundation.dart';
import 'package:glucous_meal_app/models/models.dart';
import 'api_service.dart';

/// User state management provider
class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch user profile from backend
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profile = await ApiService.fetchUserProfile();
      _userProfile = profile;
      _error = profile == null ? 'Failed to load user profile' : null;
    } catch (e) {
      _error = 'Error loading user profile: $e';
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile locally
  void updateProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  /// Clear user profile (logout)
  void clearProfile() {
    _userProfile = null;
    _error = null;
    notifyListeners();
  }
}
