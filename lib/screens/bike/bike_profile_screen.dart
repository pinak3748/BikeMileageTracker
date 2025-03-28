import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bike.dart';
import '../../providers/bike_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';

class BikeProfileScreen extends StatefulWidget {
  final bool isEditing;
  final Bike? bike;

  const BikeProfileScreen({
    super.key,
    required this.isEditing,
    this.bike,
  });

  @override
  State<BikeProfileScreen> createState() => _BikeProfileScreenState();
}

class _BikeProfileScreenState extends State<BikeProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _initialOdometerController = TextEditingController();
  final TextEditingController _currentOdometerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _purchaseDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.bike != null) {
      _populateFields();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _vinController.dispose();
    _licensePlateController.dispose();
    _initialOdometerController.dispose();
    _currentOdometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateFields() {
    final bike = widget.bike!;
    _nameController.text = bike.name;
    _makeController.text = bike.make;
    _modelController.text = bike.model;
    _yearController.text = bike.year?.toString() ?? '';
    _colorController.text = bike.color ?? '';
    _vinController.text = bike.vin ?? '';
    _licensePlateController.text = bike.licensePlate ?? '';
    _initialOdometerController.text = bike.initialOdometer.toString();
    _currentOdometerController.text = bike.currentOdometer.toString();
    _notesController.text = bike.notes ?? '';
    _purchaseDate = bike.purchaseDate;
  }

  Future<void> _saveBike() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
      final year = _yearController.text.isNotEmpty
          ? int.parse(_yearController.text)
          : null;
      final initialOdometer = double.parse(_initialOdometerController.text);
      final currentOdometer = double.parse(_currentOdometerController.text);

      if (widget.isEditing && widget.bike != null) {
        final updatedBike = widget.bike!.copyWith(
          name: _nameController.text,
          make: _makeController.text,
          model: _modelController.text,
          year: year,
          color: _colorController.text.isEmpty ? null : _colorController.text,
          vin: _vinController.text.isEmpty ? null : _vinController.text,
          licensePlate: _licensePlateController.text.isEmpty
              ? null
              : _licensePlateController.text,
          purchaseDate: _purchaseDate,
          initialOdometer: initialOdometer,
          currentOdometer: currentOdometer,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        await bikeProvider.updateBike(updatedBike);
      } else {
        final newBike = Bike(
          name: _nameController.text,
          make: _makeController.text,
          model: _modelController.text,
          year: year,
          color: _colorController.text.isEmpty ? null : _colorController.text,
          vin: _vinController.text.isEmpty ? null : _vinController.text,
          licensePlate: _licensePlateController.text.isEmpty
              ? null
              : _licensePlateController.text,
          purchaseDate: _purchaseDate,
          initialOdometer: initialOdometer,
          currentOdometer: currentOdometer,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        await bikeProvider.addBike(newBike);
      }

      // Close the screen after saving
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving bike: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.isEditing ? 'Edit Motorcycle' : 'Add Motorcycle',
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmation(context);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Basic Information'),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name / Nickname',
                      hint: 'My Bike',
                      icon: Icons.label,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _makeController,
                      label: 'Make',
                      hint: 'Honda, Yamaha, Harley-Davidson, etc.',
                      icon: Icons.business,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the make';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _modelController,
                      label: 'Model',
                      hint: 'CBR600RR, MT-09, Road King, etc.',
                      icon: Icons.motorcycle,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the model';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _yearController,
                            label: 'Year',
                            hint: '2023',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _colorController,
                            label: 'Color',
                            hint: 'Red, Black, etc.',
                            icon: Icons.color_lens,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Details'),
                    _buildTextField(
                      controller: _vinController,
                      label: 'VIN',
                      hint: 'Vehicle Identification Number',
                      icon: Icons.pin,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _licensePlateController,
                      label: 'License Plate',
                      hint: 'ABC123',
                      icon: Icons.confirmation_number,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Odometer'),
                    _buildTextField(
                      controller: _initialOdometerController,
                      label: 'Initial Odometer (km)',
                      hint: '0',
                      icon: Icons.speed,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the initial odometer reading';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _currentOdometerController,
                      label: 'Current Odometer (km)',
                      hint: '0',
                      icon: Icons.speed,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the current odometer reading';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        final initial = double.tryParse(_initialOdometerController.text) ?? 0;
                        final current = double.tryParse(value) ?? 0;
                        if (current < initial) {
                          return 'Current odometer cannot be less than initial';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Notes'),
                    _buildTextField(
                      controller: _notesController,
                      label: 'Notes',
                      hint: 'Any additional information about your motorcycle',
                      icon: Icons.note,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveBike,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          widget.isEditing ? 'Update Motorcycle' : 'Add Motorcycle',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Purchase Date'),
            subtitle: Text(
              _purchaseDate != null
                  ? '${_purchaseDate!.month}/${_purchaseDate!.day}/${_purchaseDate!.year}'
                  : 'Select a date',
              style: TextStyle(
                color: _purchaseDate != null ? Colors.black : Colors.grey,
              ),
            ),
            trailing: const Icon(Icons.arrow_drop_down),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Motorcycle'),
        content: const Text(
          'Are you sure you want to delete this motorcycle? All associated data (fuel logs, maintenance records, expenses, etc.) will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() {
                _isLoading = true;
              });
              try {
                final bikeProvider =
                    Provider.of<BikeProvider>(context, listen: false);
                await bikeProvider.deleteBike(widget.bike!.id!);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting motorcycle: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}