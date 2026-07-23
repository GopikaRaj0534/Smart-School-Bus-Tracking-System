import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/routes.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0; // 0 = Email Input, 1 = Dummy OTP, 2 = New Password Input

  void _sendOtp() {
    final emailError = ValidationHelper.validateEmail(_emailController.text);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailError),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification code sent to your email! (Use dummy: 1234)'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _verifyOtp() {
    if (_otpController.text.trim() == '1234' || _otpController.text.trim() == '0000' || _otpController.text.trim().length == 4) {
      setState(() {
        _currentStep = 2;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid code. Use code "1234" to proceed.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(
      email: _emailController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! Please log in.'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to reset password'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Step Indicator
              Row(
                children: [
                  _buildStepIndicator(0, 'Email'),
                  _buildStepDivider(),
                  _buildStepIndicator(1, 'OTP'),
                  _buildStepDivider(),
                  _buildStepIndicator(2, 'Password'),
                ],
              ),
              const SizedBox(height: 32),

              if (_currentStep == 0) ...[
                Text(
                  'Forgot Password?',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your registered email address and we'll send you a 4-digit code to verify your identity.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  labelText: 'Email Address',
                  hintText: 'Enter your school email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Send Verification Code',
                  onPressed: _sendOtp,
                ),
              ] else if (_currentStep == 1) ...[
                Text(
                  'Verify Your Identity',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a 4-digit code to ${_emailController.text}. Enter the code below. Use code "1234" to pass verification.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                
                // Dummy OTP inputs
                CustomTextField(
                  labelText: 'Verification Code',
                  hintText: 'Enter 4-digit code',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.lock_open_rounded,
                  validator: (v) => ValidationHelper.validateRequired(v, 'Verification code'),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Verify Code',
                  onPressed: _verifyOtp,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                      });
                    },
                    child: Text(
                      'Back to Email',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                )
              ] else if (_currentStep == 2) ...[
                Text(
                  'Create New Password',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your identity has been verified. Now set your new secure password.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        labelText: 'New Password',
                        hintText: 'Minimum 8 characters',
                        controller: _newPasswordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: ValidationHelper.validatePassword,
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter new password',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: (v) => ValidationHelper.validateConfirmPassword(
                          v,
                          _newPasswordController.text,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: 'Reset Password',
                        isLoading: authProvider.isLoading,
                        onPressed: _handleResetPassword,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isCompleted = _currentStep > stepIndex;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.successColor
                : isActive
                    ? AppTheme.primaryColor
                    : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppTheme.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? AppTheme.primaryColor
                    : isCompleted
                        ? AppTheme.successColor
                        : AppTheme.textLight,
              ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: 1.5,
        color: Colors.grey.shade300,
      ),
    );
  }
}
