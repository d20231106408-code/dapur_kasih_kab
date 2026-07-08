import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../styles.dart';
import '../utils/slots.dart';
import '../widgets/booking_list.dart';
import '../welcome_page.dart';
import 'report_damage.dart';
import 'booking.dart';
import 'profile.dart';
import 'booking_history.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Kitchen slots (8 AM - 11 PM) shared with the other screens.
  final List<Map<String, String>> slots = kitchenSlots;

  final int _selectedIndex = 0;

  // Default to today's date
  DateTime selectedDate = DateTime.now();

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  }

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return; // already on this tab

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookingHistoryPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.restaurant_menu,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'DapurKasih',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.textPrimary),
            tooltip: 'Log Out',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Quick action cards ---
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    label: 'SLOTS',
                    icon: Icons.calendar_month_rounded,
                    highlighted: true,
                    onTap: () {}, // already on the slots view
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ActionCard(
                    label: 'REPORT DAMAGE',
                    icon: Icons.build_circle_outlined,
                    highlighted: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportDamagePage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            AppSpacing.mediumGap,

            // --- Check availability + date picker ---
            const Text('Check Availability', style: AppTextStyles.heading),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      "${selectedDate.day.toString().padLeft(2, '0')} "
                      "${_monthName(selectedDate.month)} ${selectedDate.year}",
                      style: AppTextStyles.subheading,
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            AppSpacing.mediumGap,

            // --- Slot list with availability (logic unchanged) ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection("bookings")
                    .where(
                      "date",
                      isEqualTo: selectedDate.toIso8601String().split("T")[0],
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Rejected/cancelled bookings free their slot again.
                  final bookedSlots = snapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .where(
                        (data) =>
                            bookingBlocksSlot(data["status"] as String?),
                      )
                      .map((data) => data["slotId"])
                      .toSet();

                  final updatedSlots = slots.map((slot) {
                    final isBooked = bookedSlots.contains(slot["slotId"]);
                    return {
                      ...slot,
                      "status": isBooked ? "Booked" : "Available",
                    };
                  }).toList();

                  return BookingList(
                    slots: updatedSlots,
                    onBook: (slot) async {
                      if (slot["status"] == "Available") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingPage(
                              slot: slot,
                              date: selectedDate,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("This slot is already booked"),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
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

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month - 1];
  }
}

/// Large tappable quick-action card at the top of the dashboard.
class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool highlighted;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          gradient: highlighted ? AppGradients.primary : null,
          color: highlighted ? null : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: highlighted ? AppShadows.button : AppShadows.card,
          border: highlighted
              ? null
              : Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: highlighted ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: highlighted ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
