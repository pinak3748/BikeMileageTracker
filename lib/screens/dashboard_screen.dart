import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/statistics_card.dart';
import '../widgets/empty_state.dart';
import '../providers/bike_provider.dart';
import '../providers/fuel_provider.dart';
import '../providers/maintenance_provider.dart';
import '../providers/expense_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import 'bike/bike_profile_screen.dart';
import 'fuel/fuel_screen.dart';
import 'maintenance/maintenance_screen.dart';
import 'expense/expense_screen.dart';
import 'analytics/analytics_screen.dart';
import 'document/document_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isInit = false;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _loadData();
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
      await bikeProvider.loadBikes();

      if (bikeProvider.currentBike != null) {
        final bikeId = bikeProvider.currentBike!.id!;
        final fuelProvider = Provider.of<FuelProvider>(context, listen: false);
        final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
        final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

        // Load data from providers
        await Future.wait([
          fuelProvider.loadFuelEntries(bikeId),
          maintenanceProvider.loadMaintenanceEntries(bikeId),
          maintenanceProvider.loadReminders(bikeId),
          expenseProvider.loadExpenses(bikeId),
        ]);
      }
    } catch (error) {
      debugPrint('Error loading dashboard data: $error');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case AppConstants.dashboardIndex:
        return _buildDashboardContent();
      case AppConstants.fuelIndex:
        return const FuelScreen();
      case AppConstants.maintenanceIndex:
        return const MaintenanceScreen();
      case AppConstants.expenseIndex:
        return const ExpenseScreen();
      case AppConstants.moreIndex:
        return _buildMoreMenu();
      default:
        return _buildDashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getAppBarTitle(),
        showBikeSelector: true,
        actions: _currentIndex == AppConstants.dashboardIndex
            ? [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadData,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _getScreenForIndex(_currentIndex),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case AppConstants.dashboardIndex:
        return 'Dashboard';
      case AppConstants.fuelIndex:
        return 'Fuel Tracking';
      case AppConstants.maintenanceIndex:
        return 'Maintenance';
      case AppConstants.expenseIndex:
        return 'Expenses';
      case AppConstants.moreIndex:
        return 'More Options';
      default:
        return 'MotoTracker';
    }
  }

  Widget _buildDashboardContent() {
    final bikeProvider = Provider.of<BikeProvider>(context);
    if (!bikeProvider.hasBikes) {
      return EmptyState(
        message: 'Add your motorcycle to get started tracking fuel and maintenance',
        icon: Icons.motorcycle,
        actionLabel: 'Add Motorcycle',
        onActionPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const BikeProfileScreen(isEditing: false),
            ),
          ).then((_) => _loadData());
        },
      );
    }

    final currentBike = bikeProvider.currentBike!;
    final fuelProvider = Provider.of<FuelProvider>(context);
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bike info card
            _buildBikeInfoCard(currentBike),

            // Quick stats
            _buildQuickStats(currentBike, fuelProvider, maintenanceProvider, expenseProvider),

            // Recent activities
            _buildRecentActivities(currentBike, fuelProvider, maintenanceProvider, expenseProvider),

            // Upcoming maintenance
            _buildUpcomingMaintenance(maintenanceProvider),

            // Quick actions
            _buildQuickActions(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeInfoCard(bike) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 24,
                  child: const Icon(
                    Icons.motorcycle,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bike.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${bike.make} ${bike.model} ${bike.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => BikeProfileScreen(
                          isEditing: true,
                          bike: bike,
                        ),
                      ),
                    ).then((_) => _loadData());
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Odometer',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatDistance(bike.currentOdometer),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Update'),
                  onPressed: () => _showUpdateOdometerDialog(context, bike),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateOdometerDialog(BuildContext context, bike) {
    final TextEditingController controller = TextEditingController(
      text: bike.currentOdometer.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Odometer'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Current Odometer (km)',
            suffixText: 'km',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (newValue != null && newValue >= bike.currentOdometer) {
                Provider.of<BikeProvider>(context, listen: false)
                    .updateOdometer(bike.id!, newValue);
                Navigator.of(ctx).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Odometer value must be equal or greater than current value'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bike, FuelProvider fuelProvider, MaintenanceProvider maintenanceProvider, ExpenseProvider expenseProvider) {
    return FutureBuilder(
      future: Future.wait([
        fuelProvider.getFuelStatistics(bike.id!),
        maintenanceProvider.getMaintenanceStatistics(bike.id!),
        expenseProvider.getExpenseStatistics(bike.id!),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading statistics: ${snapshot.error}',
              style: TextStyle(color: AppColors.danger),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No statistics available'));
        }

        final fuelStats = snapshot.data![0] as Map<String, dynamic>;
        final maintenanceStats = snapshot.data![1] as Map<String, dynamic>;
        final expenseStats = snapshot.data![2] as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  'Quick Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                children: [
                  StatisticsCard(
                    title: 'Avg. Efficiency',
                    value: DateFormatter.formatEfficiency(
                      (fuelStats['avgEfficiency'] as double?) ?? 0.0,
                    ),
                    icon: Icons.speed,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const AnalyticsScreen()),
                    ),
                  ),
                  StatisticsCard(
                    title: 'Total Fuel Cost',
                    value: DateFormatter.formatCurrency(
                      (fuelStats['totalCost'] as double?) ?? 0.0,
                    ),
                    icon: Icons.local_gas_station,
                    iconColor: AppColors.accent,
                    onTap: () => _onNavTap(AppConstants.fuelIndex),
                  ),
                  StatisticsCard(
                    title: 'Maintenance Cost',
                    value: DateFormatter.formatCurrency(
                      (maintenanceStats['totalCost'] as double?) ?? 0.0,
                    ),
                    icon: Icons.build,
                    iconColor: AppColors.warning,
                    onTap: () => _onNavTap(AppConstants.maintenanceIndex),
                  ),
                  StatisticsCard(
                    title: 'Total Expenses',
                    value: DateFormatter.formatCurrency(
                      (expenseStats['totalExpenses'] as double?) ?? 0.0,
                    ),
                    icon: Icons.attach_money,
                    iconColor: AppColors.success,
                    onTap: () => _onNavTap(AppConstants.expenseIndex),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentActivities(bike, FuelProvider fuelProvider, MaintenanceProvider maintenanceProvider, ExpenseProvider expenseProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder(
            future: Future.wait([
              fuelProvider.getFuelEntriesForBikeWithLimit(bike.id!, 3),
              maintenanceProvider.getRecentMaintenance(bike.id!, 3),
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading activities: ${snapshot.error}',
                    style: TextStyle(color: AppColors.danger),
                  ),
                );
              }

              final recentFuelEntries = (snapshot.data?[0] as List?) ?? [];
              final recentMaintenance = (snapshot.data?[1] as List?) ?? [];
              // We'll implement this method later
              // final recentExpenses = expenseProvider.getRecentExpenses(3);
              final recentExpenses = <dynamic>[];

              // Combine and sort all activities by date
              final allActivities = [
                ...recentFuelEntries.map((e) => {
                      'type': 'fuel',
                      'date': e.date,
                      'data': e,
                    }),
                ...recentMaintenance.map((e) => {
                      'type': 'maintenance',
                      'date': e.date,
                      'data': e,
                    }),
                ...recentExpenses.map((e) => {
                      'type': 'expense',
                      'date': e.date,
                      'data': e,
                    }),
              ];

              allActivities.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

              // Take only the 5 most recent activities
              final mostRecent = allActivities.take(5).toList();

              if (mostRecent.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No recent activities found',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mostRecent.length,
                itemBuilder: (ctx, i) {
                  final activity = mostRecent[i];
                  final type = activity['type'] as String;
                  final data = activity['data'];
                  final date = activity['date'] as DateTime;

                  // Build different UI based on activity type
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getActivityColor(type),
                        child: Icon(
                          _getActivityIcon(type),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(_getActivityTitle(type, data)),
                      subtitle: Text(DateFormatter.formatDate(date)),
                      trailing: Text(
                        _getActivityValue(type, data),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _navigateToDetail(type, data),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'fuel':
        return AppColors.accent;
      case 'maintenance':
        return AppColors.warning;
      case 'expense':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'fuel':
        return Icons.local_gas_station;
      case 'maintenance':
        return Icons.build;
      case 'expense':
        return Icons.attach_money;
      default:
        return Icons.history;
    }
  }

  String _getActivityTitle(String type, dynamic data) {
    switch (type) {
      case 'fuel':
        return 'Fuel Fill-Up';
      case 'maintenance':
        return data.title;
      case 'expense':
        return data.title;
      default:
        return 'Activity';
    }
  }

  String _getActivityValue(String type, dynamic data) {
    switch (type) {
      case 'fuel':
        return DateFormatter.formatCurrency(data.totalCost);
      case 'maintenance':
        return DateFormatter.formatCurrency(data.cost);
      case 'expense':
        return DateFormatter.formatCurrency(data.amount);
      default:
        return '';
    }
  }

  void _navigateToDetail(String type, dynamic data) {
    // Implementation for navigation to detail screens
    // will be added when those screens are created
  }

  Widget _buildUpcomingMaintenance(MaintenanceProvider maintenanceProvider) {
    final bikeProvider = Provider.of<BikeProvider>(context);
    if (!bikeProvider.hasBikes) return const SizedBox();

    final currentBike = bikeProvider.currentBike!;
    final overdueReminders = maintenanceProvider.getOverdueReminders(currentBike.id!);
    final upcomingReminders = maintenanceProvider.getUpcomingReminders(currentBike.id!);

    if (overdueReminders.isEmpty && upcomingReminders.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Maintenance Reminders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          
          // Overdue reminders
          if (overdueReminders.isNotEmpty) ...[
            Card(
              color: AppColors.danger.withOpacity(0.1),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.danger),
                        const SizedBox(width: 8),
                        Text(
                          'Overdue',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: overdueReminders.length,
                    itemBuilder: (ctx, i) {
                      final reminder = overdueReminders[i];
                      return ListTile(
                        title: Text(reminder.title),
                        subtitle: Text(
                          'Due: ${DateFormatter.formatDate(reminder.dueDate!)}',
                          style: TextStyle(color: AppColors.danger),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          onPressed: () {
                            // Mark as completed logic
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Upcoming reminders
          if (upcomingReminders.isNotEmpty) ...[
            Card(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Text(
                          'Upcoming',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcomingReminders.take(3).length,
                    itemBuilder: (ctx, i) {
                      final reminder = upcomingReminders[i];
                      return ListTile(
                        title: Text(reminder.title),
                        subtitle: Text(
                          reminder.dueDate != null
                              ? 'Due: ${DateFormatter.formatDate(reminder.dueDate!)}'
                              : 'Due at: ${DateFormatter.formatDistance(reminder.dueDistance!)}',
                        ),
                        trailing: Text(reminder.maintenanceType),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          
          if (upcomingReminders.length > 3) ...[
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('See All Reminders'),
                onPressed: () => _onNavTap(AppConstants.maintenanceIndex),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                icon: Icons.local_gas_station,
                label: 'Add Fuel',
                color: AppColors.accent,
                onPressed: () => _onNavTap(AppConstants.fuelIndex),
              ),
              _buildQuickActionButton(
                icon: Icons.build,
                label: 'Add Maintenance',
                color: AppColors.warning,
                onPressed: () => _onNavTap(AppConstants.maintenanceIndex),
              ),
              _buildQuickActionButton(
                icon: Icons.attach_money,
                label: 'Add Expense',
                color: AppColors.success,
                onPressed: () => _onNavTap(AppConstants.expenseIndex),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreMenu() {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.analytics, color: AppColors.primary),
          title: const Text('Analytics'),
          subtitle: const Text('View detailed charts and statistics'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const AnalyticsScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.article, color: AppColors.primary),
          title: const Text('Documents'),
          subtitle: const Text('Store and manage bike documents'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const DocumentScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.motorcycle, color: AppColors.primary),
          title: const Text('Bike Profile'),
          subtitle: const Text('View and edit bike information'),
          onTap: () {
            final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => BikeProfileScreen(
                  isEditing: true,
                  bike: bikeProvider.currentBike,
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.settings, color: AppColors.primary),
          title: const Text('Settings'),
          subtitle: const Text('App preferences and options'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.info, color: AppColors.primary),
          title: const Text('About'),
          subtitle: const Text('App version and information'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'MotoTracker',
              applicationVersion: '1.0.0',
              applicationIcon: Icon(
                Icons.motorcycle,
                color: AppColors.primary,
                size: 32,
              ),
              children: [
                const Text(
                  'A comprehensive motorcycle maintenance and fuel tracking app to optimize your riding experience.',
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
