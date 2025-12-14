import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/student_profile.dart';

class ProfileProvider with ChangeNotifier {
  StudentProfile? _profile;
  bool _isLoading = false;
  String? _error;

  StudentProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load profile
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // print('🔍 Loading profile...');
      final result = await ApiService.fetchProfile();

      if (result['success'] && result['data'] != null) {
        // Extract profile data from the response
        final profileData = result['data']['profile'] ?? result['data'];
        if (profileData != null) {
          _profile = StudentProfile.fromJson(profileData);
          // print('✅ Profile loaded: ${_profile?.currentLevel}');
        } else {
          _error = 'No profile data found';
        }
      } else {
        _error = result['error'] ?? 'Failed to load profile';
      }
    } catch (e) {
      _error = 'Load failed: $e';
      // print('❌ Load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setup profile
  Future<Map<String, dynamic>> setupProfile(
    Map<String, dynamic> profileData,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // print('🛠️ Setting up profile: $profileData');
      final result = await ApiService.setupProfile(profileData);

      if (result['success']) {
        // print('✅ Setup success – reloading...');
        await loadProfile(); // Reload fresh data
      } else {
        _error = result['error'] ?? 'Setup failed';
      }
      return result;
    } catch (e) {
      _error = 'Setup failed: $e';
      // print('❌ Setup error: $e');
      return {'success': false, 'error': _error};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // BONUS: Clear error (call from UI button)
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
