import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';

class ForgotPasswordCodePage extends StatefulWidget {
  final String emailOrPhone;

  const ForgotPasswordCodePage({
    super.key,
    required this.emailOrPhone,
  });

  @override
  State<ForgotPasswordCodePage> createState() => _ForgotPasswordCodePageState();
}

class _ForgotPasswordCodePageState extends State<ForgotPasswordCodePage> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(4, (_) => FocusNode());
    _controllers = List.generate(4, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleCodeInput(String value, int index) {
    if (value.isEmpty) {
      return;
    }

    // Only allow single digit
    if (value.length > 1) {
      _controllers[index].text = value[value.length - 1];
      return;
    }

    // Move to next field if not the last one
    if (index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else {
      // All fields filled, verify code
      _verifyCode();
    }
  }

  void _verifyCode() {
    final code = _controllers.map((c) => c.text).join();
    
    if (code.length != 4) {
      setState(() => _errorMessage = 'Please enter all 4 digits');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
    // Mock verification - accept any 4-digit code
        context.push('/reset-password', extra: widget.emailOrPhone);
      }
    });
  }

  void _resendCode() {
    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code resent successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
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
              'Enter Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral900,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            const Text(
              'Please enter the 4-digit code we sent to your email address.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.neutral600,
              ),
            ),
            const SizedBox(height: 32),

            // Code Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (index) => SizedBox(
                  width: 60,
                  height: 60,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    enabled: !_isLoading,
                    onChanged: (value) => _handleCodeInput(value, index),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.neutral300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.neutral300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Error Message
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.error,
                ),
              ),
            const SizedBox(height: 24),

            // Resend Code Link
            Center(
              child: Column(
                children: [
                  const Text(
                    'Didn\'t receive the code?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.neutral600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading ? null : _resendCode,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Resend Code',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isLoading
                            ? AppTheme.neutral400
                            : AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Next Button
            ElevatedButton(
              onPressed: _isLoading || _controllers.any((c) => c.text.isEmpty)
                  ? null
                  : _verifyCode,
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
                      'Next',
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
