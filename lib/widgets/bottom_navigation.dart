import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_gas_station_outlined),
          activeIcon: Icon(Icons.local_gas_station),
          label: 'Fuel',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build_outlined),
          activeIcon: Icon(Icons.build),
          label: 'Maintenance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money_outlined),
          activeIcon: Icon(Icons.attach_money),
          label: 'Expenses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_outlined),
          activeIcon: Icon(Icons.menu),
          label: 'More',
        ),
      ],
    );
  }
}