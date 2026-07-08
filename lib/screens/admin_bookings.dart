import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../styles.dart';

/// Admin view of every booking, with Approve / Reject actions.
class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  // ---------------------------------------------------------
  // STATUS UPDATE LOGIC (unchanged) — only one Approved booking
  // per slot per date.
  // ---------------------------------------------------------
  Future<void> _setStatus(
    BuildContext context,
    String docId,
    String status,
    Map<String, dynamic> booking,
  ) async {
    try {
      if (status == "Approved") {
        final sameSlot = await FirebaseFirestore.instance
            .collection("bookings")
            .where("date", isEqualTo: booking["date"])
            .where("slotId", isEqualTo: booking["slotId"])
            .get();

        final bool alreadyApproved = sameSlot.docs.any((doc) =>
            doc.id != docId &&
            ((doc.data()["status"] as String?) ?? "").toLowerCase() ==
                "approved");

        if (alreadyApproved) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Another booking is already approved for this slot.",
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(docId)
          .update({"status": status});
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking $status."),
          backgroundColor:
              status == "Approved" ? AppColors.success : AppColors.error,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update booking: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("bookings").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading bookings: ${snapshot.error}",
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Newest bookings first (client-side sort avoids composite indexes).
        final bookings = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aTime =
                (a.data() as Map<String, dynamic>)["createdAt"] as Timestamp?;
            final bTime =
                (b.data() as Map<String, dynamic>)["createdAt"] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

        if (bookings.isEmpty) {
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
                  child: const Icon(Icons.event_note_rounded,
                      size: 48, color: AppColors.primary),
                ),
                AppSpacing.mediumGap,
                const Text("No bookings yet", style: AppTextStyles.heading),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index].data() as Map<String, dynamic>;
            final docId = bookings[index].id;
            final String status = (booking["status"] as String?) ?? "Pending";
            final bool isPending = status.toLowerCase() == "pending";

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: AppDecorations.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: date | time + status chip
                  Row(
                    children: [
                      const Icon(Icons.event_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${booking["date"] ?? "-"}  •  ${booking["time"] ?? "-"}",
                          style: AppTextStyles.subheading,
                        ),
                      ),
                      StatusChip(status: status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 12),

                  _AdminDetailRow(
                      icon: Icons.edit_note_rounded,
                      label: "Purpose",
                      value: "${booking["purpose"] ?? "-"}"),
                  _AdminDetailRow(
                      icon: Icons.group_outlined,
                      label: "Members",
                      value: "${booking["members"] ?? "-"}"),
                  _AdminDetailRow(
                      icon: Icons.tag_rounded,
                      label: "Total Users",
                      value: "${booking["totalUsers"] ?? "-"}"),

                  if (isPending) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text(
                              "Approve",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            onPressed: () => _setStatus(
                                context, docId, "Approved", booking),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text(
                              "Reject",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            onPressed: () => _setStatus(
                                context, docId, "Rejected", booking),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Compact icon + label + value row inside an admin booking card.
class _AdminDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AdminDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text("$label: ", style: AppTextStyles.body),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
