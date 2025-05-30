import 'package:firebase_auth/firebase_auth.dart';
import 'package:laundry_app/data/model/user_data.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/repository/admin_repo.dart';
import 'data/repository/user_repo.dart';

class UserPreferencesManager {
  static const String _isAdminKey = 'is_admin';
  static const String _keyIsUserProfileComplete = 'isUserProfileComplete';
  static const String _keyUserData = 'userData';
  static const String _keyAuthToken = 'userAuthToken';

  final SharedPreferences _prefs;
  final FirebaseAuth _auth;
  final IUserRepository _userRepository;
  final AdminRepository _adminRepository;

  UserPreferencesManager(this._prefs, this._auth, this._userRepository,this._adminRepository) {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        clearUserData();
      }
    });
  }

  bool get isUserProfileComplete => _prefs.getBool(_keyIsUserProfileComplete) ?? false;
  set isUserProfileComplete(bool value) => _prefs.setBool(_keyIsUserProfileComplete, value);
  bool get isAdmin => _prefs.getBool(_isAdminKey) ?? false;
  Future<void> setAdminStatus(bool isAdmin) async {
    await _prefs.setBool(_isAdminKey, isAdmin);
  }

  Future<void> _checkAndUpdateAdminStatus(String? email) async {
    if (email == null) {
      await setAdminStatus(false);
      return;
    }

    final result = await _adminRepository.isUserAdmin(email);
    result.fold(
            (failure) async => await setAdminStatus(false),
            (isAdmin) async => await setAdminStatus(isAdmin)
    );
  }
  // Update profile completion status
  Future<void> updateProfileStatus() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      await _prefs.setBool(_keyIsUserProfileComplete, false);
      return;
    }

    final result = await _userRepository.getUserInfo(userId);
    final isComplete = result.fold(
          (failure) => false,
          (user) => user.name.isNotEmpty && user.phone.isNotEmpty && user.address.isNotEmpty && user.photoUrl.isNotEmpty,
    );

    await _prefs.setBool(_keyIsUserProfileComplete, isComplete);
  }

  UserData? get currentUser {
    final String? jsonData = _prefs.getString(_keyUserData);
    if (jsonData == null) return null;
    try {
      return UserData.fromJson(json.decode(jsonData));
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  Future<void> setCurrentUser(UserData user) async {
    try {
      final jsonData = json.encode(user.toJson());
      await _prefs.setString(_keyUserData, jsonData);
    } catch (e) {
      print('Error saving user data: $e');
      throw Exception('Failed to save user data');
    }
  }

  String? get authToken => _prefs.getString(_keyAuthToken);
  Future<void> setAuthToken(String token) => _prefs.setString(_keyAuthToken, token);

  Future<void> clearUserData() async {
    await _prefs.remove(_keyUserData);
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyIsUserProfileComplete);
    await _prefs.remove(_isAdminKey);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await clearUserData();
  }

  bool get isReadyForMain => isUserProfileComplete && _auth.currentUser != null;
  bool get isReadyForAdminDashboard => isReadyForMain && isAdmin && _auth.currentUser != null;
}