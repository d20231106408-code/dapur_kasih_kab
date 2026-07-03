import 'package:flutter/material.dart';
import '../styles.dart';

class ReportDamagePage extends StatelessWidget {
  ReportDamagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Report Damage", style: AppTextStyles.heading),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Center(
          child: Text(
            "Report Damage Page (to be implemented)",
            style: AppTextStyles.subheading,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
