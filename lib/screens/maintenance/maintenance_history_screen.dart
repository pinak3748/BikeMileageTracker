import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bike_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import 'maintenance_entry_screen.dart';

class MaintenanceHistoryScreen extends StatefulWidget {
  const MaintenanceHistoryScreen({super.key});

  @override
  State<MaintenanceHistoryScreen> createState() => _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  bool _isLoading = false;
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
    if (bikeProvider.currentBike != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
        await maintenanceProvider.loadMaintenanceEntries(bikeProvider.currentBike!.id!);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading maintenance data: $error'),
            backgroundColor: AppColors.current.danger,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance History'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                if (_selectedFilter == value) {
                  _selectedFilter = null; // Toggle off if same filter is selected
                } else {
                  _selectedFilter = value;
                }
              });
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Types'),
              ),
              ...AppConstants.maintenanceTypes.map((type) => 
                PopupMenuItem(
                  value: type,
                  child: Text(type),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.current.accent))
          : _buildMaintenanceList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const MaintenanceEntryScreen(),
            ),
          ).then((_) => _refreshData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMaintenanceList() {
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context);
    final entries = maintenanceProvider.maintenanceEntries;

    // Apply filter if selected
    final filteredEntries = _selectedFilter == null || _selectedFilter == 'all'
        ? entries
        : entries.where((e) => e.maintenanceType == _selectedFilter).toList();

    if (entries.isEmpty) {
      return EmptyState(
        message: 'No maintenance records yet. Add your first maintenance to start tracking.',
        icon: Icons.build,
        actionLabel: 'Add Maintenance',
        onActionPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const MaintenanceEntryScreen()),
          ).then((_) => _refreshData());
        },
      );
    }

    if (filteredEntries.isEmpty) {
      return EmptyState(
        message: 'No maintenance records found for the selected filter.',
        icon: Icons.filter_list,
        actionLabel: 'Clear Filter',
        onActionPressed: () {
          setState(() {
            _selectedFilter = null;
          });
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredEntries.length,
        itemBuilder: (ctx, i) {
          final entry = filteredEntries[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => MaintenanceEntryScreen(
                      maintenance: entry,
                      isEditing: true,
                    ),
                  ),
                ).then((_) => _refreshData());
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.formatDate(entry.date),
                          style: TextStyle(
                            color: AppColors.current.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.build,
                              size: 16,
                              color: AppColors.current.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.maintenanceType,
                              style: TextStyle(
                                color: AppColors.current.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          DateFormatter.formatCurrency(entry.cost),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.current.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          size: 16,
                          color: AppColors.current.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatDistance(entry.odometer),
                          style: TextStyle(
                            color: AppColors.current.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (entry.partsReplaced != null && entry.partsReplaced!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Divider(color: AppColors.current.border),
                      const SizedBox(height: 8),
                      Text(
                        'Parts: ${entry.partsReplaced}',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (entry.serviceProvider != null && entry.serviceProvider!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Service: ${entry.serviceProvider}',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        entry.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppColors.current.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
