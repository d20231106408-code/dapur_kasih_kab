import 'package:flutter/material.dart';
import '../styles.dart';
import 'booking.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'update_booking.dart'; // page update

class BookingHistoryScreen extends StatefulWidget {
  final List<Booking> initialBookings;

  const BookingHistoryScreen({super.key, this.initialBookings = const []});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  int _selectedIndex = 1;
  late List<Booking> bookings;

  @override
  void initState() {
    super.initState();
    // mula dengan senarai booking yang dihantar dari BookingPage
    bookings = List.from(widget.initialBookings);
  }

  // 🔧 Delete Booking
  void deleteBooking(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Are you sure you want to DELETE?"),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const Center(child: CircularProgressIndicator()),
              );

              await Future.delayed(const Duration(seconds: 1));

              setState(() {
                bookings.removeWhere((b) => b.id == id);
              });

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Booking deleted successfully!")),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("BOOKING HISTORY"),
        backgroundColor: AppColors.primary,
      ),
      body: bookings.isEmpty
          ? const Center(child: Text("No bookings yet"))
          : ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: ${booking.date}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("Time: ${booking.time}"),
                            Text("Purpose: ${booking.purpose}"),
                            Text("Members: ${booking.members}"),
                            Text("Total Users: ${booking.totalUsers}"),
                            const SizedBox(height: 8),
                            if (booking.status == 'pending')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                    onPressed: () async {
                                      final updatedBooking = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => UpdateBookingPage(booking: booking),
                                        ),
                                      );

                                      if (updatedBooking != null) {
                                        setState(() {
                                          bookings[index] = updatedBooking;
                                        });
                                      }
                                    },
                                    child: const Text("Update"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => deleteBooking(booking.id),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: booking.status == 'approved'
                                ? Colors.green
                                : booking.status == 'rejected'
                                    ? Colors.red
                                    : Colors.yellow.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            booking.status.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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