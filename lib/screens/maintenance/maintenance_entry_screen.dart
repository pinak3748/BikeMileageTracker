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

class MaintenanceEntryScreen extends StatefulWidget {
  final String bikeId;
  final MaintenanceRecord? existingRecord;

  const MaintenanceEntryScreen({
    Key? key,
    required this.bikeId,
    this.existingRecord,
  }) : super(key: key);

  @override
  _MaintenanceEntryScreenState createState() => _MaintenanceEntryScreenState();
}

class _MaintenanceEntryScreenState extends State<MaintenanceEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _odometerController;
  late TextEditingController _costController;
  late TextEditingController _shopNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  DateTime _date = DateTime.now();
  bool _isRecurring = false;
  MaintenanceStatus _status = MaintenanceStatus.completed;
  bool _isLoading = false;
  late Bike _bike;
  String _selectedMaintenanceType = '';

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(
        text: widget.existingRecord?.type ?? '');
    _odometerController = TextEditingController(
        text: (widget.existingRecord?.odometer ?? 0).toString());
    _costController = TextEditingController(
        text: (widget.existingRecord?.cost ?? 0).toString());
    _shopNameController = TextEditingController(
        text: widget.existingRecord?.shopName ?? '');
    _descriptionController = TextEditingController(
        text: widget.existingRecord?.description ?? '');
    _notesController = TextEditingController(
        text: widget.existingRecord?.notes ?? '');

    if (widget.existingRecord != null) {
      _date = widget.existingRecord!.date;
      _isRecurring = widget.existingRecord!.isRecurring;
      _status = widget.existingRecord!.status;
      _selectedMaintenanceType = widget.existingRecord!.type;
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
        if (widget.existingRecord == null) {
          _odometerController.text = bike.currentOdometer.toString();
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
    
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _saveMaintenanceRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
    final bikesProvider = Provider.of<BikesProvider>(context, listen: false);
    
    try {
      // Get type from controller or dropdown
      final maintenanceType = _typeController.text.isNotEmpty
          ? _typeController.text
          : _selectedMaintenanceType;
          
      if (widget.existingRecord != null) {
        // Update existing record
        final updatedRecord = widget.existingRecord!.copyWith(
          type: maintenanceType,
          date: _date,
          odometer: double.parse(_odometerController.text),
          cost: _costController.text.isNotEmpty ? double.parse(_costController.text) : null,
          shopName: _shopNameController.text.isNotEmpty ? _shopNameController.text : null,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          isRecurring: _isRecurring,
          status: _status,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
        
        await maintenanceProvider.updateMaintenanceRecord(updatedRecord);
      } else {
        // Create new record
        final newRecord = MaintenanceRecord(
          bikeId: widget.bikeId,
          type: maintenanceType,
          date: _date,
          odometer: double.parse(_odometerController.text),
          cost: _costController.text.isNotEmpty ? double.parse(_costController.text) : null,
          shopName: _shopNameController.text.isNotEmpty ? _shopNameController.text : null,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          isRecurring: _isRecurring,
          status: _status,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
        
        await maintenanceProvider.addMaintenanceRecord(newRecord);
      }
      
      // Update bike's current odometer if the new reading is higher
      final currentOdometer = double.parse(_odometerController.text);
      if (currentOdometer > _bike.currentOdometer) {
        await bikesProvider.updateBikeOdometer(widget.bikeId, currentOdometer);
      }
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving maintenance record: $e')),
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
    _costController.dispose();
    _shopNameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRecord != null;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Maintenance' : 'Add Maintenance',
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
                  title: 'Delete Record',
                  message: 'Are you sure you want to delete this maintenance record?',
                  confirmText: 'Delete',
                ).then((confirmed) async {
                  if (confirmed) {
                    setState(() {
                      _isLoading = true;
                    });
                    
                    try {
                      final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
                      await maintenanceProvider.deleteMaintenanceRecord(widget.existingRecord!.id!);
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting record: $e')),
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
                      
                      // Date Picker
                      Text(
                        'Date',
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
                                DateFormat('MMMM dd, yyyy').format(_date),
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
                      
                      // Odometer Reading
                      TextFormField(
                        controller: _odometerController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Odometer Reading (km)',
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
                      
                      // Cost
                      TextFormField(
                        controller: _costController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Cost (\$)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Shop Name
                      TextFormField(
                        controller: _shopNameController,
                        decoration: const InputDecoration(
                          labelText: 'Shop Name',
                          border: OutlineInputBorder(),
                        ),
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
                      
                      const SizedBox(height: 16),
                      
                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Recurring Checkbox
                      CheckboxListTile(
                        title: const Text('Is Recurring Maintenance?'),
                        value: _isRecurring,
                        activeColor: AppColors.current.primary,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _isRecurring = value;
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Status Dropdown for Editing
                      if (isEditing)
                        CustomDropdown<MaintenanceStatus>(
                          label: 'Status',
                          value: _status,
                          items: MaintenanceStatus.values.map((status) {
                            return DropdownMenuItem<MaintenanceStatus>(
                              value: status,
                              child: Text(status.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _status = value;
                              });
                            }
                          },
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveMaintenanceRecord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.current.primary,
                            foregroundColor: AppColors.current.onPrimary,
                          ),
                          child: Text(
                            isEditing ? 'Update Record' : 'Save Record',
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