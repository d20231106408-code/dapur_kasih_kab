import 'package:flutter/material.dart';

/// ============================================================
/// DapurKasih Design System
/// ============================================================
/// Premium palette inspired by the approved UI reference:
/// soft cream background, orange gradient accents, deep navy
/// contrast, white rounded cards with gentle shadows.
///
/// The class/member names used by existing screens (AppColors,
/// AppTextStyles, AppSpacing, AppButtonStyles) are preserved so
/// every screen keeps compiling — only the visual values changed.
/// ============================================================

/// Color palette
class AppColors {
  // Brand
  static const Color primary = Color(0xFFFF7A22); // signature orange
  static const Color primaryDark = Color(0xFFF25C05); // pressed / gradient end
  static const Color primarySoft = Color(0xFFFFF1E6); // tinted chips & fills
  static const Color navy = Color(0xFF1E2142); // dark hero / admin accent

  // Surfaces
  static const Color background = Color(0xFFFAF6F0); // soft cream
  static const Color card = Colors.white;
  static const Color inputFill = Color(0xFFF4F1EC);

  // Text
  static const Color textPrimary = Color(0xFF20242F);
  static const Color textSecondary = Color(0xFF8A8F9C);

  // Feedback
  static const Color success = Color(0xFF2FA84F);
  static const Color successSoft = Color(0xFFE4F6E9);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningSoft = Color(0xFFFDF2DC);
  static const Color error = Color(0xFFE5484D);
  static const Color errorSoft = Color(0xFFFDE8E8);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSoft = Color(0xFFE7F0FE);
}

/// Brand gradients
class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9345), Color(0xFFFF6A2B)],
  );

  static const LinearGradient navy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF272B52), Color(0xFF171A35)],
  );
}

/// Soft elevation
class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF1E2142).withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> button = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Corner radii
class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
}

/// Text styles
///
/// No fontFamily is set here on purpose: the global Poppins
/// textTheme (see main.dart) is inherited automatically.
class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13.5,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11.5,
    color: AppColors.textSecondary,
  );
}

/// Spacing constants
class AppSpacing {
  static const EdgeInsets screenPadding = EdgeInsets.all(20.0);
  static const SizedBox smallGap = SizedBox(height: 10);
  static const SizedBox mediumGap = SizedBox(height: 20);
  static const SizedBox largeGap = SizedBox(height: 32);
}

/// Button styles
class AppButtonStyles {
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
  );

  static ButtonStyle navyButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.navy,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
  );

  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textPrimary,
    side: BorderSide(color: Colors.grey.shade300),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
  );
}

/// Shared component decorations
class AppDecorations {
  /// Standard filled input used across all forms.
  static InputDecoration input({
    String? hint,
    String? label,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.inputFill,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1.4),
      ),
    );
  }

  /// White rounded card used for lists and detail blocks.
  static BoxDecoration card = BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    boxShadow: AppShadows.card,
  );
}

/// Small status chip (PENDING / APPROVED / REJECTED / IN REVIEW / RESOLVED)
/// used by booking history, damage history and the admin lists.
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    late final Color fg;
    late final Color bg;

    switch (s) {
      case "approved":
      case "resolved":
        fg = AppColors.success;
        bg = AppColors.successSoft;
        break;
      case "rejected":
        fg = AppColors.error;
        bg = AppColors.errorSoft;
        break;
      case "in review":
        fg = AppColors.info;
        bg = AppColors.infoSoft;
        break;
      default: // pending
        fg = AppColors.warning;
        bg = AppColors.warningSoft;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
