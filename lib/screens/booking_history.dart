import 'package:flutter/material.dart';
import '../styles.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Booking History", style: AppTextStyles.heading),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Center(
          child: Text(
            "Booking History Page (to be implemented)",
            style: AppTextStyles.subheading,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
