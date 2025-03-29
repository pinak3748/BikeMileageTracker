import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:moto_tracker/models/bike.dart';
import 'package:moto_tracker/models/maintenance_record.dart';
import 'package:moto_tracker/providers/bikes_provider.dart';
import 'package:moto_tracker/providers/maintenance_provider.dart';
import 'package:moto_tracker/screens/maintenance/maintenance_entry_screen.dart';
import 'package:moto_tracker/screens/maintenance/maintenance_history_screen.dart';
import 'package:moto_tracker/screens/maintenance/maintenance_reminder_list_screen.dart';
import 'package:moto_tracker/utils/constants.dart';
import 'package:moto_tracker/utils/helpers.dart';
import 'package:moto_tracker/widgets/app_bar.dart';
import 'package:moto_tracker/widgets/empty_state.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bikesProvider = Provider.of<BikesProvider>(context, listen: false);
      final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
      
      Bike? selectedBike = bikesProvider.selectedBike;
      
      if (selectedBike != null) {
        await maintenanceProvider.loadMaintenanceRecords(selectedBike.id!);
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading maintenance data: $e')),
        );
      }
    }
  }

  void _navigateToMaintenanceEntry() {
    final bikesProvider = Provider.of<BikesProvider>(context, listen: false);
    final selectedBike = bikesProvider.selectedBike;
    
    if (selectedBike == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bike first')),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceEntryScreen(
          bikeId: selectedBike.id!,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToMaintenanceHistory() {
    final bikesProvider = Provider.of<BikesProvider>(context, listen: false);
    final selectedBike = bikesProvider.selectedBike;
    
    if (selectedBike == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bike first')),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceHistoryScreen(
          bikeId: selectedBike.id!,
        ),
      ),
    );
  }

  void _navigateToMaintenanceReminders() {
    final bikesProvider = Provider.of<BikesProvider>(context, listen: false);
    final selectedBike = bikesProvider.selectedBike;
    
    if (selectedBike == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bike first')),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceReminderListScreen(
          bikeId: selectedBike.id!,
        ),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final bikesProvider = Provider.of<BikesProvider>(context);
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context);
    
    final selectedBike = bikesProvider.selectedBike;
    
    if (selectedBike == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Maintenance'),
        body: const EmptyState(
          icon: Icons.build,
          title: 'No Bike Selected',
          message: 'Please select or add a bike to start tracking maintenance.',
        ),
      );
    }
    
    final upcomingMaintenanceCount = maintenanceProvider.getUpcomingMaintenanceCount(selectedBike.id!);
    final recentMaintenanceCount = maintenanceProvider.getRecentMaintenanceCount(selectedBike.id!);
    final totalMaintenanceCost = maintenanceProvider.getTotalMaintenanceCost(selectedBike.id!);
    
    return Scaffold(
      appBar: const CustomAppBar(title: 'Maintenance'),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToMaintenanceEntry,
        backgroundColor: AppColors.current.primary,
        foregroundColor: AppColors.current.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Upcoming',
                          value: '$upcomingMaintenanceCount',
                          icon: Icons.notification_important,
                          color: AppColors.current.warning,
                          onTap: _navigateToMaintenanceReminders,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Recent',
                          value: '$recentMaintenanceCount',
                          icon: Icons.history,
                          color: AppColors.current.info,
                          onTap: _navigateToMaintenanceHistory,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Total cost card
                  _buildStatCard(
                    title: 'Total Maintenance Cost',
                    value: formatCurrency(totalMaintenanceCost),
                    icon: Icons.attach_money,
                    color: AppColors.current.success,
                    onTap: _navigateToMaintenanceHistory,
                    fullWidth: true,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Quick actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.current.text,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: 'Add Service',
                          icon: Icons.build,
                          color: AppColors.current.primary,
                          onTap: _navigateToMaintenanceEntry,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          label: 'History',
                          icon: Icons.history,
                          color: AppColors.current.secondary,
                          onTap: _navigateToMaintenanceHistory,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: 'Reminders',
                          icon: Icons.notifications_active,
                          color: AppColors.current.info,
                          onTap: _navigateToMaintenanceReminders,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Upcoming maintenance
                  Text(
                    'Upcoming Maintenance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.current.text,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Upcoming maintenance list
                  _buildUpcomingMaintenanceList(maintenanceProvider, selectedBike),
                ],
              ),
            ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return Card(
      elevation: AppConstants.cardElevation,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: fullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: fullWidth ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.current.textSecondary,
                    ),
                  ),
                  Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: fullWidth ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.current.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
  
  Widget _buildUpcomingMaintenanceList(MaintenanceProvider provider, Bike bike) {
    final scheduledMaintenance = provider.getScheduledMaintenance(bike.id!);
    
    if (scheduledMaintenance.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle,
        title: 'No Upcoming Maintenance',
        message: 'You have no upcoming maintenance scheduled.',
        iconSize: 48,
      );
    }
    
    return Column(
      children: scheduledMaintenance.take(3).map((record) => _buildMaintenanceItem(record)).toList()
        ..add(
          // See all button
          if (scheduledMaintenance.length > 3)
            TextButton(
              onPressed: _navigateToMaintenanceHistory,
              child: Text(
                'See All (${scheduledMaintenance.length})',
                style: TextStyle(
                  color: AppColors.current.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ),
    );
  }
  
  Widget _buildMaintenanceItem(MaintenanceRecord record) {
    final dateString = record.nextDueDate != null
        ? DateFormat('MMM dd, yyyy').format(record.nextDueDate!)
        : DateFormat('MMM dd, yyyy').format(record.date);
        
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          record.type,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Due: $dateString'),
            Text('Odometer: ${record.odometer.toStringAsFixed(0)} km'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MaintenanceEntryScreen(
                bikeId: record.bikeId,
                existingRecord: record,
              ),
            ),
          ).then((_) => _loadData());
        },
      ),
    );
  }
}