import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/expense.dart';
import '../../providers/bike_provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';

class ExpenseEntryScreen extends StatefulWidget {
  final Expense? expense;
  final bool isEditing;
  final String? initialCategory;

  const ExpenseEntryScreen({
    super.key,
    this.expense,
    this.isEditing = false,
    this.initialCategory,
  });

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _odometerController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  File? _receiptImage;
  String? _receiptPath;

  @override
  void initState() {
    super.initState();
    
    // If editing, populate form with existing data
    if (widget.isEditing && widget.expense != null) {
      final expense = widget.expense!;
      _titleController.text = expense.title;
      _amountController.text = expense.amount.toString();
      _odometerController.text = expense.odometer?.toString() ?? '';
      _notesController.text = expense.notes ?? '';
      _selectedDate = expense.date;
      _selectedCategory = expense.category;
      _receiptPath = expense.receiptUrl;
    } 
    // For new entries with pre-selected category
    else if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
    
    // For new entries, pre-fill with current odometer reading
    if (!widget.isEditing) {
      final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
      if (bikeProvider.currentBike != null) {
        _odometerController.text = bikeProvider.currentBike!.currentOdometer.toString();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _odometerController.dispose();
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

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

      if (bikeProvider.currentBike == null) {
        throw Exception('No bike selected');
      }

      final title = _titleController.text;
      final amount = double.parse(_amountController.text);
      double? odometer;
      if (_odometerController.text.isNotEmpty) {
        odometer = double.parse(_odometerController.text);
      }
      final notes = _notesController.text.isEmpty ? null : _notesController.text;

      if (widget.isEditing && widget.expense != null) {
        // Update existing entry
        final updatedExpense = widget.expense!.copyWith(
          title: title,
          date: _selectedDate,
          amount: amount,
          category: _selectedCategory!,
          odometer: odometer,
          notes: notes,
          // Handling receipt URL would require more complex logic for file upload/update
        );

        await expenseProvider.updateExpense(updatedExpense);
      } else {
        // Create new entry
        final newExpense = Expense(
          bikeId: bikeProvider.currentBike!.id!,
          title: title,
          date: _selectedDate,
          amount: amount,
          category: _selectedCategory!,
          odometer: odometer,
          notes: notes,
          // Handling receipt URL would require more complex logic for file upload
        );

        await expenseProvider.addExpense(newExpense);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving expense: $error'),
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
        title: Text(widget.isEditing ? 'Edit Expense' : 'Add Expense'),
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
                    // Category
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Expense Category',
                      ),
                      value: _selectedCategory,
                      items: AppConstants.expenseCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Expense Title',
                        hintText: 'E.g., Oil Change, New Tires, Insurance Premium',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date and Amount
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
                        // Amount
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              prefixText: '\$',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Must be > 0';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Odometer
                    TextFormField(
                      controller: _odometerController,
                      decoration: const InputDecoration(
                        labelText: 'Odometer (Optional)',
                        suffixText: 'km',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveExpense,
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
        title: const Text('Delete Expense'),
        content: const Text(
          'Are you sure you want to delete this expense? This action cannot be undone.',
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
                final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
                await expenseProvider.deleteExpense(widget.expense!.id!);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting expense: $error'),
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
