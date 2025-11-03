import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:yad_app/features/auth/presentation/bloc/otp_event.dart';
import 'package:yad_app/features/auth/presentation/bloc/otp_state.dart';

class OtpPage extends StatefulWidget {
  final String email;
  final String phoneNumber;

  const OtpPage({
    required this.email,
    required this.phoneNumber,
    super.key,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  late FocusNode _focusNode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  String _getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  bool _isOtpComplete() {
    return _otpControllers.every((c) => c.text.isNotEmpty);
  }

  void _handleSubmit() {
    if (!_isOtpComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    context.read<OtpBloc>().add(
          OtpVerifyEvent(
            email: widget.email,
            code: _getOtpCode(),
          ),
        );
  }

  void _handleResend() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    context.read<OtpBloc>().add(
          OtpResendEvent(email: widget.email),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.neutral900),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<OtpBloc, OtpState>(
        listener: (context, state) {
          if (state is OtpLoading) {
            setState(() => _isLoading = true);
          } else if (state is OtpVerified) {
            setState(() => _isLoading = false);
            context.push('/initial-setup');
          } else if (state is OtpFailure) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          } else if (state is OtpResendSuccess) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Code resent successfully'),
                backgroundColor: AppTheme.success,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Enter code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 24),

              // Subtitle
              const Text(
                'Check your messages',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'We sent a code to +1 (${widget.phoneNumber}). Enter it below to continue.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.neutral600,
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => OtpInputField(
                    controller: _otpControllers[index],
                    focusNode: index == 0 ? _focusNode : null,
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                      setState(() {});
                    },
                    enabled: !_isLoading,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Resend Code
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _handleResend,
                  child: const Text(
                    'Resend code',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || !_isOtpComplete()
                      ? null
                      : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: AppTheme.neutral400,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final FocusNode? focusNode;
  final bool enabled;

  const OtpInputField({
    required this.controller,
    required this.onChanged,
    this.focusNode,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppTheme.neutral100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppTheme.primary,
              width: 2,
            ),
          ),
        ),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
