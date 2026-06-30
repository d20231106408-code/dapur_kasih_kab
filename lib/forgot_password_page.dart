import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Controller to read the text typed into the email field
  final TextEditingController _emailController = TextEditingController();
  
  // Loading state to show a spinner while Firebase processes the request
  bool _isLoading = false;

  // ---------------------------------------------------------
  // FIREBASE PASSWORD RESET LOGIC
  // ---------------------------------------------------------
  Future<void> _resetPassword() async {
    final String email = _emailController.text.trim();

    // 1. Check if the email field is empty
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    // 2. Start the loading spinner
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Tell Firebase to send a reset link to this email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // 4. If successful, show a success message and go back to the Login page
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent! Check your email.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to the previous screen (Login)
      }
    } on FirebaseAuthException catch (e) {
      // 5. Handle errors (e.g., user not found, badly formatted email)
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
      // 6. Stop the loading spinner
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Clean up the controller when the page is closed
  @override
  void dispose() {
    _emailController.dispose();
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
                  height: 300,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/dapur.jpg', // Make sure this matches your asset path
                    fit: BoxFit.cover,
                  ),
                ),
                
                // 2. The Back Arrow Button (Top Left)
                SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context); // Goes back to Login Page
                    },
                  ),
                ),

                // 3. The White Curved Top overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60, // Height of the curve
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(80), // Creates the curve from the image
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ---------------------------------------------------------
            // BOTTOM SECTION: FORM AND BUTTONS
            // ---------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Center(
                    child: Text(
                      'Forgot\nPassword?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Subtitle Instructions
                  const Center(
                    child: Text(
                      "Don't worry! It happens. Please enter the email address associated with your account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Label
                  const Text(
                    'EMAIL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Email TextField
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade300,
                      hintText: 'jiara@example.com',
                      hintStyle: const TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
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
                      onPressed: _isLoading ? null : _resetPassword, // Disables if loading
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Send Reset Link',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 25), // Space between button and text

                  // --- NEW: Back to Login Text Button ---
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Takes the user back to Login
                      },
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600, // Slightly bold for better visibility
                          fontSize: 15,
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
}