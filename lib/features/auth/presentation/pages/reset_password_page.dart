import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';

class ResetPasswordPage extends StatefulWidget {
  final String emailOrPhone;

  const ResetPasswordPage({
    super.key,
    required this.emailOrPhone,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;
  String? _confirmError;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validatePasswords() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _passwordError = _validateNewPassword(newPassword);
      _confirmError = _validateConfirmPassword(newPassword, confirmPassword);
    });

    return _passwordError == null && _confirmError == null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must include a number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must include a special character';
    }

    return null;
  }

  String? _validateConfirmPassword(String newPassword, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (newPassword != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _handleResetPassword() {
    if (!_validatePasswords()) {
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.pushReplacement('/password-reset-success');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.neutral900,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Set New Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.neutral900,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // New Password Field
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              enabled: !_isLoading,
              onChanged: (_) {
                if (_passwordError != null) {
                  setState(() {
                    _passwordError = _validateNewPassword(_newPasswordController.text);
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'New Password',
                hintStyle: const TextStyle(color: AppTheme.neutral500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _passwordError != null
                        ? AppTheme.error
                        : Colors.transparent,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _passwordError != null
                        ? AppTheme.error
                        : Colors.transparent,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppTheme.error,
                    width: 2,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.neutral500,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                errorText: _passwordError,
                errorStyle: const TextStyle(
                  color: AppTheme.error,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password Field
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              enabled: !_isLoading,
              onChanged: (_) {
                if (_confirmError != null) {
                  setState(() {
                    _confirmError = _validateConfirmPassword(
                      _newPasswordController.text,
                      _confirmPasswordController.text,
                    );
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Confirm New Password',
                hintStyle: const TextStyle(color: AppTheme.neutral500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _confirmError != null
                        ? AppTheme.error
                        : Colors.transparent,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _confirmError != null
                        ? AppTheme.error
                        : Colors.transparent,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppTheme.error,
                    width: 2,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.neutral500,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                errorText: _confirmError,
                errorStyle: const TextStyle(
                  color: AppTheme.error,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Password Requirements
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Password must be at least 8 characters long and include a number and a special character.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.neutral600,
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Reset Password Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: AppTheme.neutral400,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
