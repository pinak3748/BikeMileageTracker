import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../../providers/bike_provider.dart';
import '../../providers/maintenance_provider.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bikeProvider = Provider.of<BikeProvider>(context);

    if (!bikeProvider.hasBikes) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Maintenance',
          showBikeSelector: true,
        ),
        body: EmptyState(
          message: 'Add your motorcycle to start tracking maintenance',
          icon: Icons.motorcycle,
          actionLabel: 'Add Motorcycle',
          onActionPressed: () {
            Navigator.of(context).pushNamed('/add-bike');
          },
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Maintenance',
        showBikeSelector: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Reminders'),
            Tab(text: 'Services'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(),
          _buildRemindersTab(),
          _buildServicesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maintenance entry form will be implemented in the next phase'),
            ),
          );
        },
        backgroundColor: AppColors.warning,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return EmptyState(
      message: 'Track all maintenance performed on your bike',
      icon: Icons.build,
      actionLabel: 'Add Maintenance Entry',
      onActionPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maintenance entry form will be implemented in the next phase'),
          ),
        );
      },
    );
  }

  Widget _buildRemindersTab() {
    return EmptyState(
      message: 'Set up reminders for upcoming maintenance',
      icon: Icons.notifications,
      actionLabel: 'Add Reminder',
      onActionPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder form will be implemented in the next phase'),
          ),
        );
      },
    );
  }

  Widget _buildServicesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: AppConstants.maintenanceTypes.length,
      itemBuilder: (context, index) {
        final maintenanceType = AppConstants.maintenanceTypes[index];
        IconData icon;
        
        switch (maintenanceType) {
          case 'Oil Change':
            icon = Icons.opacity;
            break;
          case 'Chain Maintenance':
            icon = Icons.link;
            break;
          case 'Tire Replacement':
            icon = Icons.tire_repair;
            break;
          case 'Filter Change':
            icon = Icons.filter_alt;
            break;
          case 'Brake Service':
            icon = Icons.pan_tool;
            break;
          case 'Inspection':
            icon = Icons.search;
            break;
          case 'Tune-up':
            icon = Icons.tune;
            break;
          case 'Electrical':
            icon = Icons.electrical_services;
            break;
          case 'Fluids':
            icon = Icons.water_drop;
            break;
          default:
            icon = Icons.build;
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.warning,
              child: Icon(icon, color: Colors.white),
            ),
            title: Text(maintenanceType),
            subtitle: const Text('Tap to see history and schedule'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$maintenanceType details will be implemented in the next phase'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}