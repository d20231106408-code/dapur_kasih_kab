import 'package:flutter/material.dart';
import '../styles.dart';

class BookingList extends StatelessWidget {
  final List<Map<String, String>> slots;
  final Function(Map<String, String>) onBook;

  const BookingList({super.key, required this.slots, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final status = slot["status"] ?? "Available";
        final bool booked = status == "Booked";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              // Time + availability chip
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot["time"] ?? "",
                      style: AppTextStyles.subheading,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: booked
                            ? AppColors.errorSoft
                            : AppColors.successSoft,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: booked
                                  ? AppColors.error
                                  : AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            booked ? "Full" : "Available",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: booked
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Book button
              booked
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "Booked",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () => onBook(slot),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: AppShadows.button,
                        ),
                        child: const Text(
                          "Book Now",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
