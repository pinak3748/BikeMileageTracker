import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:moto_tracker/models/bike.dart';
import 'package:moto_tracker/models/maintenance_record.dart';
import 'package:moto_tracker/models/maintenance_status.dart';
import 'package:moto_tracker/providers/bikes_provider.dart';
import 'package:moto_tracker/providers/maintenance_provider.dart';
import 'package:moto_tracker/screens/maintenance/maintenance_entry_screen.dart';
import 'package:moto_tracker/utils/constants.dart';
import 'package:moto_tracker/utils/helpers.dart';
import 'package:moto_tracker/widgets/app_bar.dart';
import 'package:moto_tracker/widgets/empty_state.dart';

class MaintenanceHistoryScreen extends StatefulWidget {
  final String bikeId;

  const MaintenanceHistoryScreen({
    Key? key,
    required this.bikeId,
  }) : super(key: key);

  @override
  _MaintenanceHistoryScreenState createState() =>
      _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  bool _isLoading = true;
  late Bike _bike;
  List<MaintenanceRecord> _records = [];
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', ...AppConstants.maintenanceTypes];

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
      final maintenanceProvider =
          Provider.of<MaintenanceProvider>(context, listen: false);

      final bike = await bikesProvider.getBike(widget.bikeId);
      await maintenanceProvider.loadMaintenanceRecords(widget.bikeId);

      if (mounted) {
        setState(() {
          _bike = bike;
          _records = maintenanceProvider.getRecordsByBikeId(widget.bikeId);
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading maintenance history: $e')),
        );
      }
    }
  }

  void _applyFilter() {
    final maintenanceProvider =
        Provider.of<MaintenanceProvider>(context, listen: false);

    if (_selectedFilter == 'All') {
      _records = maintenanceProvider.getRecordsByBikeId(widget.bikeId);
    } else {
      _records = maintenanceProvider.getMaintenanceByType(
          widget.bikeId, _selectedFilter);
    }

    setState(() {});
  }

  Future<void> _navigateToMaintenanceEntry() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceEntryScreen(
          bikeId: widget.bikeId,
        ),
      ),
    );

    if (result != null) {
      _loadData();
    }
  }

  Future<void> _navigateToEditMaintenance(MaintenanceRecord record) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceEntryScreen(
          bikeId: widget.bikeId,
          existingRecord: record,
        ),
      ),
    );

    if (result != null) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Maintenance History',
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: AppColors.current.onPrimary,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildFilterSheet(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToMaintenanceEntry,
        backgroundColor: AppColors.current.primary,
        foregroundColor: AppColors.current.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? EmptyState(
                  icon: Icons.build_outlined,
                  title: 'No Maintenance Records',
                  message:
                      'You haven\'t recorded any maintenance for this bike yet.',
                  actionText: 'Add Maintenance',
                  onAction: _navigateToMaintenanceEntry,
                )
              : ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return _buildMaintenanceItem(record);
                  },
                ),
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filter by Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.current.text,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final option = _filterOptions[index];
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _selectedFilter,
                  activeColor: AppColors.current.primary,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedFilter = value;
                      });
                      _applyFilter();
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceItem(MaintenanceRecord record) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToEditMaintenance(record),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      record.type,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: record.status == MaintenanceStatus.completed
                          ? AppColors.current.success.withOpacity(0.2)
                          : AppColors.current.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      record.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: record.status == MaintenanceStatus.completed
                            ? AppColors.current.success
                            : AppColors.current.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.current.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(record.date),
                    style: TextStyle(
                      color: AppColors.current.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.speed,
                    size: 16,
                    color: AppColors.current.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${record.odometer.toStringAsFixed(0)} km',
                    style: TextStyle(
                      color: AppColors.current.textSecondary,
                    ),
                  ),
                ],
              ),
              if (record.cost != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: AppColors.current.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatCurrency(record.cost!),
                      style: TextStyle(
                        color: AppColors.current.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (record.shopName != null && record.shopName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 16,
                      color: AppColors.current.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      record.shopName!,
                      style: TextStyle(
                        color: AppColors.current.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (record.description != null &&
                  record.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  record.description!,
                  style: TextStyle(
                    color: AppColors.current.text,
                  ),
                ),
              ],
              if (record.isRecurring) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 16,
                      color: AppColors.current.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recurring maintenance',
                      style: TextStyle(
                        color: AppColors.current.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}