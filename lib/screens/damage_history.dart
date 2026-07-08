import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../styles.dart';

/// Shows every damage report submitted by the logged-in user.
class DamageHistoryPage extends StatelessWidget {
  const DamageHistoryPage({super.key});

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
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Damage Reports", style: AppTextStyles.heading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getMyDamageReports(),
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

          // Sort newest first on the client so no composite index is needed.
          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final aTime =
                  (a.data() as Map<String, dynamic>)["createdAt"] as Timestamp?;
              final bTime =
                  (b.data() as Map<String, dynamic>)["createdAt"] as Timestamp?;
              if (aTime == null || bTime == null) return 0;
              return bTime.compareTo(aTime);
            });

          if (docs.isEmpty) {
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
                  AppSpacing.smallGap,
                  const Text(
                    "Reports you submit will appear here.",
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppSpacing.screenPadding,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final report = docs[index].data() as Map<String, dynamic>;
              final String status = (report["status"] as String?) ?? "Pending";
              final String urgency = (report["urgency"] as String?) ?? "Low";
              final Timestamp? createdAt = report["createdAt"] as Timestamp?;
              final String dateText = createdAt != null
                  ? createdAt.toDate().toLocal().toString().split(' ')[0]
                  : "-";

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: AppDecorations.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
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
                        StatusChip(status: status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      report["description"] ?? "-",
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        // Urgency chip
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
                        const Spacer(),
                        const Icon(Icons.schedule_rounded,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text("${report["slot"] ?? "-"}",
                            style: AppTextStyles.caption),
                        const SizedBox(width: 12),
                        const Icon(Icons.event_rounded,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(dateText, style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
