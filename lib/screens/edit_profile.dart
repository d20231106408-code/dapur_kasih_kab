import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../styles.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final FirestoreService firestore = FirestoreService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ---------------------------------------------------------
  // LOAD / SAVE LOGIC (unchanged)
  // ---------------------------------------------------------
  Future<void> loadProfile() async {
    final data = await firestore.getProfile().first;

    if (data.exists) {
      final profile = data.data() as Map<String, dynamic>;
      nameController.text = profile["name"] ?? "";
      phoneController.text = profile["phone"] ?? "";
      addressController.text = profile["address"] ?? "";
    }

    emailController.text = FirebaseAuth.instance.currentUser?.email ?? "";

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      await firestore.saveProfile(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Widget buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboard,
            validator: validator,
            style: TextStyle(
              color: enabled
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            decoration: AppDecorations.input(
              prefixIcon:
                  Icon(icon, color: AppColors.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Edit Profile", style: AppTextStyles.heading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Avatar ---
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_rounded,
                          size: 52, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              buildField(
                label: "Name",
                icon: Icons.person_outline_rounded,
                controller: nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your name";
                  }
                  return null;
                },
              ),

              buildField(
                label: "Phone Number",
                icon: Icons.phone_outlined,
                controller: phoneController,
                keyboard: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter phone number";
                  }
                  if (value.length < 10 || value.length > 11) {
                    return "Phone number must be 10-11 digits";
                  }
                  return null;
                },
              ),

              buildField(
                label: "Email",
                icon: Icons.mail_outline_rounded,
                controller: emailController,
                enabled: false,
              ),

              buildField(
                label: "Address",
                icon: Icons.location_on_outlined,
                controller: addressController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your address";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // --- Save (navy, like the reference) ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  onPressed: isSaving ? null : _saveChanges,
                  child: isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text("Save Changes",
                          style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
