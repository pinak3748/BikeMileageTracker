import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bike.dart';
import '../../providers/bike_provider.dart';
import '../../utils/constants.dart';

class BikeProfileScreen extends StatefulWidget {
  final Bike? bike;
  final bool isEditing;

  const BikeProfileScreen({
    super.key,
    this.bike,
    this.isEditing = false,
  });

  @override
  State<BikeProfileScreen> createState() => _BikeProfileScreenState();
}

class _BikeProfileScreenState extends State<BikeProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _vinController;
  late TextEditingController _licensePlateController;
  late TextEditingController _purchaseDateController;
  late TextEditingController _initialOdometerController;
  late TextEditingController _colorController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if editing
    _nameController = TextEditingController(text: widget.bike?.name ?? '');
    _makeController = TextEditingController(text: widget.bike?.make ?? '');
    _modelController = TextEditingController(text: widget.bike?.model ?? '');
    _yearController = TextEditingController(text: widget.bike?.year?.toString() ?? '');
    _vinController = TextEditingController(text: widget.bike?.vin ?? '');
    _licensePlateController = TextEditingController(text: widget.bike?.licensePlate ?? '');
    _purchaseDateController = TextEditingController(text: widget.bike?.purchaseDate?.toString().split(' ')[0] ?? '');
    _initialOdometerController = TextEditingController(text: widget.bike?.initialOdometer?.toString() ?? '');
    _colorController = TextEditingController(text: widget.bike?.color ?? '');
    _notesController = TextEditingController(text: widget.bike?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _licensePlateController.dispose();
    _purchaseDateController.dispose();
    _initialOdometerController.dispose();
    _colorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _purchaseDateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Edit Motorcycle' : 'Add Motorcycle';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 16),
              
              // Basic Info Section
              _buildSectionTitle('Basic Information'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname *',
                  hintText: 'e.g. My Cruiser',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for your motorcycle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _makeController,
                      decoration: const InputDecoration(
                        labelText: 'Make *',
                        hintText: 'e.g. Honda',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model *',
                        hintText: 'e.g. CBR 600',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        labelText: 'Year *',
                        hintText: 'e.g. 2020',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a valid year';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        hintText: 'e.g. Red',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Details Section
              _buildSectionTitle('Details'),
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(
                  labelText: 'VIN',
                  hintText: 'Vehicle Identification Number',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'License Plate',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _purchaseDateController,
                decoration: InputDecoration(
                  labelText: 'Purchase Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _initialOdometerController,
                decoration: const InputDecoration(
                  labelText: 'Initial Odometer *',
                  hintText: 'e.g. 0',
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Notes Section
              _buildSectionTitle('Notes'),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  hintText: 'Any other details about your motorcycle',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              // Save Button
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  widget.isEditing ? 'Save Changes' : 'Add Motorcycle',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () {
        // Will implement image picker in the next phase
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image picker will be implemented in the next phase'),
          ),
        );
      },
      child: Center(
        child: CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.lightBackground,
          child: widget.bike?.imageUrl == null
              ? Icon(
                  Icons.motorcycle,
                  size: 60,
                  color: AppColors.primary,
                )
              : null,
        ),
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final bike = Bike(
        id: widget.bike?.id,
        name: _nameController.text,
        make: _makeController.text,
        model: _modelController.text,
        year: int.tryParse(_yearController.text),
        color: _colorController.text,
        vin: _vinController.text,
        licensePlate: _licensePlateController.text,
        purchaseDate: _purchaseDateController.text.isNotEmpty
            ? DateTime.parse(_purchaseDateController.text)
            : null,
        initialOdometer: double.tryParse(_initialOdometerController.text) ?? 0,
        currentOdometer: widget.bike?.currentOdometer ?? double.tryParse(_initialOdometerController.text) ?? 0,
        notes: _notesController.text,
        imageUrl: widget.bike?.imageUrl,
      );

      final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
      
      if (widget.isEditing) {
        bikeProvider.updateBike(bike);
      } else {
        bikeProvider.addBike(bike);
      }

      Navigator.of(context).pop();
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Motorcycle?'),
        content: const Text(
          'This will permanently delete this motorcycle and all associated data including fuel entries, maintenance records, and documents. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
              if (widget.bike?.id != null) {
                bikeProvider.deleteBike(widget.bike!.id!);
              }
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}