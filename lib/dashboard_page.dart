import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- PLACEHOLDER PAGE FOR LOGOUT NAVIGATION ---
import 'welcome_page.dart'; // Or login_page.dart, wherever you want users to go after logging out

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Get the currently logged-in user from Firebase
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // ---------------------------------------------------------
  // FIREBASE LOGOUT LOGIC
  // ---------------------------------------------------------
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    
    // Check if the widget is still mounted before navigating
    if (mounted) {
      // Navigate back to the Welcome/Login page and clear the navigation history
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()), // Change this if needed
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the user's display name or use a default if it's not set
    String displayName = currentUser?.displayName ?? currentUser?.email ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Light grey background for contrast
      
      // ---------------------------------------------------------
      // APP BAR (Top Navigation)
      // ---------------------------------------------------------
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7A22), // Your custom orange
        elevation: 0, // Removes the shadow under the app bar
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log Out',
            onPressed: _signOut,
          ),
        ],
      ),

      // ---------------------------------------------------------
      // BODY (Main Content)
      // ---------------------------------------------------------
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER SECTION ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25.0),
            decoration: const BoxDecoration(
              color: Color(0xFFFF7A22),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome back,",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  displayName, // Displays the Firebase user's name or email
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- GRID MENU SECTION ---
          // Expanded forces the grid to take up the remaining screen space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.count(
                crossAxisCount: 2, // 2 columns
                crossAxisSpacing: 15, // Space between columns
                mainAxisSpacing: 15, // Space between rows
                children: [
                  // Dummy Feature 1
                  _buildDashboardCard(
                    context,
                    title: "My Profile",
                    icon: Icons.person,
                    color: Colors.blue,
                    onTap: () {
                      // TODO: Navigate to profile page
                      _showDummySnackbar(context, "Profile clicked");
                    },
                  ),

                  // Dummy Feature 2
                  _buildDashboardCard(
                    context,
                    title: "Saved Recipes",
                    icon: Icons.favorite,
                    color: Colors.red,
                    onTap: () {
                      // TODO: Navigate to recipes page
                      _showDummySnackbar(context, "Recipes clicked");
                    },
                  ),

                  // Dummy Feature 3
                  _buildDashboardCard(
                    context,
                    title: "My Orders",
                    icon: Icons.shopping_bag,
                    color: Colors.green,
                    onTap: () {
                      // TODO: Navigate to orders page
                      _showDummySnackbar(context, "Orders clicked");
                    },
                  ),

                  // Dummy Feature 4
                  _buildDashboardCard(
                    context,
                    title: "Settings",
                    icon: Icons.settings,
                    color: Colors.grey.shade700,
                    onTap: () {
                      // TODO: Navigate to settings page
                      _showDummySnackbar(context, "Settings clicked");
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // HELPER WIDGETS & FUNCTIONS
  // ---------------------------------------------------------

  // A helper function to build the square cards in the grid cleanly
  Widget _buildDashboardCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4), // Changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), // Light transparent version of the icon color
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A simple snackbar just to prove the dummy buttons work
  void _showDummySnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}