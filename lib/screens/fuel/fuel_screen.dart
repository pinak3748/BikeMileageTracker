import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bike_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../../utils/constants.dart';

class FuelScreen extends StatelessWidget {
  const FuelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bikeProvider = Provider.of<BikeProvider>(context);

    if (!bikeProvider.hasBikes) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Fuel Log',
          showBikeSelector: true,
        ),
        body: EmptyState(
          message: 'Add your motorcycle to start tracking fuel',
          title: 'No Bikes Available',
          icon: Icons.motorcycle,
          actionText: 'Add Motorcycle',
          onAction: () {
            Navigator.of(context).pushNamed('/add-bike');
          },
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Fuel Log',
        showBikeSelector: true,
      ),
      body: EmptyState(
        message: 'Keep track of your fuel consumption and expenses',
        title: 'No Fuel Entries',
        icon: Icons.local_gas_station,
        actionText: 'Add Fuel Entry',
        onAction: () {
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
        backgroundColor: AppColors.current.info,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}