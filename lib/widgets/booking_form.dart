import 'package:flutter/material.dart';
import '../styles.dart';
import 'gradient_button.dart';

class BookingForm extends StatefulWidget {
  final void Function(String purpose, String members, int totalUsers)? onSubmit;

  const BookingForm({super.key, this.onSubmit});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();

  // Report business rule: 4-8 users per booking.
  static const int _minUsers = 4;
  static const int _maxUsers = 8;
  int _totalUsers = 5;

  @override
  void dispose() {
    _purposeController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  void _changeTotal(int delta) {
    setState(() {
      _totalUsers = (_totalUsers + delta).clamp(_minUsers, _maxUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Purpose of Booking ---
          const Text("Purpose of Booking", style: AppTextStyles.subheading),
          AppSpacing.smallGap,
          TextFormField(
            controller: _purposeController,
            decoration: AppDecorations.input(
              hint: "e.g., Group Dinner / Birthday Prep",
              prefixIcon: const Icon(Icons.edit_note_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Purpose of booking is required";
              }
              return null;
            },
          ),
          AppSpacing.mediumGap,

          // --- Group Member Names ---
          const Text("Group Member Names", style: AppTextStyles.subheading),
          AppSpacing.smallGap,
          TextFormField(
            controller: _membersController,
            decoration: AppDecorations.input(
              hint: "e.g., Aaron, Adam, ...",
              prefixIcon: const Icon(Icons.group_outlined,
                  color: AppColors.textSecondary, size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Group member names are required";
              }

              // Split names by comma and match against the selected total.
              final names = value
                  .split(",")
                  .map((n) => n.trim())
                  .where((n) => n.isNotEmpty)
                  .toList();

              if (names.length != _totalUsers) {
                return "Number of names must equal Total Users ($_totalUsers)";
              }

              return null;
            },
          ),
          AppSpacing.mediumGap,

          // --- Total Number of Users (stepper) ---
          const Text("Total Number of Users", style: AppTextStyles.subheading),
          const SizedBox(height: 4),
          Text(
            "Min. $_minUsers & Max. $_maxUsers",
            style: AppTextStyles.caption,
          ),
          AppSpacing.smallGap,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StepperButton(
                  icon: Icons.remove_rounded,
                  enabled: _totalUsers > _minUsers,
                  onTap: () => _changeTotal(-1),
                ),
                Text(
                  "$_totalUsers",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                _StepperButton(
                  icon: Icons.add_rounded,
                  enabled: _totalUsers < _maxUsers,
                  onTap: () => _changeTotal(1),
                ),
              ],
            ),
          ),
          AppSpacing.mediumGap,

          // --- Confirm button ---
          GradientButton(
            label: "Confirm Reservation",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit?.call(
                  _purposeController.text,
                  _membersController.text,
                  _totalUsers,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Round +/- button used by the total-users stepper.
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: enabled ? AppColors.primarySoft : AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
