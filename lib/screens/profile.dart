import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../login_page.dart';
import '../services/firestore_service.dart';
import '../styles.dart';
import 'booking_history.dart';
import 'dashboard.dart';
import 'damage_history.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService firestoreService = FirestoreService();
  final ImagePicker picker = ImagePicker();

  final int _selectedIndex = 2;
  bool isUploading = false;

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookingHistoryPage()),
      );
    }
  }

  // ---------------------------------------------------------
  // PHOTO UPLOAD LOGIC (unchanged) — base64 stored in Firestore
  // ---------------------------------------------------------
  Future<void> pickImage() async {
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 600,
    );

    if (pickedImage == null) return;

    setState(() => isUploading = true);

    try {
      final bytes = await pickedImage.readAsBytes();
      await firestoreService.updateImageBase64(base64Encode(bytes));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  // ---------------------------------------------------------
  // LOGOUT LOGIC (unchanged) with a themed confirmation dialog
  // ---------------------------------------------------------
  Future<void> _handleLogout(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.errorSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout_rounded,
                color: AppColors.error, size: 28),
          ),
          title: const Text("Logout",
              textAlign: TextAlign.center, style: AppTextStyles.heading),
          content: const Text(
            "Are you sure you want to logout?",
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              style: AppButtonStyles.outlinedButton,
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profile", style: AppTextStyles.heading),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestoreService.getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading profile"));
          }

          Map<String, dynamic> data = {};

          if (snapshot.hasData && snapshot.data!.exists) {
            data = snapshot.data!.data() as Map<String, dynamic>;
          }

          final String name = data["name"] ?? "No Name";
          final String memberId = data["memberId"] ?? "-";
          final String email = data["email"] ??
              FirebaseAuth.instance.currentUser?.email ??
              "No Email";
          final String phone = data["phone"] ?? "-";
          final String address = data["address"] ?? "-";

          // Prefer the base64 photo stored in Firestore; fall back to a
          // legacy imageUrl if one exists.
          final String imageBase64 = data["imageBase64"] ?? "";
          final String imageUrl = data["imageUrl"] ?? "";
          ImageProvider? avatarImage;
          if (imageBase64.isNotEmpty) {
            avatarImage = MemoryImage(base64Decode(imageBase64));
          } else if (imageUrl.isNotEmpty) {
            avatarImage = NetworkImage(imageUrl);
          }

          return SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                //================ GRADIENT PROFILE CARD =================//
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: AppShadows.button,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: AppColors.primarySoft,
                              backgroundImage: avatarImage,
                              child: avatarImage == null
                                  ? const Icon(Icons.person_rounded,
                                      size: 52, color: AppColors.primary)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: isUploading ? null : pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.navy,
                                  shape: BoxShape.circle,
                                ),
                                child: isUploading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.camera_alt_rounded,
                                        color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                AppSpacing.mediumGap,

                //================ INFO CARD =================//
                Container(
                  decoration: AppDecorations.card,
                  child: Column(
                    children: [
                      _InfoTile(
                          icon: Icons.badge_outlined,
                          label: "Member ID",
                          value: memberId),
                      Divider(height: 1, color: Colors.grey.shade100),
                      _InfoTile(
                          icon: Icons.location_on_outlined,
                          label: "Address",
                          value: address),
                      Divider(height: 1, color: Colors.grey.shade100),
                      _InfoTile(
                          icon: Icons.phone_outlined,
                          label: "Phone No.",
                          value: phone),
                      Divider(height: 1, color: Colors.grey.shade100),
                      _InfoTile(
                          icon: Icons.mail_outline_rounded,
                          label: "Email",
                          value: email),
                    ],
                  ),
                ),

                AppSpacing.mediumGap,

                //================ MENU =================//
                Container(
                  decoration: AppDecorations.card,
                  child: Column(
                    children: [
                      _MenuTile(
                        icon: Icons.edit_rounded,
                        label: "Edit Profile",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: Colors.grey.shade100),
                      _MenuTile(
                        icon: Icons.build_circle_outlined,
                        label: "My Damage Reports",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DamageHistoryPage(),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: Colors.grey.shade100),
                      _MenuTile(
                        icon: Icons.logout_rounded,
                        label: "Logout",
                        destructive: true,
                        onTap: () => _handleLogout(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_note_rounded), label: "Bookings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }
}

/// Read-only detail row inside the info card.
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: AppColors.primary, size: 19),
      ),
      title: Text(label, style: AppTextStyles.caption),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Tappable menu row (Edit Profile / My Damage Reports / Logout).
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = destructive ? AppColors.error : AppColors.textPrimary;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: destructive ? AppColors.errorSoft : AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon,
            color: destructive ? AppColors.error : AppColors.textSecondary,
            size: 19),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: destructive ? AppColors.error : AppColors.textSecondary),
    );
  }
}
