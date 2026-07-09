import 'package:flutter/material.dart';
import '../styles.dart';
import '../utils/slots.dart';
import '../widgets/booking_form.dart';
import 'booking_history.dart';

class Booking {
  final String id;
  String date;
  String time;
  String purpose;
  String members;
  int totalUsers;
  String status; // pending, approved, rejected

  Booking({
    required this.id,
    required this.date,
    required this.time,
    required this.purpose,
    required this.members,
    required this.totalUsers,
    required this.status,
  });
}

class BookingPage extends StatelessWidget {
  final Map<String, String> slot;
  final DateTime date;

  const BookingPage({super.key, required this.slot, required this.date});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore db = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- NAVY HERO ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        'DapurKasih',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // balances the back button
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'CONFIRM YOUR SESSION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'BOOK THE DATE NOW! ✨',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Date & time chips
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _HeroDetail(
                            icon: Icons.event_rounded,
                            label: 'Date',
                            value: date.toLocal().toString().split(' ')[0],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 34,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _HeroDetail(
                            icon: Icons.schedule_rounded,
                            label: 'Time',
                            value: slot["time"] ?? "-",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ---------------- WHITE FORM SHEET ----------------
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xl),
                    topRight: Radius.circular(AppRadius.xl),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: BookingForm(
                    // -------- BOOKING LOGIC (unchanged) --------
                    onSubmit: (purpose, members, totalUsers) async {
                      try {
                        // Guard against double booking: re-check that nobody
                        // has taken this slot while the form was being filled.
                        final existing = await db
                            .collection("bookings")
                            .where(
                              "date",
                              isEqualTo:
                                  date.toIso8601String().split("T")[0],
                            )
                            .where("slotId", isEqualTo: slot["slotId"])
                            .get();

                        final bool alreadyTaken = existing.docs.any(
                          (doc) => bookingBlocksSlot(
                            (doc.data())["status"] as String?,
                          ),
                        );

                        if (alreadyTaken) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Sorry, this slot has just been booked by someone else.",
                              ),
                            ),
                          );
                          return;
                        }

                        await db.collection("bookings").add({
                          "slotId": slot["slotId"],
                          "time": slot["time"],
                          "date": date.toIso8601String().split("T")[0],
                          "purpose": purpose,
                          "members": members,
                          "totalUsers": totalUsers,
                          "userId": auth.currentUser?.uid,
                          "status": "Pending", // awaiting admin approval
                          "createdAt": FieldValue.serverTimestamp(),
                        });

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Booking saved successfully!"),
                            backgroundColor: AppColors.success,
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookingHistoryPage(),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Error saving booking: $e")),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon + label + value block inside the navy hero card.
class _HeroDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
