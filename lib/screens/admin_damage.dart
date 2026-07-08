import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDamagePage extends StatelessWidget {
  const AdminDamagePage({super.key});
  @override
  Widget build(BuildContext context) {
    final _db = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection("damageReports").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final reports = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index].data() as Map<String, dynamic>;
            final docId = reports[index].id;

            return Card(
              child: ListTile(
                title: Text("Report: ${report["description"]}"),
                subtitle: Text("Status: ${report["status"]}"),
                trailing: DropdownButton<String>(
                  value: report["status"],
                  items: ["pending", "in review", "resolved"]
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (newStatus) {
                    _db.collection("damageReports").doc(docId).update({"status": newStatus});
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
