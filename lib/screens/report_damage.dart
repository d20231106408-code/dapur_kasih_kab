import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../styles.dart';
import '../utils/slots.dart';
import '../widgets/gradient_button.dart';
import 'dashboard.dart';
import 'damage_history.dart';
import 'report_success.dart';

class ReportDamagePage extends StatefulWidget {
  const ReportDamagePage({super.key});

  @override
  State<ReportDamagePage> createState() => _ReportDamagePageState();
}

class _ReportDamagePageState extends State<ReportDamagePage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedItem;
  String _urgency = "Low";

  final List<String> _items = [
    "Stove",
    "Sink",
    "Microwave",
    "Refrigerator",
    "Others",
  ];

  bool _isLoading = false;

  // Kitchen slots (8 AM - 11 PM) shared with the dashboard.
  final List<Map<String, String>> slots = kitchenSlots;

  String? _selectedSlot;

  // Date the damage was noticed (report requires DateReport).
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (slots.isNotEmpty) {
      _selectedSlot = slots.first["time"];
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      // Reports are about things already noticed — allow up to 30 days
      // back, but never a future date.
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month - 1];
  }

  // ---------------------------------------------------------
  // SUBMIT LOGIC (unchanged) — now ends on the success screen
  // ---------------------------------------------------------
  Future<void> _submitReport() async {
    if (_selectedItem == null ||
        _descriptionController.text.trim().isEmpty ||
        _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _db.collection("damage_reports").add({
        "userId": _auth.currentUser?.uid,
        "date": _selectedDate.toIso8601String().split("T")[0],
        "slot": _selectedSlot,
        "item": _selectedItem,
        "description": _descriptionController.text.trim(),
        "urgency": _urgency,
        "status": "Pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReportSuccessPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to submit report: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Colored urgency selector chip (Low / Medium / High)
  Widget _urgencyChip(String label, Color color, Color softColor) {
    final bool selected = _urgency == label;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () => setState(() => _urgency = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? color : softColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selected ? color : Colors.transparent,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Report Damage", style: AppTextStyles.heading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'My Reports',
            icon: const Icon(Icons.history_rounded,
                color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DamageHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Help us keep the kitchen safe and functional for everyone.",
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ),

            AppSpacing.mediumGap,

            const Text("Date", style: AppTextStyles.subheading),
            AppSpacing.smallGap,
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_rounded,
                        color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      "${_selectedDate.day.toString().padLeft(2, '0')} "
                      "${_monthName(_selectedDate.month)} ${_selectedDate.year}",
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),

            AppSpacing.mediumGap,

            const Text("Time", style: AppTextStyles.subheading),
            AppSpacing.smallGap,
            DropdownButtonFormField<String>(
              initialValue: _selectedSlot,
              borderRadius: BorderRadius.circular(AppRadius.md),
              decoration: AppDecorations.input(
                prefixIcon: const Icon(Icons.schedule_rounded,
                    color: AppColors.textSecondary, size: 20),
              ),
              items: slots.map((slot) {
                return DropdownMenuItem<String>(
                  value: slot["time"],
                  child: Text(slot["time"]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSlot = value;
                });
              },
            ),

            AppSpacing.mediumGap,

            const Text("Affected Item / Area", style: AppTextStyles.subheading),
            AppSpacing.smallGap,
            DropdownButtonFormField<String>(
              initialValue: _selectedItem,
              borderRadius: BorderRadius.circular(AppRadius.md),
              decoration: AppDecorations.input(
                hint: "-- Select Item --",
                prefixIcon: const Icon(Icons.kitchen_rounded,
                    color: AppColors.textSecondary, size: 20),
              ),
              items: _items.map((item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedItem = value;
                });
              },
            ),

            AppSpacing.mediumGap,

            const Text("Detail Description", style: AppTextStyles.subheading),
            AppSpacing.smallGap,
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: AppDecorations.input(
                hint:
                    "Please provide details (e.g. Stove #3 burner is not igniting)...",
              ),
            ),

            AppSpacing.mediumGap,

            const Text("Urgency Level", style: AppTextStyles.subheading),
            AppSpacing.smallGap,
            Row(
              children: [
                _urgencyChip("Low", AppColors.success, AppColors.successSoft),
                _urgencyChip(
                    "Medium", AppColors.warning, AppColors.warningSoft),
                _urgencyChip("High", AppColors.error, AppColors.errorSoft),
              ],
            ),

            AppSpacing.mediumGap,

            GradientButton(
              label: "Submit",
              icon: Icons.send_rounded,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _submitReport,
            ),

            AppSpacing.smallGap,

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: AppButtonStyles.outlinedButton,
                icon: const Icon(Icons.home_outlined, size: 19),
                label: const Text(
                  "Return Home",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
