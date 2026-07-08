import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'styles.dart';
import 'widgets/gradient_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // ---------------------------------------------------------
  // FIREBASE PASSWORD RESET LOGIC (unchanged)
  // ---------------------------------------------------------
  Future<void> _resetPassword() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent! Check your email.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is badly formatted.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // --- Icon badge ---
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Heading ---
              const Center(
                child: Text(
                  'Forgot\nPassword?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display,
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  "Don't worry! It happens. Please enter the email address associated with your account.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
              ),
              const SizedBox(height: 36),

              // --- Email ---
              const Text('EMAIL', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: AppDecorations.input(
                  hint: 'you@example.com',
                  prefixIcon: const Icon(Icons.mail_outline_rounded,
                      color: AppColors.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 32),

              // --- Submit ---
              GradientButton(
                label: 'Send Reset Link',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _resetPassword,
              ),
              const SizedBox(height: 24),

              // --- Back to login ---
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
