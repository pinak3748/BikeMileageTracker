import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bike_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

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
          message: 'Add your motorcycle to track maintenance',
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
        title: 'Maintenance',
        showBikeSelector: true,
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: AppColors.current.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.current.primary,
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'History'),
                  Tab(text: 'Schedule'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildUpcomingTab(context),
                  _buildHistoryTab(context),
                  _buildScheduleTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add maintenance form will be implemented in the next phase'),
            ),
          );
        },
        backgroundColor: AppColors.current.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUpcomingTab(BuildContext context) {
    return EmptyState(
      message: 'No upcoming maintenance tasks',
      icon: Icons.build,
      actionLabel: 'Add Task',
      onActionPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add maintenance form will be implemented in the next phase'),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    return EmptyState(
      message: 'No maintenance history',
      icon: Icons.history,
      actionLabel: 'Add Record',
      onActionPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add maintenance form will be implemented in the next phase'),
          ),
        );
      },
    );
  }

  Widget _buildScheduleTab(BuildContext context) {
    return EmptyState(
      message: 'No maintenance schedule',
      icon: Icons.calendar_today,
      actionLabel: 'Add Schedule',
      onActionPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add maintenance schedule form will be implemented in the next phase'),
          ),
        );
      },
    );
  }
}