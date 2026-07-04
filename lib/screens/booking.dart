import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../styles.dart';
import '../widgets/booking_form.dart';
import 'booking_history.dart';

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
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("DapurKasih", style: AppTextStyles.heading),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // ✅ center headers
          children: [
            // Header texts
            Text("CONFIRM YOUR SESSION", style: AppTextStyles.heading),
            Text("BOOK THE DATE NOW!", style: AppTextStyles.body),
            AppSpacing.mediumGap,

            // Booking details card centered
            Center(
              child: Container(
                width: 300, // fixed width for neat box
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
              onSubmit: (purpose, members, totalUsers) async {
                try {
                  await _db.collection("bookings").add({
                    "slotId": slot["slotId"],
                    "time": slot["time"],
                    "date": date.toIso8601String().split("T")[0],
                    "purpose": purpose,
                    "members": members,
                    "totalUsers": totalUsers,
                    "userId": _auth.currentUser?.uid,
                    "createdAt": FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Booking saved successfully!")),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingHistoryPage(),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error saving booking: $e")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
