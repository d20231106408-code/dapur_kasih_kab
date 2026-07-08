import 'package:flutter/material.dart';

import 'login_page.dart';
import 'styles.dart';

// ---------------------------------------------------------
// WELCOME PAGE — premium onboarding screen
// Cream background, brand header, rounded hero image card and
// a navy pill CTA, matching the approved UI reference.
// ---------------------------------------------------------
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // --- Brand header ---
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: AppShadows.button,
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DapurKasih',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Kolej Aminuddin Baki (KAB)',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // --- Headline ---
                  const Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppGradients.primary.createShader(bounds),
                    child: const Text(
                      'DapurKasih',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Text(
                        "Let's Get Started ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text('✨', style: TextStyle(fontSize: 18)),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // --- Hero image card ---
                  Expanded(
                    flex: 9,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: AppShadows.card,
                        image: const DecorationImage(
                          image: AssetImage('assets/dapur.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Subtle gradient at the bottom of the photo for depth
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.navy.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // --- CTA ---
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Let's Get Started",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
