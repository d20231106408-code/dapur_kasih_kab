import 'package:flutter/material.dart';
import '../styles.dart';
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

  const BookingPage({
    Key? key,
    required this.slot,
    required this.date,
  }) : super(key: key);

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("CONFIRM YOUR SESSION", style: AppTextStyles.heading),
            Text("BOOK THE DATE NOW!", style: AppTextStyles.body),
            AppSpacing.mediumGap,

            // Booking details card
            Center(
              child: Container(
                width: 300,
                child: Card(
                  color: Colors.orange.shade50,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date: ${date.toLocal().toString().split(' ')[0]}",
                            style: AppTextStyles.subheading),
                        AppSpacing.smallGap,
                        Text("Time: ${slot["time"]}",
                            style: AppTextStyles.subheading),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.mediumGap,

            // Booking form
            BookingForm(
              onSubmit: (purpose, members, totalUsers) {
                // buat objek Booking baru
                final newBooking = Booking(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  date: date.toIso8601String().split("T")[0],
                  time: slot["time"] ?? "",
                  purpose: purpose,
                  members: members,
                  totalUsers: totalUsers,
                  status: "pending",
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Booking saved successfully!")),
                );

                // pass booking baru ke BookingHistoryScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingHistoryScreen(
                      initialBookings: [newBooking],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
