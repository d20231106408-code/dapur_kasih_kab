import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../styles.dart';
import '../welcome_page.dart';
import 'admin_bookings.dart';
import 'admin_damage.dart';

/// Admin home: manage bookings (approve/reject) and damage reports.
///
/// SECURITY: before showing anything, this page re-verifies that the
/// signed-in account has role == "admin" in Firestore. Normal users
/// (or signed-out visitors) are always redirected away, so admin pages
/// can never be reached by navigation tricks.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  // null = still verifying, true = admin, false = denied
  bool? _authorized;

  final List<Widget> _pages = const [
    AdminBookingsPage(),
    AdminDamagePage(),
  ];

  @override
  void initState() {
    super.initState();
    _verifyAdminAccess();
  }

  Future<void> _verifyAdminAccess() async {
    final user = FirebaseAuth.instance.currentUser;

    String role = "";
    if (user != null) {
      try {
        role = await FirestoreService().getUserRole(user.uid);
      } catch (_) {
        role = "";
      }
    }

    if (!mounted) return;

    if (role != "admin") {
      setState(() => _authorized = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Access denied. Admin account required."),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
        (route) => false,
      );
    } else {
      setState(() => _authorized = true);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Block all admin content until the role check completes.
    if (_authorized != true) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppGradients.navy,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.admin_panel_settings_outlined,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.textPrimary),
            tooltip: 'Log Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.event_note_rounded), label: "Bookings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.build_circle_outlined), label: "Damage"),
        ],
      ),
    );
  }
}
