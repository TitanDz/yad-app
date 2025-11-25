import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/core/validators/input_validator.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _emailError = InputValidator.validateEmail(_emailController.text);
      _passwordError =
          InputValidator.validatePasswordBasic(_passwordController.text);
    });

    return _emailError == null && _passwordError == null;
  }

  void _handleSignIn() {
    if (!_validateForm()) {
      return;
    }

    context.read<AuthBloc>().add(
          AuthLoginEvent(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _isLoading = true);
          } else if (state is AuthLoginSuccess) {
            setState(() => _isLoading = false);
            context.push('/otp', extra: state.email);
          } else if (state is AuthFailure) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        child: Container(
          color: const Color(0xFF4D61DE),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),

                        // Header Row: The10th (centered) and Help Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'The10th',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.help_outline, color: Colors.white),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Welcome Title
                        Text(
                          'Welcome',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          'Sign in or create an account to continue',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLoading,
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(
                                () => _emailError =
                                    InputValidator.validateEmail(_emailController.text),
                              );
                            }
                          },
                          style: const TextStyle(color: Colors.black, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: Colors.black.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                              child: SvgPicture.asset(
                                'assets/images/Accounts/mail.svg',
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withValues(alpha: 0.6),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        if (_emailError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _emailError!,
                                style: TextStyle(
                                  color: AppTheme.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          enabled: !_isLoading,
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(
                                () => _passwordError =
                                    InputValidator.validatePasswordBasic(
                                        _passwordController.text),
                              );
                            }
                          },
                          style: const TextStyle(color: Colors.black, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Colors.black.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                              child: SvgPicture.asset(
                                'assets/images/Accounts/lock.svg',
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withValues(alpha: 0.6),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.black.withValues(alpha: 0.6),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                              padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                              constraints: const BoxConstraints(),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        if (_passwordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _passwordError!,
                                style: TextStyle(
                                  color: AppTheme.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Forgot Password Link
                        GestureDetector(
                          onTap: _isLoading ? null : () => context.push('/forgot-password'),
                          child: Text(
                            'Forgot password?',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.95),
                              foregroundColor: AppTheme.divinity,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _isLoading ? 'Signing in...' : 'Sign In',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppTheme.divinity,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Or continue with
                        Text(
                          'Or continue with',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSocialButton(
                              asset: 'assets/images/Accounts/apple.svg',
                              label: 'Apple',
                              onPressed: _isLoading ? null : () {},
                            ),
                            _buildSocialButton(
                              asset: 'assets/images/Accounts/mail.svg',
                              label: 'Mail',
                              onPressed: _isLoading ? null : () {},
                            ),
                            _buildSocialButton(
                              asset: 'assets/images/Accounts/google.svg',
                              label: 'Google',
                              onPressed: _isLoading ? null : () {},
                            ),
                            _buildSocialButton(
                              asset: 'assets/images/Accounts/phone.svg',
                              label: 'Phone',
                              onPressed: _isLoading ? null : () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String asset,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 70,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
          minimumSize: const Size(70, 80),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              asset,
              width: 28,
              height: 28,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
