import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../styles.dart';

/// Admin view of every damage report with a status dropdown
/// (Pending / In Review / Resolved).
class AdminDamagePage extends StatelessWidget {
  const AdminDamagePage({super.key});

  static const List<String> _statuses = ["Pending", "In Review", "Resolved"];

  /// Maps any legacy value (e.g. lowercase "pending") onto the
  /// canonical status list so the dropdown never crashes.
  String _normalizeStatus(String? raw) {
    if (raw == null) return "Pending";
    return _statuses.firstWhere(
      (s) => s.toLowerCase() == raw.toLowerCase(),
      orElse: () => "Pending",
    );
  }

  Color _urgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case "high":
        return AppColors.error;
      case "medium":
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  Color _urgencySoft(String urgency) {
    switch (urgency.toLowerCase()) {
      case "high":
        return AppColors.errorSoft;
      case "medium":
        return AppColors.warningSoft;
      default:
        return AppColors.successSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: db.collection("damage_reports").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading reports: ${snapshot.error}",
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Newest reports first (client-side sort avoids composite indexes).
        final reports = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aTime =
                (a.data() as Map<String, dynamic>)["createdAt"] as Timestamp?;
            final bTime =
                (b.data() as Map<String, dynamic>)["createdAt"] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.build_circle_outlined,
                      size: 48, color: AppColors.primary),
                ),
                AppSpacing.mediumGap,
                const Text("No damage reports yet",
                    style: AppTextStyles.heading),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index].data() as Map<String, dynamic>;
            final docId = reports[index].id;
            final String status =
                _normalizeStatus(report["status"] as String?);
            final String urgency = (report["urgency"] as String?) ?? "Low";

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: AppDecorations.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: item + urgency chip
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(Icons.kitchen_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          report["item"] ?? "Unknown item",
                          style: AppTextStyles.subheading,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _urgencySoft(urgency),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded,
                                size: 14, color: _urgencyColor(urgency)),
                            const SizedBox(width: 4),
                            Text(
                              urgency,
                              style: TextStyle(
                                color: _urgencyColor(urgency),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    report["description"] ?? "-",
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text("Slot: ${report["slot"] ?? "-"}",
                          style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 12),

                  // Status selector
                  Row(
                    children: [
                      const Text("Status", style: AppTextStyles.subheading),
                      const Spacer(),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: DropdownButton<String>(
                          value: status,
                          underline: const SizedBox.shrink(),
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textSecondary),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          items: _statuses
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ))
                              .toList(),
                          onChanged: (newStatus) async {
                            if (newStatus == null) return;
                            try {
                              await db
                                  .collection("damage_reports")
                                  .doc(docId)
                                  .update({"status": newStatus});
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Failed to update status: $e"),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
