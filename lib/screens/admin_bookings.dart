import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final _db = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection("bookings").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final bookings = snapshot.data!.docs;

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index].data() as Map<String, dynamic>;
            final docId = bookings[index].id;

            return Card(
              child: ListTile(
                title: Text("Purpose: ${booking["purpose"]}"),
                subtitle: Text("Status: ${booking["status"]}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () => _db.collection("bookings").doc(docId).update({"status": "approved"}),
                      child: const Text("Approve"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => _db.collection("bookings").doc(docId).update({"status": "rejected"}),
                      child: const Text("Reject"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
