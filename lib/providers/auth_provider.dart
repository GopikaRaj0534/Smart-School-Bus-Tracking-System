import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final SessionService _sessionService = SessionService();
  final ApiService _apiService = ApiService();

  // Initialize and check auto-login session
  Future<void> checkSavedSession() async {
    await _sessionService.init();
    if (_sessionService.isLoggedIn()) {
      _currentUser = UserModel(
        fullName: _sessionService.getSavedName(),
        email: _sessionService.getSavedEmail(),
        phoneNumber: '',
        role: _sessionService.getSavedRole(),
      );
      notifyListeners();
    }
  }

  // Login action calling API service
  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      
      if (response['success'] == true) {
        final userData = response['user'];
        _currentUser = UserModel.fromJson(userData);
        
        // Save session locally
        await _sessionService.saveSession(
          email: _currentUser!.email,
          name: _currentUser!.fullName,
          role: _currentUser!.role,
          rememberMe: rememberMe,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Registration action
  Future<bool> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        role: role,
      );

      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred during registration.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset Password Action
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.forgotPassword(email, newPassword);
      _isLoading = false;
      if (response['success'] == true) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Reset password failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred during password reset.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout action
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await _sessionService.clearSession();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  // Update activity timestamp to prevent auto-logout
  void recordActivity() {
    if (_currentUser != null) {
      _sessionService.updateActivity();
    }
  }
}
