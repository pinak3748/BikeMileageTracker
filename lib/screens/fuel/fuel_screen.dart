import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../../providers/bike_provider.dart';

class FuelScreen extends StatelessWidget {
  const FuelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bikeProvider = Provider.of<BikeProvider>(context);

    if (!bikeProvider.hasBikes) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Fuel Tracking',
          showBikeSelector: true,
        ),
        body: EmptyState(
          message: 'Add your motorcycle to start tracking fuel entries',
          icon: Icons.motorcycle,
          actionLabel: 'Add Motorcycle',
          onActionPressed: () {
            Navigator.of(context).pushNamed('/add-bike');
          },
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Fuel Tracking',
        showBikeSelector: true,
      ),
      body: EmptyState(
        message: 'Track your fuel consumption, costs, and efficiency',
        icon: Icons.local_gas_station,
        actionLabel: 'Add Fuel Entry',
        onActionPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fuel entry form will be implemented in the next phase'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fuel entry form will be implemented in the next phase'),
            ),
          );
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}