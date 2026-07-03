import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../styles.dart';
import '../widgets/booking_list.dart';
import '../welcome_page.dart';
import 'report_damage.dart';
import 'booking.dart';
import 'profile.dart';
import 'booking_history.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generate slots dynamically from 8 AM to 11 PM
  final List<Map<String, String>> slots = List.generate(15, (index) {
    final startHour = 8 + index;
    final endHour = startHour + 1;
    return {
      "slotId": "$startHour", // unique ID for Firestore
      "title": "Slot ${index + 1}",
      "time": "${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00",
    };
  });

  String activeButton = "Slots";
  int _selectedIndex = 0;

  // ✅ Default to today’s date
  DateTime selectedDate = DateTime.now();

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
      (route) => false,
    );
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BookingHistoryPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
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
        title: Text("DapurKasih", style: AppTextStyles.heading),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
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
            // Top buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeButton == "Slots"
                        ? AppColors.primary
                        : Colors.grey.shade400,
                  ),
                  onPressed: () {
                    setState(() {
                      activeButton = "Slots";
                    });
                  },
                  child: Text("Slots", style: AppTextStyles.button),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeButton == "Report Damage"
                        ? AppColors.primary
                        : Colors.grey.shade400,
                  ),
                  onPressed: () async {
                    setState(() {
                      activeButton = "Report Damage";
                    });
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDamagePage(),
                      ),
                    );
                    setState(() {
                      activeButton = "Slots";
                    });
                  },
                  child: Text("Report Damage", style: AppTextStyles.button),
                ),
              ],
            ),
            AppSpacing.mediumGap,

            // Date picker row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Selected: ${selectedDate.toLocal().toString().split(' ')[0]}",
                  style: AppTextStyles.subheading,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () => _pickDate(context),
                  child: Text("Pick Date", style: AppTextStyles.button),
                ),
              ],
            ),
            AppSpacing.mediumGap,

            // Slot list with availability
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection("bookings")
                    .where("date",
                        isEqualTo: selectedDate.toIso8601String().split("T")[0])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final bookedSlots = snapshot.data!.docs
                      .map((doc) =>
                          (doc.data() as Map<String, dynamic>)["slotId"])
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
                        // ✅ Navigate to BookingPage after saving
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
                          SnackBar(content: Text("This slot is already booked")),
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
        selectedItemColor: AppColors.primary,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
