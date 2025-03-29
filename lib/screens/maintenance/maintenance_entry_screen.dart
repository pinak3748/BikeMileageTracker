import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/maintenance.dart';
import '../../providers/bike_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';

class MaintenanceEntryScreen extends StatefulWidget {
  final Maintenance? maintenance;
  final bool isEditing;
  final bool isFromReminder;
  final MaintenanceReminder? reminder;

  const MaintenanceEntryScreen({
    super.key,
    this.maintenance,
    this.isEditing = false,
    this.isFromReminder = false,
    this.reminder,
  });

  @override
  State<MaintenanceEntryScreen> createState() => _MaintenanceEntryScreenState();
}

class _MaintenanceEntryScreenState extends State<MaintenanceEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _partsReplacedController = TextEditingController();
  final _serviceProviderController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  DateTime _selectedDate = DateTime.now();
  String? _selectedMaintenanceType;
  MaintenanceStatus _status = MaintenanceStatus.completed;
  File? _receiptImage;
  String? _receiptPath;

  @override
  void initState() {
    super.initState();
    
    // If editing, populate form with existing data
    if (widget.isEditing && widget.maintenance != null) {
      final maintenance = widget.maintenance!;
      _titleController.text = maintenance.title;
      _odometerController.text = maintenance.odometer.toString();
      _costController.text = maintenance.cost.toString();
      _partsReplacedController.text = maintenance.partsReplaced ?? '';
      _serviceProviderController.text = maintenance.serviceProvider ?? '';
      _notesController.text = maintenance.notes ?? '';
      _selectedDate = maintenance.date;
      _selectedMaintenanceType = maintenance.maintenanceType;
      _status = maintenance.status;
      _receiptPath = maintenance.receiptUrl;
    } 
    // If from reminder, pre-fill with reminder data
    else if (widget.isFromReminder && widget.reminder != null) {
      final reminder = widget.reminder!;
      _titleController.text = reminder.title;
      _selectedMaintenanceType = reminder.maintenanceType;
      
      // For new entries, pre-fill with current odometer reading
      final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
      if (bikeProvider.currentBike != null) {
        _odometerController.text = bikeProvider.currentBike!.currentOdometer.toString();
      }
    }
    // For new entries
    else {
      // Pre-fill with current odometer reading
      final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
      if (bikeProvider.currentBike != null) {
        _odometerController.text = bikeProvider.currentBike!.currentOdometer.toString();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _odometerController.dispose();
    _costController.dispose();
    _partsReplacedController.dispose();
    _serviceProviderController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickReceiptImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _receiptImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.current.danger,
        ),
      );
    }
  }

  Future<void> _saveMaintenance() async {
    if (!_formKey.currentState!.validate()) {
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
      final odometer = double.parse(_odometerController.text);
      final cost = double.parse(_costController.text);
      final partsReplaced = _partsReplacedController.text.isEmpty ? null : _partsReplacedController.text;
      final serviceProvider = _serviceProviderController.text.isEmpty ? null : _serviceProviderController.text;
      final notes = _notesController.text.isEmpty ? null : _notesController.text;

      if (widget.isEditing && widget.maintenance != null) {
        // Update existing entry
        final updatedMaintenance = widget.maintenance!.copyWith(
          title: title,
          date: _selectedDate,
          odometer: odometer,
          cost: cost,
          maintenanceType: _selectedMaintenanceType!,
          partsReplaced: partsReplaced,
          serviceProvider: serviceProvider,
          notes: notes,
          status: _status,
          // Handling receipt URL would require more complex logic for file upload/update
        );

        await maintenanceProvider.updateMaintenance(updatedMaintenance);
      } else {
        // Create new entry
        final newMaintenance = Maintenance(
          bikeId: bikeProvider.currentBike!.id!,
          title: title,
          date: _selectedDate,
          odometer: odometer,
          cost: cost,
          maintenanceType: _selectedMaintenanceType!,
          partsReplaced: partsReplaced,
          serviceProvider: serviceProvider,
          notes: notes,
          status: _status,
          // Handling receipt URL would require more complex logic for file upload
        );

        if (widget.isFromReminder && widget.reminder != null) {
          // Complete the reminder
          await maintenanceProvider.completeReminder(widget.reminder!.id!, newMaintenance);
        } else {
          // Just add maintenance
          await maintenanceProvider.addMaintenance(newMaintenance, bikeProvider.currentBike!);
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving maintenance: $error'),
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

  @override
  Widget build(BuildContext context) {
    String title = 'Add Maintenance';
    if (widget.isEditing) {
      title = 'Edit Maintenance';
    } else if (widget.isFromReminder) {
      title = 'Complete Maintenance';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.current.accent))
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
                        labelText: 'Maintenance Title',
                        hintText: 'E.g., Oil Change, Chain Cleaning',
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
                    const SizedBox(height: 16),

                    // Date and Odometer
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Picker
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormatter.formatDate(_selectedDate),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Odometer
                        Expanded(
                          child: TextFormField(
                            controller: _odometerController,
                            decoration: const InputDecoration(
                              labelText: 'Odometer',
                              suffixText: 'km',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final odometer = double.tryParse(value);
                              if (odometer == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Cost
                    TextFormField(
                      controller: _costController,
                      decoration: const InputDecoration(
                        labelText: 'Cost',
                        prefixText: '\$',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final cost = double.tryParse(value);
                        if (cost == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Parts Replaced
                    TextFormField(
                      controller: _partsReplacedController,
                      decoration: const InputDecoration(
                        labelText: 'Parts Replaced (Optional)',
                        hintText: 'E.g., Oil filter, brake pads',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Service Provider
                    TextFormField(
                      controller: _serviceProviderController,
                      decoration: const InputDecoration(
                        labelText: 'Service Provider (Optional)',
                        hintText: 'E.g., Dealer name, mechanic',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Add any additional details here',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Receipt Image
                    if (widget.isEditing && _receiptPath != null) ...[
                      Text(
                        'Existing Receipt:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_receiptPath!),
                      const SizedBox(height: 16),
                    ],

                    if (_receiptImage != null) ...[
                      Text(
                        'Selected Receipt:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: Image.file(_receiptImage!),
                      ),
                      const SizedBox(height: 16),
                    ],

                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Add Receipt Photo'),
                      onPressed: _pickReceiptImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Status (only for editing)
                    if (widget.isEditing) ...[
                      Text(
                        'Status:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<MaintenanceStatus>(
                        segments: [
                          ButtonSegment<MaintenanceStatus>(
                            value: MaintenanceStatus.completed,
                            label: const Text('Completed'),
                            icon: const Icon(Icons.check_circle),
                          ),
                          ButtonSegment<MaintenanceStatus>(
                            value: MaintenanceStatus.scheduled,
                            label: const Text('Scheduled'),
                            icon: const Icon(Icons.schedule),
                          ),
                          ButtonSegment<MaintenanceStatus>(
                            value: MaintenanceStatus.overdue,
                            label: const Text('Overdue'),
                            icon: const Icon(Icons.warning),
                          ),
                        ],
                        selected: {_status},
                        onSelectionChanged: (Set<MaintenanceStatus> selected) {
                          setState(() {
                            _status = selected.first;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveMaintenance,
                        child: Text(widget.isEditing ? 'Update' : 'Save'),
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
        title: const Text('Delete Maintenance'),
        content: const Text(
          'Are you sure you want to delete this maintenance record? This action cannot be undone.',
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
                await maintenanceProvider.deleteMaintenance(widget.maintenance!.id!);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting maintenance: $error'),
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
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.current.danger),
            ),
          ),
        ],
      ),
    );
  }
}
