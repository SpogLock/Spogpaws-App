import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.secondary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: AppFonts.nunitoBold(
            fontSize: 20,
          ).copyWith(color: AppColors.secondary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Profile Summary Section ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        color: AppColors.secondary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "John Doe",
                          style: AppFonts.nunitoBold(fontSize: 18),
                        ),
                        Text(
                          "john.doe@spogpaws.com",
                          style: AppFonts.nunitoRegular(
                            fontSize: 14,
                          ).copyWith(color: AppColors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // --- Section: Account ---
            _buildSectionHeader("Account"),
            _buildSettingsTile(
              icon: Icons.notifications_none_rounded,
              title: "Notifications",
              subtitle: "Control your alerts and reminders",
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.lock_outline_rounded,
              title: "Privacy & Security",
              subtitle: "Manage your password and data",
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.pets_outlined,
              title: "My Pets",
              subtitle: "Add or remove pet profiles",
              onTap: () {},
            ),

            const SizedBox(height: 10),

            // --- Section: Support ---
            _buildSectionHeader("Support"),
            _buildSettingsTile(
              icon: Icons.help_outline_rounded,
              title: "Help Center",
              subtitle: "FAQs and troubleshooting",
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.info_outline_rounded,
              title: "About Spogpaws",
              subtitle: "Version 1.0.4",
              onTap: () {},
            ),

            const SizedBox(height: 30),

            // --- Logout Button ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () {
                  // Add Logout Logic
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.shade100),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.red.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Log Out",
                        style: AppFonts.nunitoBold(
                          fontSize: 16,
                        ).copyWith(color: Colors.red.shade400),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Helper: Section Header ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: AppFonts.nunitoBold(
          fontSize: 14,
        ).copyWith(color: AppColors.primary, letterSpacing: 1.2),
      ),
    );
  }

  // --- Helper: Settings Tile ---
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.secondary, size: 22),
      ),
      title: Text(title, style: AppFonts.nunitoBold(fontSize: 16)),
      subtitle: Text(
        subtitle,
        style: AppFonts.nunitoRegular(
          fontSize: 13,
        ).copyWith(color: AppColors.grey),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.grey.shade300,
        size: 16,
      ),
    );
  }
}
