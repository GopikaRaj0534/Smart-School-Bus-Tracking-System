import 'dart:math';

class ValidationHelper {
  // Check for empty string
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Validate Email Address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validate Phone Number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number (10-15 digits)';
    }
    return null;
  }

  // Validate Password length >= 8
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  // Validate Confirm Password matching
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm password is required';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Captcha Generator State Model
  static CaptchaQuestion generateCaptcha() {
    final rand = Random();
    final num1 = rand.nextInt(10) + 1; // 1 to 10
    final num2 = rand.nextInt(10) + 1; // 1 to 10
    final isAddition = rand.nextBool();
    
    if (isAddition) {
      return CaptchaQuestion(
        question: '$num1 + $num2 = ?',
        answer: num1 + num2,
      );
    } else {
      // Ensure result is positive
      final large = max(num1, num2);
      final small = min(num1, num2);
      return CaptchaQuestion(
        question: '$large - $small = ?',
        answer: large - small,
      );
    }
  }
}

class CaptchaQuestion {
  final String question;
  final int answer;

  CaptchaQuestion({required this.question, required this.answer});
}
