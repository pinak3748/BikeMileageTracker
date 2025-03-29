import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:moto_tracker/models/bike.dart';
import 'package:moto_tracker/models/maintenance_record.dart';
import 'package:moto_tracker/models/maintenance_status.dart';
import 'package:moto_tracker/models/reminder_type.dart';
import 'package:moto_tracker/providers/bikes_provider.dart';
import 'package:moto_tracker/providers/maintenance_provider.dart';
import 'package:moto_tracker/utils/constants.dart';
import 'package:moto_tracker/utils/helpers.dart';
import 'package:moto_tracker/widgets/app_bar.dart';
import 'package:moto_tracker/widgets/custom_dropdown.dart';

class MaintenanceReminderScreen extends StatefulWidget {
  final String bikeId;
  final MaintenanceRecord? existingReminder;

  const MaintenanceReminderScreen({
    Key? key,
    required this.bikeId,
    this.existingReminder,
  }) : super(key: key);

  @override
  _MaintenanceReminderScreenState createState() =>
      _MaintenanceReminderScreenState();
}

class _MaintenanceReminderScreenState extends State<MaintenanceReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _odometerController;
  late TextEditingController _descriptionController;
  late TextEditingController _intervalDistanceController;
  late TextEditingController _intervalTimeController;
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 90));
  bool _isLoading = false;
  late Bike _bike;
  String _selectedMaintenanceType = '';
  ReminderType _reminderType = ReminderType.time;
  bool _isOdometerBased = false;
  bool _isTimeBased = true;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(
        text: widget.existingReminder?.type ?? '');
    _odometerController = TextEditingController(
        text: (widget.existingReminder?.odometer ?? 0).toString());
    _descriptionController = TextEditingController(
        text: widget.existingReminder?.description ?? '');
    _intervalDistanceController = TextEditingController(
        text: widget.existingReminder?.intervalDistance?.toString() ?? '1000');
    _intervalTimeController = TextEditingController(
        text: widget.existingReminder?.intervalDays?.toString() ?? '90');

    if (widget.existingReminder != null) {
      _nextDueDate = widget.existingReminder!.nextDueDate ?? DateTime.now().add(const Duration(days: 90));
      _selectedMaintenanceType = widget.existingReminder!.type;
      
      if (widget.existingReminder!.reminderType != null) {
        _reminderType = widget.existingReminder!.reminderType!;
      }
      
      // Set checkbox states based on reminder type
      _isOdometerBased = _reminderType == ReminderType.odometer || _reminderType == ReminderType.both;
      _isTimeBased = _reminderType == ReminderType.time || _reminderType == ReminderType.both;
    } else {
      _selectedMaintenanceType = AppConstants.maintenanceTypes.first;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBikeData();
    });
  }

  Future<void> _loadBikeData() async {
    final bikesProvider = Provider.of<BikesProvider>(context, listen: false);
    final bike = await bikesProvider.getBike(widget.bikeId);
    
    if (mounted) {
      setState(() {
        _bike = bike;
        if (widget.existingReminder == null) {
          _odometerController.text = bike.currentOdometer.toString();
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // 2 years ahead
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.current.primary,
              onPrimary: AppColors.current.onPrimary,
              onSurface: AppColors.current.text,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _nextDueDate) {
      setState(() {
        _nextDueDate = picked;
      });
    }
  }

  void _updateReminderType() {
    if (_isOdometerBased && _isTimeBased) {
      _reminderType = ReminderType.both;
    } else if (_isOdometerBased) {
      _reminderType = ReminderType.odometer;
    } else if (_isTimeBased) {
      _reminderType = ReminderType.time;
    } else {
      // Default if none selected
      _reminderType = ReminderType.time;
      _isTimeBased = true;
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Make sure at least one reminder type is selected
    if (!_isOdometerBased && !_isTimeBased) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one reminder type')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
    
    try {
      // Update reminder type
      _updateReminderType();
      
      // Get type from controller or dropdown
      final maintenanceType = _typeController.text.isNotEmpty
          ? _typeController.text
          : _selectedMaintenanceType;
          
      if (widget.existingReminder != null) {
        // Update existing reminder
        final updatedReminder = widget.existingReminder!.copyWith(
          type: maintenanceType,
          odometer: double.parse(_odometerController.text),
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          nextDueDate: _nextDueDate,
          reminderType: _reminderType,
          isRecurring: true,
          status: MaintenanceStatus.scheduled,
          intervalDistance: _isOdometerBased && _intervalDistanceController.text.isNotEmpty 
              ? double.parse(_intervalDistanceController.text) 
              : null,
          intervalDays: _isTimeBased && _intervalTimeController.text.isNotEmpty 
              ? int.parse(_intervalTimeController.text) 
              : null,
        );
        
        await maintenanceProvider.updateMaintenanceReminder(updatedReminder);
      } else {
        // Create new reminder
        final newReminder = MaintenanceRecord(
          bikeId: widget.bikeId,
          type: maintenanceType,
          date: DateTime.now(),
          odometer: double.parse(_odometerController.text),
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          nextDueDate: _nextDueDate,
          reminderType: _reminderType,
          isRecurring: true,
          status: MaintenanceStatus.scheduled,
          intervalDistance: _isOdometerBased && _intervalDistanceController.text.isNotEmpty 
              ? double.parse(_intervalDistanceController.text) 
              : null,
          intervalDays: _isTimeBased && _intervalTimeController.text.isNotEmpty 
              ? int.parse(_intervalTimeController.text) 
              : null,
        );
        
        await maintenanceProvider.addMaintenanceReminder(newReminder);
      }
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving reminder: $e')),
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
  void dispose() {
    _typeController.dispose();
    _odometerController.dispose();
    _descriptionController.dispose();
    _intervalDistanceController.dispose();
    _intervalTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReminder != null;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Reminder' : 'Add Reminder',
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(
                Icons.delete,
                color: AppColors.current.error,
              ),
              onPressed: () {
                // Show confirmation dialog
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
                      final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
                      await maintenanceProvider.deleteMaintenanceRecord(widget.existingReminder!.id!);
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting reminder: $e')),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  }
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Maintenance Type Dropdown
                      CustomDropdown<String>(
                        label: 'Maintenance Type',
                        value: _selectedMaintenanceType,
                        items: AppConstants.maintenanceTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMaintenanceType = value;
                              if (_typeController.text.isEmpty || 
                                  AppConstants.maintenanceTypes.contains(_typeController.text)) {
                                _typeController.text = value;
                              }
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Custom Type Input (if needed)
                      TextFormField(
                        controller: _typeController,
                        decoration: const InputDecoration(
                          labelText: 'Custom Type (if not listed above)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Next Due Date Picker
                      Text(
                        'Next Due Date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.current.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMMM dd, yyyy').format(_nextDueDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.current.text,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.current.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Current Odometer Reading
                      TextFormField(
                        controller: _odometerController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Current Odometer Reading (km)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the odometer reading';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Reminder Type Section
                      Text(
                        'Reminder Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.current.text,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Checkbox for Time-based
                      CheckboxListTile(
                        title: const Text('Time-based Reminder'),
                        value: _isTimeBased,
                        activeColor: AppColors.current.primary,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _isTimeBased = value;
                              if (!_isTimeBased && !_isOdometerBased) {
                                _isOdometerBased = true;
                              }
                            });
                          }
                        },
                      ),
                      
                      // Interval in days (if time-based)
                      if (_isTimeBased)
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: TextFormField(
                            controller: _intervalTimeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Repeat every (days)',
                              border: OutlineInputBorder(),
                              helperText: 'e.g., 90 for every 3 months',
                            ),
                            validator: (value) {
                              if (_isTimeBased) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the interval';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        
                      const SizedBox(height: 16),
                      
                      // Checkbox for Odometer-based
                      CheckboxListTile(
                        title: const Text('Odometer-based Reminder'),
                        value: _isOdometerBased,
                        activeColor: AppColors.current.primary,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _isOdometerBased = value;
                              if (!_isTimeBased && !_isOdometerBased) {
                                _isTimeBased = true;
                              }
                            });
                          }
                        },
                      ),
                      
                      // Interval in kilometers (if odometer-based)
                      if (_isOdometerBased)
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: TextFormField(
                            controller: _intervalDistanceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Repeat every (km)',
                              border: OutlineInputBorder(),
                              helperText: 'e.g., 5000 for every 5,000 km',
                            ),
                            validator: (value) {
                              if (_isOdometerBased) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the interval';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        
                      const SizedBox(height: 32),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveReminder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.current.primary,
                            foregroundColor: AppColors.current.onPrimary,
                          ),
                          child: Text(
                            isEditing ? 'Update Reminder' : 'Save Reminder',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}