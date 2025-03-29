import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/fuel_entry.dart';
import '../../models/fill_type.dart';
import '../../providers/bike_provider.dart';
import '../../providers/fuel_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';

class FuelEntryScreen extends StatefulWidget {
  final FuelEntry? entry;
  final bool isEditing;

  const FuelEntryScreen({
    super.key,
    this.entry,
    this.isEditing = false,
  });

  @override
  State<FuelEntryScreen> createState() => _FuelEntryScreenState();
}

class _FuelEntryScreenState extends State<FuelEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final _odometerController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pricePerUnitController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _stationController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  DateTime _selectedDate = DateTime.now();
  FillType _fillType = FillType.full;
  String? _selectedFuelType;

  @override
  void initState() {
    super.initState();
    
    // If editing, populate form with existing data
    if (widget.isEditing && widget.entry != null) {
      final entry = widget.entry!;
      _odometerController.text = entry.odometer.toString();
      _quantityController.text = entry.quantity.toString();
      _pricePerUnitController.text = entry.costPerUnit.toString();
      _totalCostController.text = entry.totalCost.toString();
      _stationController.text = entry.station ?? '';
      _notesController.text = entry.notes ?? '';
      _selectedDate = entry.date;
      _fillType = entry.fillType;
      _selectedFuelType = entry.fuelType;
    } else {
      // For new entries, pre-fill with current odometer reading
      final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
      if (bikeProvider.currentBike != null) {
        _odometerController.text = bikeProvider.currentBike!.currentOdometer.toString();
      }
    }

    // Add listeners for automatic calculations
    _quantityController.addListener(_calculateTotalCost);
    _pricePerUnitController.addListener(_calculateTotalCost);
    _totalCostController.addListener(_calculatePricePerUnit);
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _quantityController.dispose();
    _pricePerUnitController.dispose();
    _totalCostController.dispose();
    _stationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotalCost() {
    if (_quantityController.text.isNotEmpty && _pricePerUnitController.text.isNotEmpty) {
      try {
        final quantity = double.parse(_quantityController.text);
        final pricePerUnit = double.parse(_pricePerUnitController.text);
        final totalCost = quantity * pricePerUnit;
        
        // Update total cost without triggering its listener
        _totalCostController.removeListener(_calculatePricePerUnit);
        _totalCostController.text = totalCost.toStringAsFixed(2);
        _totalCostController.addListener(_calculatePricePerUnit);
      } catch (e) {
        // Handle parsing errors
      }
    }
  }

  void _calculatePricePerUnit() {
    if (_quantityController.text.isNotEmpty && _totalCostController.text.isNotEmpty) {
      try {
        final quantity = double.parse(_quantityController.text);
        final totalCost = double.parse(_totalCostController.text);
        
        if (quantity > 0) {
          final pricePerUnit = totalCost / quantity;
          
          // Update price per unit without triggering its listener
          _pricePerUnitController.removeListener(_calculateTotalCost);
          _pricePerUnitController.text = pricePerUnit.toStringAsFixed(2);
          _pricePerUnitController.addListener(_calculateTotalCost);
        }
      } catch (e) {
        // Handle parsing errors
      }
    }
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

  Future<void> _saveFuelEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
      final fuelProvider = Provider.of<FuelProvider>(context, listen: false);

      if (bikeProvider.currentBike == null) {
        throw Exception('No bike selected');
      }

      final odometer = double.parse(_odometerController.text);
      final quantity = double.parse(_quantityController.text);
      final costPerUnit = double.parse(_pricePerUnitController.text);
      final totalCost = double.parse(_totalCostController.text);
      final station = _stationController.text.isEmpty ? null : _stationController.text;
      final notes = _notesController.text.isEmpty ? null : _notesController.text;

      if (widget.isEditing && widget.entry != null) {
        // Update existing entry
        final updatedEntry = widget.entry!.copyWith(
          date: _selectedDate,
          odometer: odometer,
          quantity: quantity,
          costPerUnit: costPerUnit,
          totalCost: totalCost,
          fillType: _fillType,
          fuelType: _selectedFuelType,
          station: station,
          notes: notes,
        );

        await fuelProvider.updateFuelEntry(updatedEntry);
      } else {
        // Create new entry
        final newEntry = FuelEntry(
          bikeId: bikeProvider.currentBike!.id!,
          date: _selectedDate,
          odometer: odometer,
          quantity: quantity,
          costPerUnit: costPerUnit,
          totalCost: totalCost,
          fillType: _fillType,
          fuelType: _selectedFuelType,
          station: station,
          notes: notes,
        );

        await fuelProvider.addFuelEntry(newEntry);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving fuel entry: $error'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Fill-Up' : 'Add Fill-Up'),
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

                    // Fill Type
                    Row(
                      children: [
                        const Text('Fill Type:'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SegmentedButton<FillType>(
                            segments: const [
                              ButtonSegment<FillType>(
                                value: FillType.full,
                                label: Text('Full Tank'),
                                icon: Icon(Icons.check_circle),
                              ),
                              ButtonSegment<FillType>(
                                value: FillType.partial,
                                label: Text('Partial'),
                                icon: Icon(Icons.radio_button_unchecked),
                              ),
                            ],
                            selected: {_fillType},
                            onSelectionChanged: (Set<FillType> selected) {
                              setState(() {
                                _fillType = selected.first;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quantity and Cost per Unit
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quantity
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              suffixText: 'L',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final quantity = double.tryParse(value);
                              if (quantity == null || quantity <= 0) {
                                return 'Must be > 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Cost per Unit
                        Expanded(
                          child: TextFormField(
                            controller: _pricePerUnitController,
                            decoration: const InputDecoration(
                              labelText: 'Price/Liter',
                              prefixText: '\$',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return 'Must be > 0';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Total Cost
                    TextFormField(
                      controller: _totalCostController,
                      decoration: const InputDecoration(
                        labelText: 'Total Cost',
                        prefixText: '\$',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final cost = double.tryParse(value);
                        if (cost == null || cost <= 0) {
                          return 'Must be > 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fuel Type
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Fuel Type',
                      ),
                      value: _selectedFuelType,
                      items: AppConstants.fuelTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFuelType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Station
                    TextFormField(
                      controller: _stationController,
                      decoration: const InputDecoration(
                        labelText: 'Gas Station (Optional)',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveFuelEntry,
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
        title: const Text('Delete Fill-Up'),
        content: const Text(
          'Are you sure you want to delete this fill-up? This action cannot be undone.',
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
                final fuelProvider = Provider.of<FuelProvider>(context, listen: false);
                await fuelProvider.deleteFuelEntry(widget.entry!.id!, widget.entry!.bikeId);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting fuel entry: $error'),
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
