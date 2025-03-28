import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bike_provider.dart';
import '../models/bike.dart';
import '../screens/bike/bike_profile_screen.dart';
import '../utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBikeSelector;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBikeSelector = false,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom != null ? bottom!.preferredSize.height : 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: _buildActions(context),
      bottom: bottom,
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actionsList = <Widget>[];

    if (showBikeSelector) {
      actionsList.add(_buildBikeDropdown(context));
    }

    if (actions != null) {
      actionsList.addAll(actions!);
    }

    return actionsList;
  }

  Widget _buildBikeDropdown(BuildContext context) {
    final bikeProvider = Provider.of<BikeProvider>(context);

    if (!bikeProvider.hasBikes) {
      // Show add bike button if no bikes are available
      return IconButton(
        icon: const Icon(Icons.add_circle_outline),
        tooltip: 'Add Motorcycle',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const BikeProfileScreen(isEditing: false),
            ),
          );
        },
      );
    }

    // Show bike selector dropdown
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Center(
        child: DropdownButton<String>(
          value: bikeProvider.currentBike?.id,
          dropdownColor: AppColors.primary,
          underline: Container(),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          items: bikeProvider.bikes.map<DropdownMenuItem<String>>((Bike bike) {
            return DropdownMenuItem<String>(
              value: bike.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.motorcycle,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bike.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? bikeId) {
            if (bikeId != null) {
              bikeProvider.selectBike(bikeId);
            }
          },
          selectedItemBuilder: (BuildContext context) {
            return bikeProvider.bikes.map<Widget>((Bike bike) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.motorcycle,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bike.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }
}