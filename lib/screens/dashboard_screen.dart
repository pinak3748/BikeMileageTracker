import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bike_provider.dart';
import '../providers/maintenance_provider.dart';
import '../providers/fuel_provider.dart';
import '../providers/expense_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/statistics_card.dart';
import 'bike/bike_profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final bikeProvider = Provider.of<BikeProvider>(context);
    
    if (!bikeProvider.hasBikes) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Dashboard',
          showBikeSelector: false,
        ),
        body: EmptyState(
          message: 'Add your motorcycle to get started',
          title: 'Welcome to Bike Tracker',
          icon: Icons.motorcycle,
          actionText: 'Add Motorcycle',
          onAction: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BikeProfileScreen(isEditing: false),
              ),
            );
          },
        ),
      );
    }
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
        showBikeSelector: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(context),
                const SizedBox(height: 24),
                _buildSectionHeader('Recent Activity'),
                _buildRecentActivity(context),
                const SizedBox(height: 24),
                _buildSectionHeader('Maintenance'),
                _buildMaintenanceSection(context),
                const SizedBox(height: 24),
                _buildSectionHeader('Fuel Economy'),
                _buildFuelSection(context),
                const SizedBox(height: 24),
                _buildSectionHeader('Expenses'),
                _buildExpensesSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSummaryCards(BuildContext context) {
    final bikeProvider = Provider.of<BikeProvider>(context);
    final fuelProvider = Provider.of<FuelProvider>(context);
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    
    final currentBike = bikeProvider.currentBike;
    if (currentBike == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatisticsCard(
                title: 'Current Odometer',
                value: DateFormatter.formatDistance(currentBike.currentOdometer),
                icon: Icons.speed,
                backgroundColor: Colors.white,
                onTap: () {
                  _showUpdateOdometerDialog(context, currentBike.currentOdometer);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatisticsCard(
                title: 'Distance Traveled',
                value: DateFormatter.formatDistance(currentBike.totalDistanceTraveled),
                icon: Icons.timeline,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatisticsCard(
                title: 'Fuel Economy',
                value: fuelProvider.getAverageFuelEconomy(currentBike.id!) > 0
                    ? '${DateFormatter.formatNumber(fuelProvider.getAverageFuelEconomy(currentBike.id!))} km/L'
                    : 'N/A',
                icon: Icons.local_gas_station,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatisticsCard(
                title: 'Total Expenses',
                value: DateFormatter.formatCurrency(
                  fuelProvider.getTotalFuelCost(currentBike.id!) +
                  maintenanceProvider.getTotalMaintenanceCost(currentBike.id!) +
                  expenseProvider.getTotalExpenses(currentBike.id!),
                ),
                icon: Icons.account_balance_wallet,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.current.primary,
        ),
      ),
    );
  }
  
  Widget _buildRecentActivity(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('Recent activity will be shown here'),
        ),
      ),
    );
  }
  
  Widget _buildMaintenanceSection(BuildContext context) {
    final bikeProvider = Provider.of<BikeProvider>(context);
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context);
    
    final currentBike = bikeProvider.currentBike;
    if (currentBike == null) return const SizedBox.shrink();
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Recent',
                    '${maintenanceProvider.getRecentMaintenanceCount(currentBike.id!)}',
                    'In last 30 days',
                    AppColors.current.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    'Upcoming',
                    '${maintenanceProvider.getUpcomingMaintenanceCount(currentBike.id!)}',
                    'Scheduled',
                    AppColors.current.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/maintenance');
              },
              child: const Text('View All Maintenance'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFuelSection(BuildContext context) {
    final bikeProvider = Provider.of<BikeProvider>(context);
    final fuelProvider = Provider.of<FuelProvider>(context);
    
    final currentBike = bikeProvider.currentBike;
    if (currentBike == null) return const SizedBox.shrink();
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Total Cost',
                    DateFormatter.formatCurrency(fuelProvider.getTotalFuelCost(currentBike.id!)),
                    'All time',
                    AppColors.current.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    'Total Volume',
                    '${DateFormatter.formatNumber(fuelProvider.getTotalFuelVolume(currentBike.id!))} L',
                    'All time',
                    AppColors.current.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/fuel');
              },
              child: const Text('View Fuel History'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExpensesSection(BuildContext context) {
    final bikeProvider = Provider.of<BikeProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    
    final currentBike = bikeProvider.currentBike;
    if (currentBike == null) return const SizedBox.shrink();
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Total',
                    DateFormatter.formatCurrency(expenseProvider.getTotalExpenses(currentBike.id!)),
                    'All expenses',
                    AppColors.current.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    'Recent',
                    '${expenseProvider.getRecentExpensesCount(currentBike.id!)}',
                    'In last 30 days',
                    AppColors.current.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/expenses');
              },
              child: const Text('View All Expenses'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(String title, String value, String subtitle, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  void _showUpdateOdometerDialog(BuildContext context, double currentValue) {
    final TextEditingController controller = TextEditingController(
      text: currentValue.toString(),
    );
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Odometer'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Current Reading (km)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
                final currentBike = bikeProvider.currentBike;
                if (currentBike != null) {
                  bikeProvider.updateOdometer(currentBike.id!, value);
                  Navigator.of(ctx).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Odometer updated')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _refreshData(BuildContext context) async {
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
    final fuelProvider = Provider.of<FuelProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    await bikeProvider.loadBikes();
    
    final currentBike = bikeProvider.currentBike;
    if (currentBike != null) {
      await maintenanceProvider.loadMaintenanceRecords(currentBike.id!);
      await fuelProvider.loadFuelEntries(currentBike.id!);
      await expenseProvider.loadExpenses(currentBike.id!);
    }
  }
}