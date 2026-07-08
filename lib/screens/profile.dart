import 'package:flutter/material.dart';
import '../styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Profile", style: AppTextStyles.heading),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Center(
          child: Text(
            "Profile Page (to be implemented)",
            style: AppTextStyles.subheading,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
