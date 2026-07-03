import 'package:flutter/material.dart';
import '../styles.dart';

class BookingList extends StatelessWidget {
  final List<Map<String, String>> slots;
  final Function(Map<String, String>) onBook;

  const BookingList({
    Key? key,
    required this.slots,
    required this.onBook,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final status = slot["status"] ?? "Available";

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(
              slot["time"] ?? "",
              style: AppTextStyles.subheading,
            ),
            subtitle: Text(
              status,
              style: TextStyle(
                color: status == "Booked" ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: status == "Booked"
                    ? Colors.grey
                    : AppColors.primary,
              ),
              onPressed: status == "Booked"
                  ? null
                  : () => onBook(slot),
              child: Text(
                status == "Booked" ? "Unavailable" : "Book",
                style: AppTextStyles.button,
              ),
            ),
          ),
        );
      },
    );
  }
}
