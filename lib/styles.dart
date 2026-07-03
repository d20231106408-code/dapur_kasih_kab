import 'package:flutter/material.dart';

/// Color palette
class AppColors {
  static const Color primary = Colors.deepOrange; // main orange theme
  static const Color background = Color(0xFFFDF6EC); // soft beige background
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color success = Colors.green;
  static const Color error = Colors.red;
}

/// Text styles
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

/// Spacing constants
class AppSpacing {
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const SizedBox smallGap = SizedBox(height: 10);
  static const SizedBox mediumGap = SizedBox(height: 20);
}

/// Button styles
class AppButtonStyles {
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
