import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/core/validators/input_validator.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailPhoneController = TextEditingController();
  String? _inputError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailPhoneController.dispose();
    super.dispose();
  }

  bool _validateInput() {
    final input = _emailPhoneController.text.trim();
    
    setState(() {
      if (input.isEmpty) {
        _inputError = 'Please enter your email or phone number';
      } else if (input.contains('@')) {
        // Validate as email
        _inputError = InputValidator.validateEmail(input);
      } else if (RegExp(r'^[0-9-\s]+$').hasMatch(input)) {
        // Validate as phone number
        _inputError = null;
      } else {
        _inputError = 'Please enter a valid email or phone number';
      }
    });

    return _inputError == null;
  }

  void _handleSendCode() {
    if (!_validateInput()) {
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.push('/forgot-password-code', extra: _emailPhoneController.text.trim());
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
          'Forgot Password',
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
            
            // Title
            const Text(
              'Enter your email or phone',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral900,
              ),
            ),
            const SizedBox(height: 24),

            // Email/Phone Input Field
            TextField(
              controller: _emailPhoneController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              onChanged: (_) {
                if (_inputError != null) {
                  _validateInput();
                }
              },
              decoration: InputDecoration(
                hintText: 'Email or Phone',
                hintStyle: const TextStyle(color: AppTheme.neutral500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _inputError != null
                        ? AppTheme.error
                        : Colors.transparent,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _inputError != null
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
                errorText: _inputError,
                errorStyle: const TextStyle(
                  color: AppTheme.error,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Send Code Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSendCode,
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
                      'Send Reset Link/Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 48),

            // Remember Password & Back to Login
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Remember your password?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
