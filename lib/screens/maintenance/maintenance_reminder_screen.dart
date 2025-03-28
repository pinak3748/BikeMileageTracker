import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/maintenance.dart';
import '../../providers/bike_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';

class MaintenanceReminderScreen extends StatefulWidget {
  final MaintenanceReminder? reminder;
  final bool isEditing;

  const MaintenanceReminderScreen({
    super.key,
    this.reminder,
    this.isEditing = false,
  });

  @override
  State<MaintenanceReminderScreen> createState() => _MaintenanceReminderScreenState();
}

class _MaintenanceReminderScreenState extends State<MaintenanceReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _distanceController = TextEditingController();

  // Form state
  DateTime? _selectedDate;
  String? _selectedMaintenanceType;
  ReminderType _reminderType = ReminderType.date;

  @override
  void initState() {
    super.initState();
    
    // If editing, populate form with existing data
    if (widget.isEditing && widget.reminder != null) {
      final reminder = widget.reminder!;
      _titleController.text = reminder.title;
      _selectedMaintenanceType = reminder.maintenanceType;
      
      if (reminder.dueDate != null) {
        _selectedDate = reminder.dueDate;
      }
      
      if (reminder.dueDistance != null) {
        _distanceController.text = reminder.dueDistance.toString();
      }
      
      _reminderType = reminder.reminderType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation based on reminder type
    if (_reminderType == ReminderType.date && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a due date'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    } else if (_reminderType == ReminderType.distance && _distanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a due distance'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    } else if (_reminderType == ReminderType.both && 
              (_selectedDate == null || _distanceController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both date and distance'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
      final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);

      if (bikeProvider.currentBike == null) {
        throw Exception('No bike selected');
      }

      final title = _titleController.text;
      double? dueDistance;
      if (_reminderType == ReminderType.distance || _reminderType == ReminderType.both) {
        dueDistance = double.parse(_distanceController.text);
      }

      if (widget.isEditing && widget.reminder != null) {
        // Update existing reminder
        final updatedReminder = widget.reminder!.copyWith(
          title: title,
          maintenanceType: _selectedMaintenanceType!,
          dueDate: _reminderType == ReminderType.distance ? null : _selectedDate,
          dueDistance: dueDistance,
          reminderType: _reminderType,
        );

        await maintenanceProvider.updateReminder(updatedReminder);
      } else {
        // Create new reminder
        final newReminder = MaintenanceReminder(
          bikeId: bikeProvider.currentBike!.id!,
          title: title,
          maintenanceType: _selectedMaintenanceType!,
          dueDate: _reminderType == ReminderType.distance ? null : _selectedDate,
          dueDistance: dueDistance,
          reminderType: _reminderType,
        );

        await maintenanceProvider.addReminder(newReminder);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving reminder: $error'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Reminder' : 'Set Maintenance Reminder'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Reminder Title',
                        hintText: 'E.g., Oil Change, Chain Lubrication',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Maintenance Type
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Maintenance Type',
                      ),
                      value: _selectedMaintenanceType,
                      items: AppConstants.maintenanceTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMaintenanceType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a maintenance type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Reminder Type
                    Text(
                      'Reminder Type:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<ReminderType>(
                      segments: const [
                        ButtonSegment<ReminderType>(
                          value: ReminderType.date,
                          label: Text('By Date'),
                          icon: Icon(Icons.calendar_today),
                        ),
                        ButtonSegment<ReminderType>(
                          value: ReminderType.distance,
                          label: Text('By Distance'),
                          icon: Icon(Icons.speed),
                        ),
                        ButtonSegment<ReminderType>(
                          value: ReminderType.both,
                          label: Text('Both'),
                          icon: Icon(Icons.all_inclusive),
                        ),
                      ],
                      selected: {_reminderType},
                      onSelectionChanged: (Set<ReminderType> selected) {
                        setState(() {
                          _reminderType = selected.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Date Picker (for Date or Both)
                    if (_reminderType == ReminderType.date || _reminderType == ReminderType.both) ...[
                      Text(
                        'Due Date:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _selectedDate != null
                                ? DateFormatter.formatDate(_selectedDate!)
                                : 'Select a date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Distance Input (for Distance or Both)
                    if (_reminderType == ReminderType.distance || _reminderType == ReminderType.both) ...[
                      Text(
                        'Due at Odometer:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _distanceController,
                        decoration: const InputDecoration(
                          hintText: 'Enter odometer reading',
                          suffixText: 'km',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (_reminderType == ReminderType.distance || _reminderType == ReminderType.both)
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a distance';
                                }
                                final distance = double.tryParse(value);
                                if (distance == null) {
                                  return 'Invalid number';
                                }
                                final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
                                if (bikeProvider.currentBike != null &&
                                    distance <= bikeProvider.currentBike!.currentOdometer) {
                                  return 'Must be greater than current odometer';
                                }
                                return null;
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Current odometer reading display
                      Consumer<BikeProvider>(
                        builder: (ctx, bikeProvider, _) {
                          if (bikeProvider.currentBike != null) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                'Current odometer: ${DateFormatter.formatDistance(bikeProvider.currentBike!.currentOdometer)}',
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveReminder,
                        child: Text(widget.isEditing ? 'Update' : 'Set Reminder'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text(
          'Are you sure you want to delete this reminder? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() {
                _isLoading = true;
              });

              try {
                final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
                await maintenanceProvider.deleteReminder(widget.reminder!.id!);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting reminder: $error'),
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
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
