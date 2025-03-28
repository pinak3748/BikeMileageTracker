import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../../providers/bike_provider.dart';
import '../../providers/expense_provider.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final bikeProvider = Provider.of<BikeProvider>(context);

    if (!bikeProvider.hasBikes) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Expenses',
          showBikeSelector: true,
        ),
        body: EmptyState(
          message: 'Add your motorcycle to start tracking expenses',
          icon: Icons.motorcycle,
          actionLabel: 'Add Motorcycle',
          onActionPressed: () {
            Navigator.of(context).pushNamed('/add-bike');
          },
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Expenses',
        showBikeSelector: true,
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _buildExpenseList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense entry form will be implemented in the next phase'),
            ),
          );
        },
        backgroundColor: AppColors.success,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', ...AppConstants.expenseCategories];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: AppColors.success,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpenseList() {
    return EmptyState(
      message: 'Track your motorcycle-related expenses',
      icon: Icons.attach_money,
      actionLabel: 'Add Expense',
      onActionPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense entry form will be implemented in the next phase'),
          ),
        );
      },
    );
  }
}