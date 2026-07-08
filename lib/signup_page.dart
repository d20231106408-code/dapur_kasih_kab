import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'screens/dashboard.dart';
import 'services/firestore_service.dart';
import 'styles.dart';
import 'widgets/gradient_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _memberIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ---------------------------------------------------------
  // DATE OF BIRTH PICKER LOGIC (unchanged)
  // ---------------------------------------------------------
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // ---------------------------------------------------------
  // FIREBASE SIGNUP LOGIC (unchanged)
  // ---------------------------------------------------------
  Future<void> _signUpUser() async {
    if (_nameController.text.isEmpty ||
        _memberIdController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final String phone = _phoneController.text.trim();
    if (phone.length < 10 || phone.length > 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number must be 10-11 digits.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // Save the full profile to Firestore (users/{uid}).
      await FirestoreService().createUserProfile(
        userId: userCredential.user!.uid,
        name: _nameController.text.trim(),
        memberId: _memberIdController.text.trim().toUpperCase(),
        email: _emailController.text.trim(),
        phone: phone,
        dob: _dobController.text.trim(),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
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
    _nameController.dispose();
    _memberIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Small grey label above each field
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: AppTextStyles.label),
    );
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
              const SizedBox(height: 8),

              // --- Heading ---
              const Center(
                child: Text(
                  'Create new\nAccount',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display,
                ),
              ),
              const SizedBox(height: 12),

              // --- Log in link ---
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already Registered? ',
                        style: AppTextStyles.body),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Log in here.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- NAME ---
              _buildLabel('NAME'),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: AppDecorations.input(
                  hint: 'Your full name',
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      color: AppColors.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 18),

              // --- MEMBER ID ---
              _buildLabel('MEMBER ID (MATRIC NO.)'),
              TextField(
                controller: _memberIdController,
                textCapitalization: TextCapitalization.characters,
                decoration: AppDecorations.input(
                  hint: 'D20231106358',
                  prefixIcon: const Icon(Icons.badge_outlined,
                      color: AppColors.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 18),

              // --- EMAIL ---
              _buildLabel('EMAIL'),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: AppDecorations.input(
                  hint: 'you@example.com',
                  prefixIcon: const Icon(Icons.mail_outline_rounded,
                      color: AppColors.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 18),

              // --- PHONE ---
              _buildLabel('PHONE NUMBER'),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: AppDecorations.input(
                  hint: '0123456789',
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 18),

              // --- PASSWORD ---
              _buildLabel('PASSWORD'),
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
              const SizedBox(height: 18),

              // --- DATE OF BIRTH ---
              _buildLabel('DATE OF BIRTH'),
              TextField(
                controller: _dobController,
                readOnly: true,
                onTap: _selectDate,
                decoration: AppDecorations.input(
                  hint: 'Select date',
                  prefixIcon: const Icon(Icons.cake_outlined,
                      color: AppColors.textSecondary, size: 20),
                  suffixIcon: const Icon(Icons.calendar_today_outlined,
                      color: AppColors.textSecondary, size: 18),
                ),
              ),
              const SizedBox(height: 36),

              // --- SIGN UP BUTTON ---
              GradientButton(
                label: 'Sign up',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _signUpUser,
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
