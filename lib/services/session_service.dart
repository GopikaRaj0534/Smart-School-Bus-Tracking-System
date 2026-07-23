import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  SharedPreferences? _prefs;

  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyUserRole = 'user_role';
  static const String keyLastActive = 'last_active_timestamp';
  static const String keyRememberMe = 'remember_me';

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool isLoggedIn() {
    if (_prefs == null) return false;
    final loggedIn = _prefs!.getBool(keyIsLoggedIn) ?? false;
    if (!loggedIn) return false;

    // Check remember me flag
    final rememberMe = _prefs!.getBool(keyRememberMe) ?? false;
    if (rememberMe) {
      return true; // Don't enforce 5-minute timeout if remember me is checked, OR we can still check it. Let's make it timeout regardless or keep session alive if remember me is off.
    }

    // Check inactivity
    final lastActive = _prefs!.getInt(keyLastActive) ?? 0;
    if (lastActive == 0) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - lastActive;
    
    // 5 minutes in milliseconds = 300,000
    if (diff > 300000) {
      clearSession();
      return false;
    }
    
    // Update active time since they just opened the app
    updateActivity();
    return true;
  }

  Future<void> saveSession({
    required String email,
    required String name,
    required String role,
    required bool rememberMe,
  }) async {
    await init();
    await _prefs!.setBool(keyIsLoggedIn, true);
    await _prefs!.setString(keyUserEmail, email);
    await _prefs!.setString(keyUserName, name);
    await _prefs!.setString(keyUserRole, role);
    await _prefs!.setBool(keyRememberMe, rememberMe);
    await updateActivity();
  }

  Future<void> updateActivity() async {
    await init();
    await _prefs!.setInt(keyLastActive, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clearSession() async {
    await init();
    await _prefs!.setBool(keyIsLoggedIn, false);
    await _prefs!.remove(keyUserEmail);
    await _prefs!.remove(keyUserName);
    await _prefs!.remove(keyUserRole);
    await _prefs!.remove(keyLastActive);
    // Note: We don't remove keyRememberMe so the UI can prefill remember me status
  }

  bool getRememberMe() {
    if (_prefs == null) return false;
    return _prefs!.getBool(keyRememberMe) ?? false;
  }

  String getSavedEmail() {
    if (_prefs == null) return '';
    return _prefs!.getString(keyUserEmail) ?? '';
  }

  String getSavedName() {
    if (_prefs == null) return '';
    return _prefs!.getString(keyUserName) ?? '';
  }

  String getSavedRole() {
    if (_prefs == null) return 'Parent';
    return _prefs!.getString(keyUserRole) ?? 'Parent';
  }
}
