import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:moto_tracker/models/bike.dart';
import 'package:moto_tracker/models/maintenance_record.dart';
import 'package:moto_tracker/providers/bikes_provider.dart';
import 'package:moto_tracker/providers/maintenance_provider.dart';
import 'package:moto_tracker/screens/maintenance/maintenance_entry_screen.dart';
import 'package:moto_tracker/screens/maintenance/maintenance_reminder_screen.dart';
import 'package:moto_tracker/utils/constants.dart';
import 'package:moto_tracker/utils/helpers.dart';
import 'package:moto_tracker/widgets/app_bar.dart';
import 'package:moto_tracker/widgets/empty_state.dart';

class MaintenanceReminderListScreen extends StatefulWidget {
  final String bikeId;

  const MaintenanceReminderListScreen({
    Key? key,
    required this.bikeId,
  }) : super(key: key);

  @override
  _MaintenanceReminderListScreenState createState() =>
      _MaintenanceReminderListScreenState();
}

class _MaintenanceReminderListScreenState extends State<MaintenanceReminderListScreen> {
  bool _isLoading = true;
  late Bike _bike;
  List<MaintenanceRecord> _reminders = [];

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
      await maintenanceProvider.loadMaintenanceReminders(widget.bikeId);

      if (mounted) {
        setState(() {
          _bike = bike;
          _reminders = maintenanceProvider.getUpcomingMaintenance(widget.bikeId);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading maintenance reminders: $e')),
        );
      }
    }
  }

  void _navigateToAddReminder() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceReminderScreen(
          bikeId: widget.bikeId,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToEditReminder(MaintenanceRecord reminder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceReminderScreen(
          bikeId: widget.bikeId,
          existingReminder: reminder,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _markReminderAsComplete(MaintenanceRecord reminder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceEntryScreen(
          bikeId: widget.bikeId,
          existingRecord: reminder.copyWith(status: MaintenanceStatus.pending),
        ),
      ),
    ).then((_) => _loadData());
  }

  void _deleteReminder(MaintenanceRecord reminder) {
    showConfirmationDialog(
      context,
      title: 'Delete Reminder',
      message: 'Are you sure you want to delete this maintenance reminder?',
      confirmText: 'Delete',
    ).then((confirmed) async {
      if (confirmed) {
        setState(() {
          _isLoading = true;
        });
        
        try {
          final maintenanceProvider = 
              Provider.of<MaintenanceProvider>(context, listen: false);
          await maintenanceProvider.deleteMaintenanceRecord(reminder.id!);
          _loadData();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting reminder: $e')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Maintenance Reminders'),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddReminder,
        backgroundColor: AppColors.current.primary,
        foregroundColor: AppColors.current.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? EmptyState(
                  icon: Icons.notifications_none,
                  title: 'No Maintenance Reminders',
                  message:
                      'You haven\'t set up any maintenance reminders for this bike yet.',
                  actionText: 'Add Reminder',
                  onAction: _navigateToAddReminder,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    return _buildReminderItem(reminder);
                  },
                ),
    );
  }

  Widget _buildReminderItem(MaintenanceRecord reminder) {
    final dueDate = reminder.nextDueDate ?? reminder.date;
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    
    final bool isOverdue = daysUntilDue < 0;
    final bool isDueSoon = daysUntilDue >= 0 && daysUntilDue <= 7;
    
    Color statusColor = AppColors.current.success;
    String statusText = 'Upcoming';
    
    if (isOverdue) {
      statusColor = AppColors.current.error;
      statusText = 'Overdue';
    } else if (isDueSoon) {
      statusColor = AppColors.current.warning;
      statusText = 'Due Soon';
    }
    
    return Dismissible(
      key: Key(reminder.id!),
      background: Container(
        color: AppColors.current.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showConfirmationDialog(
          context,
          title: 'Delete Reminder',
          message: 'Are you sure you want to delete this maintenance reminder?',
          confirmText: 'Delete',
        );
      },
      onDismissed: (direction) {
        _deleteReminder(reminder);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isOverdue
                        ? '${-daysUntilDue} days overdue'
                        : daysUntilDue == 0
                            ? 'Due today'
                            : 'Due in $daysUntilDue days',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => _navigateToEditReminder(reminder),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            reminder.type,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.current.text,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: AppColors.current.primary,
                            size: 20,
                          ),
                          onPressed: () => _navigateToEditReminder(reminder),
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
                          'Due: ${DateFormat('MMM dd, yyyy').format(dueDate)}',
                          style: TextStyle(
                            color: AppColors.current.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (reminder.odometer != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            size: 16,
                            color: AppColors.current.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Odometer: ${reminder.odometer.toStringAsFixed(0)} km',
                            style: TextStyle(
                              color: AppColors.current.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        reminder.description!,
                        style: TextStyle(
                          color: AppColors.current.text,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _markReminderAsComplete(reminder),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.current.success,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Mark as Completed'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}