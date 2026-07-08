import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/admin_dashboard.dart';
import 'screens/admin_login.dart';
import 'screens/dashboard.dart';
import 'services/firestore_service.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import 'styles.dart';
import 'widgets/gradient_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ---------------------------------------------------------
  // FIREBASE LOGIN LOGIC (unchanged)
  // ---------------------------------------------------------
  Future<void> _loginUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Route by role: admins go to the admin dashboard,
      // students to the booking dashboard.
      final String role =
          await FirestoreService().getUserRole(credential.user!.uid);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => role == "admin"
                ? const AdminDashboardPage()
                : const DashboardPage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is badly formatted.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Incorrect email or password.';
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
    _passwordController.dispose();
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

              // --- Heading ---
              const Row(
                children: [
                  Text(
                    'Welcome Back! ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text('👋', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Login', style: AppTextStyles.display),
              const SizedBox(height: 6),
              const Text('Sign in to continue.', style: AppTextStyles.body),
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
              const SizedBox(height: 22),

              // --- Password ---
              const Text('PASSWORD', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: AppDecorations.input(
                  hint: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.textSecondary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // --- Forgot password ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // --- Login button (gradient) ---
              GradientButton(
                label: 'Log in',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _loginUser,
              ),
              const SizedBox(height: 28),

              // --- Signup link ---
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: AppTextStyles.body,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign up!',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // --- Divider ---
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('staff access', style: AppTextStyles.caption),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 20),

              // --- Admin login (navy outline) ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.navy, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  icon: const Icon(Icons.admin_panel_settings_outlined,
                      size: 20),
                  label: const Text(
                    'Admin Login',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminLoginPage(),
                      ),
                    );
                  },
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
