import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../styles.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'update_booking.dart';

/// Shows every booking made by the logged-in user, with Update /
/// Cancel actions while the booking is still Pending.
class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final int _selectedIndex = 1;

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  // ---------------------------------------------------------
  // CANCEL LOGIC (unchanged) with a themed confirmation dialog
  // ---------------------------------------------------------
  Future<void> _cancelBooking(String bookingId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: AppColors.warningSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.warning_amber_rounded,
              color: AppColors.warning, size: 30),
        ),
        title: const Text(
          "Cancel Booking?",
          textAlign: TextAlign.center,
          style: AppTextStyles.heading,
        ),
        content: const Text(
          "The slot will become available to other students.",
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            style: AppButtonStyles.outlinedButton,
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Keep Booking"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestoreService.cancelBooking(bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking cancelled successfully."),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel booking: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Booking History", style: AppTextStyles.heading),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getMyBookings(),
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
                    child: const Icon(Icons.event_busy_rounded,
                        size: 48, color: AppColors.primary),
                  ),
                  AppSpacing.mediumGap,
                  const Text("No bookings yet",
                      style: AppTextStyles.heading),
                  AppSpacing.smallGap,
                  const Text(
                    "Book a kitchen slot from the Home page.",
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
              final doc = docs[index];
              final booking = doc.data() as Map<String, dynamic>;
              // Legacy bookings without a status are still awaiting approval.
              final String status =
                  (booking["status"] as String?) ?? "Pending";
              final bool isPending = status.toLowerCase() == "pending";
              final bool isApproved = status.toLowerCase() == "approved";

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: AppDecorations.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: date + status chip
                    Row(
                      children: [
                        const Icon(Icons.event_rounded,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking["date"] ?? "-",
                            style: AppTextStyles.subheading,
                          ),
                        ),
                        StatusChip(status: status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade100, height: 1),
                    const SizedBox(height: 12),

                    _DetailRow(
                        icon: Icons.schedule_rounded,
                        label: "Time",
                        value: booking["time"] ?? "-"),
                    _DetailRow(
                        icon: Icons.edit_note_rounded,
                        label: "Purpose",
                        value: booking["purpose"] ?? "-"),
                    _DetailRow(
                        icon: Icons.group_outlined,
                        label: "Members",
                        value: booking["members"] ?? "-"),
                    _DetailRow(
                        icon: Icons.tag_rounded,
                        label: "Total Users",
                        value: "${booking["totalUsers"] ?? "-"}"),

                    if (isPending || isApproved) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (isPending)
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                      color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                  ),
                                ),
                                icon: const Icon(Icons.edit_rounded,
                                    size: 17),
                                label: const Text(
                                  "Update",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateBookingPage(
                                        bookingId: doc.id,
                                        booking: booking,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          if (isPending) const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side:
                                    const BorderSide(color: AppColors.error),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                              icon: const Icon(Icons.close_rounded,
                                  size: 17),
                              label: const Text(
                                "Cancel",
                                style:
                                    TextStyle(fontWeight: FontWeight.w700),
                              ),
                              onPressed: () => _cancelBooking(doc.id),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_note_rounded), label: "Bookings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }
}

/// Compact icon + label + value row inside a booking card.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
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
