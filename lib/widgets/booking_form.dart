import 'package:flutter/material.dart';
import '../styles.dart';

class BookingForm extends StatefulWidget {
  final void Function(String purpose, String members, int totalUsers)? onSubmit;

  const BookingForm({super.key, this.onSubmit});

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();
  final TextEditingController _totalUsersController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purpose of Booking
          Text("Purpose of Booking", style: AppTextStyles.subheading),
          AppSpacing.smallGap,
          TextFormField(
            controller: _purposeController,
            decoration: InputDecoration(
              hintText: "e.g., Group Dinner / Birthday Prep",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Purpose of booking is required";
              }
              return null;
            },
          ),
          AppSpacing.mediumGap,

          // Group Member Names
          Text("Group Member Names", style: AppTextStyles.subheading),
          AppSpacing.smallGap,
          TextFormField(
            controller: _membersController,
            decoration: InputDecoration(
              hintText: "e.g., Aaron, Adam, ...",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Group member names are required";
              }

              // Split names by comma
              final names = value
                  .split(",")
                  .map((n) => n.trim())
                  .where((n) => n.isNotEmpty)
                  .toList();
              final totalUsers = int.tryParse(_totalUsersController.text);

              if (totalUsers != null && names.length != totalUsers) {
                return "Number of names must equal Total Users ($totalUsers)";
              }

              return null;
            },
          ),
          AppSpacing.mediumGap,

          // Total Number of Users
          Text("Total Number of Users", style: AppTextStyles.subheading),
          AppSpacing.smallGap,
          TextFormField(
            controller: _totalUsersController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Min. 5 & Max. 8",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Total number of users is required";
              }
              final number = int.tryParse(value);
              if (number == null) {
                return "Please enter a valid number";
              }
              if (number < 5 || number > 8) {
                return "Number of users must be between 5 and 8";
              }
              return null;
            },
          ),
          AppSpacing.mediumGap,

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppButtonStyles.primaryButton,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit?.call(
                    _purposeController.text,
                    _membersController.text,
                    int.parse(_totalUsersController.text),
                  );
                }
              },
              child: Text("Confirm Reservation", style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }
}
