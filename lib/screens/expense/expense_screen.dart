import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bike_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

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
          message: 'Add your motorcycle to track expenses',
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
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: AppColors.current.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.current.primary,
                tabs: const [
                  Tab(text: 'Expenses'),
                  Tab(text: 'Analysis'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildExpensesTab(context),
                  _buildAnalysisTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add expense form will be implemented in the next phase'),
            ),
          );
        },
        backgroundColor: AppColors.current.error,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExpensesTab(BuildContext context) {
    return EmptyState(
      message: 'No expenses recorded',
      icon: Icons.account_balance_wallet,
      actionLabel: 'Add Expense',
      onActionPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add expense form will be implemented in the next phase'),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisTab(BuildContext context) {
    return EmptyState(
      message: 'No expense data to analyze',
      icon: Icons.insert_chart,
      actionLabel: 'Add Expense',
      onActionPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add expense form will be implemented in the next phase'),
          ),
        );
      },
    );
  }
}