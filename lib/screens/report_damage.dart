import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../styles.dart';
import 'dashboard.dart';

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

  final List<Map<String, String>> slots = List.generate(15, (index) {
    final startHour = 8 + index;
    final endHour = startHour + 1;

    return {
      "slotId": "$startHour",
      "time":
          "${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00",
    };
  });

  String? _selectedSlot;

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
        "slot": _selectedSlot,
        "item": _selectedItem,
        "description": _descriptionController.text.trim(),
        "urgency": _urgency,
        "status": "Pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted successfully.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
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

  Widget _urgencyChip(String label) {
    final bool selected = _urgency == label;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Center(child: Text(label)),
          selected: selected,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) {
            setState(() {
              _urgency = label;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("DapurKasih", style: AppTextStyles.heading),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text("REPORT DAMAGE", style: AppTextStyles.heading)),

            AppSpacing.smallGap,

            Center(
              child: Text(
                "Help us keep the kitchen safe and functional for everyone.",
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ),

            AppSpacing.mediumGap,

            Text("Time", style: AppTextStyles.subheading),

            AppSpacing.smallGap,

            DropdownButtonFormField<String>(
              initialValue: _selectedSlot,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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

            Text("Affected Item / Area", style: AppTextStyles.subheading),

            AppSpacing.smallGap,

            DropdownButtonFormField<String>(
              initialValue: _selectedItem,
              decoration: InputDecoration(
                hintText: "-- Select Item --",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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

            Text("Detail Description", style: AppTextStyles.subheading),

            AppSpacing.smallGap,

            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    "Please provide details (e.g. Stove #3 burner is not igniting)...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            AppSpacing.mediumGap,

            Text("Urgency Level", style: AppTextStyles.subheading),

            AppSpacing.smallGap,

            Row(
              children: [
                _urgencyChip("Low"),
                _urgencyChip("Medium"),
                _urgencyChip("High"),
              ],
            ),

            AppSpacing.mediumGap,
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: AppButtonStyles.primaryButton,
                onPressed: _isLoading ? null : _submitReport,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("SUBMIT", style: AppTextStyles.button),
              ),
            ),

            AppSpacing.smallGap,

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardPage()),
                  );
                },
                child: const Text("Return Home"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
