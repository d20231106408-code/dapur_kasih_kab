import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../styles.dart';
import '../widgets/gradient_button.dart';

/// Lets a student edit the details of a booking that is still Pending.
/// The slot/date/time cannot change here — to move a booking the student
/// cancels it and books another slot, which keeps availability accurate.
class UpdateBookingPage extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> booking;

  const UpdateBookingPage({
    super.key,
    required this.bookingId,
    required this.booking,
  });

  @override
  State<UpdateBookingPage> createState() => _UpdateBookingPageState();
}

class _UpdateBookingPageState extends State<UpdateBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late final TextEditingController _purposeController;
  late final TextEditingController _membersController;

  static const int _minUsers = 4;
  static const int _maxUsers = 8;
  late int _totalUsers;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _purposeController =
        TextEditingController(text: widget.booking["purpose"] ?? "");
    _membersController =
        TextEditingController(text: widget.booking["members"] ?? "");
    final int initial = (widget.booking["totalUsers"] as int?) ?? _minUsers;
    _totalUsers = initial.clamp(_minUsers, _maxUsers);
  }

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

  // ---------------------------------------------------------
  // UPDATE LOGIC (unchanged)
  // ---------------------------------------------------------
  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _firestoreService.updateBooking(
        widget.bookingId,
        purpose: _purposeController.text.trim(),
        members: _membersController.text.trim(),
        totalUsers: _totalUsers,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking updated successfully!"),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update booking: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Update Booking", style: AppTextStyles.heading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // --- Locked session details ---
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppGradients.navy,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Date",
                            style: TextStyle(
                                color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          widget.booking["date"] ?? "-",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 34,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Time",
                            style: TextStyle(
                                color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          widget.booking["time"] ?? "-",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.mediumGap,

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
                return null;
              },
            ),
            AppSpacing.mediumGap,

            const Text("Total Number of Users",
                style: AppTextStyles.subheading),
            const SizedBox(height: 4),
            const Text("Min. $_minUsers & Max. $_maxUsers",
                style: AppTextStyles.caption),
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

            GradientButton(
              label: "Save Changes",
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _saveBooking,
            ),
          ],
        ),
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
