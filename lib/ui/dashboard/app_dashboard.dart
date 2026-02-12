// dashboard_page.dart (Main Shell)

import 'package:flutter/material.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/ui/adoption/adoption_flow_page.dart';
import 'package:spogpaws/ui/dashboard/pages.dart';
import 'package:spogpaws/widgets/three_dimensional_button.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const ClinicsView(),
    const AdoptionView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Button3D(
          baseColor: AppColors.primary,
          shadowColor: AppColors.secondary,
          onTap: () => NavigatorHelper.push(context, const AdoptionFlowPage()),
          child: Icon(Icons.pets, color: AppColors.secondary, size: 28),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          color: AppColors.white,
          notchMargin: 5,
          elevation: 10,
          shape: const CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navItem(Icons.home_rounded, "HOME", 0),
                _navItem(Icons.medical_services_rounded, "CLINICS", 1),
                const SizedBox(width: 50),
                _navItem(Icons.favorite_rounded, "ADOPTION", 2),
                _navItem(Icons.account_circle_rounded, "PROFILE", 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.secondary : AppColors.grey,
            size: 20,
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: AppFonts.nunitoRegular().copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.secondary : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
