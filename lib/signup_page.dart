import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'screens/dashboard.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controllers to read the text typed into the fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // Loading state to show a spinner while Firebase processes the signup
  bool _isLoading = false;

  // ---------------------------------------------------------
  // DATE OF BIRTH PICKER LOGIC
  // ---------------------------------------------------------
  Future<void> _selectDate() async {
    // Shows a calendar popup
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(1900),   // Earliest allowed date
      lastDate: DateTime.now(),    // Latest allowed date (today)
    );

    // If the user picked a date, format it and put it in the text field
    if (pickedDate != null) {
      setState(() {
        // Simple manual formatting to YYYY-MM-DD
        _dobController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // ---------------------------------------------------------
  // FIREBASE SIGNUP LOGIC
  // ---------------------------------------------------------
  Future<void> _signUpUser() async {
    // 1. Validate that all fields are filled
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // 2. Start loading spinner
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Create the user in Firebase Auth with Email and Password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 4. Update the user's profile with their Name
      // Update nama dalam Firebase Authentication
await userCredential.user?.updateDisplayName(
  _nameController.text.trim(),
);

// Simpan maklumat pengguna ke Firestore
await FirebaseFirestore.instance
    .collection("users")
    .doc(userCredential.user!.uid)
    .set({
  "name": _nameController.text.trim(),
  "email": _emailController.text.trim(),
  "phone": "",
  "address": "",
  "dob": _dobController.text.trim(),
  "imageUrl": "",
  "createdAt": FieldValue.serverTimestamp(),
});

      // 5. If successful, navigate to Dashboard and clear navigation history
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
          (route) => false, // This prevents the user from clicking 'back' to the signup page
        );
      }
    } on FirebaseAuthException catch (e) {
      // 6. Handle specific Firebase errors gracefully
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
      // 7. Stop loading spinner
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Clean up controllers to prevent memory leaks
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------------------------------------------------
            // TOP SECTION: IMAGE AND CURVED OVERLAY
            // ---------------------------------------------------------
            Stack(
              children: [
                // 1. The Background Image
                SizedBox(
                  height: 280, // Slightly shorter than login page based on design
                  width: double.infinity,
                  child: Image.asset(
                    'assets/dapur.jpg', // Replace with your actual image path
                    fit: BoxFit.cover,
                  ),
                ),
                
                // 2. The Back Arrow Button
                SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                // 3. The White Curved Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(80), // Curve on the top left this time
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ---------------------------------------------------------
            // BOTTOM SECTION: FORM AND BUTTON
            // ---------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left
                children: [
                  // Title
                  const Center(
                    child: Text(
                      'Create new\nAccount',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        height: 1.1, // Tightens the space between the two lines
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Subtitle with clickable "Log in here" link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already Registered? ',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            'Log in here.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue, // Blue link color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- NAME FIELD ---
                  _buildLabel('NAME'),
                  TextField(
                    controller: _nameController,
                    decoration: _buildInputDecoration('Jiara Martins'),
                  ),
                  const SizedBox(height: 20),

                  // --- EMAIL FIELD ---
                  _buildLabel('EMAIL'),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration('hello@reallygreatsite.com'),
                  ),
                  const SizedBox(height: 20),

                  // --- PASSWORD FIELD ---
                  _buildLabel('PASSWORD'),
                  TextField(
                    controller: _passwordController,
                    obscureText: true, // Hides the text
                    decoration: _buildInputDecoration('******'),
                  ),
                  const SizedBox(height: 20),

                  // --- DATE OF BIRTH FIELD ---
                  _buildLabel('DATE OF BIRTH'),
                  TextField(
                    controller: _dobController,
                    readOnly: true, // Prevents typing; forces user to tap for the calendar
                    onTap: _selectDate, // Triggers the DatePicker function
                    decoration: _buildInputDecoration('Select').copyWith(
                      // You can optionally add a calendar icon here
                      suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- SIGN UP BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7A22), // Matching Orange
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _signUpUser,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Sign up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // HELPER WIDGETS
  // Keeping the build method clean by separating repeated UI
  // ---------------------------------------------------------
  
  // Helper to create the small grey labels above TextFields
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // Helper to standardise the styling of all TextFields
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade300, // Light grey background
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none, // Removes the underline
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}