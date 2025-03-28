import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bike_provider.dart';
import '../models/bike.dart';
import '../utils/constants.dart';
import '../screens/bike/bike_profile_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBikeSelector;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBikeSelector = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.primary,
      elevation: 0,
      actions: [
        if (showBikeSelector) _buildBikeSelector(context),
        if (actions != null) ...actions!,
      ],
    );
  }

  Widget _buildBikeSelector(BuildContext context) {
    final bikeProvider = Provider.of<BikeProvider>(context);
    
    if (!bikeProvider.hasBikes) {
      return IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BikeProfileScreen(isEditing: false),
            ),
          );
        },
        tooltip: 'Add Motorcycle',
      );
    }
    
    return PopupMenuButton<Bike>(
      icon: const Icon(Icons.motorcycle),
      tooltip: 'Select Motorcycle',
      itemBuilder: (context) {
        return [
          ...bikeProvider.bikes.map((bike) {
            return PopupMenuItem<Bike>(
              value: bike,
              child: Row(
                children: [
                  const Icon(
                    Icons.motorcycle,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(bike.name),
                  if (bikeProvider.currentBike?.id == bike.id)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          const PopupMenuDivider(),
          PopupMenuItem<Bike>(
            value: null,
            child: Row(
              children: [
                Icon(
                  Icons.add_circle,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text('Add Motorcycle'),
              ],
            ),
          ),
        ];
      },
      onSelected: (Bike? selectedBike) {
        if (selectedBike == null) {
          // Add new bike
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BikeProfileScreen(isEditing: false),
            ),
          );
        } else {
          // Switch to selected bike
          bikeProvider.setCurrentBike(selectedBike.id!);
        }
      },
    );
  }
}