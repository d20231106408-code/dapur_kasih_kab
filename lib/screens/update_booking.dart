import 'package:flutter/material.dart';
import 'booking.dart';

class UpdateBookingPage extends StatefulWidget {
  final Booking booking;
  const UpdateBookingPage({super.key, required this.booking});

  @override
  State<UpdateBookingPage> createState() => _UpdateBookingPageState();
}

class _UpdateBookingPageState extends State<UpdateBookingPage> {
  late TextEditingController purposeController;
  late TextEditingController membersController;
  late TextEditingController totalController;

  @override
  void initState() {
    super.initState();
    purposeController = TextEditingController(text: widget.booking.purpose);
    membersController = TextEditingController(text: widget.booking.members);
    totalController = TextEditingController(text: widget.booking.totalUsers.toString());
  }

  @override
  void dispose() {
    purposeController.dispose();
    membersController.dispose();
    totalController.dispose();
    super.dispose();
  }

  void _saveBooking() {
    widget.booking.purpose = purposeController.text;
    widget.booking.members = membersController.text;
    widget.booking.totalUsers =
        int.tryParse(totalController.text) ?? widget.booking.totalUsers;

    Navigator.pop(context, widget.booking); // hantar balik ke BookingHistory
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Booking"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Date: ${widget.booking.date}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Time: ${widget.booking.time}"),
            const SizedBox(height: 16),

            TextField(
              controller: purposeController,
              decoration: const InputDecoration(labelText: "Purpose of Booking"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: membersController,
              decoration: const InputDecoration(labelText: "Group Member Names"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Total Number of Users"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _saveBooking,
              child: const Text("Save", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
