import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bike_provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_chart.dart';
import 'expense_entry_screen.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  final String? initialFilter;
  
  const ExpenseHistoryScreen({
    super.key,
    this.initialFilter,
  });

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedFilter = widget.initialFilter;
    _refreshExpenseData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshExpenseData() async {
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
    if (bikeProvider.currentBike != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
        await expenseProvider.loadExpenses(bikeProvider.currentBike!.id!);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading expense data: $error'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Entries'),
            Tab(text: 'Charts'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                if (_selectedFilter == value) {
                  _selectedFilter = null; // Toggle off if same filter is selected
                } else {
                  _selectedFilter = value;
                }
              });
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Categories'),
              ),
              ...AppConstants.expenseCategories.map((category) => 
                PopupMenuItem(
                  value: category,
                  child: Text(category),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.current.accent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildExpenseList(),
                _buildCharts(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ExpenseEntryScreen(
                initialCategory: _selectedFilter,
              ),
            ),
          ).then((_) => _refreshExpenseData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpenseList() {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;

    // Apply filter if selected
    final filteredExpenses = _selectedFilter == null || _selectedFilter == 'all'
        ? expenses
        : expenses.where((e) => e.category == _selectedFilter).toList();

    if (expenses.isEmpty) {
      return EmptyState(
        message: 'No expenses recorded yet. Start tracking your motorcycle expenses.',
        title: 'No Expenses',
        icon: Icons.attach_money,
        actionText: 'Add Expense',
        onAction: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const ExpenseEntryScreen()),
          ).then((_) => _refreshExpenseData());
        },
      );
    }

    if (filteredExpenses.isEmpty) {
      return EmptyState(
        message: 'No expenses found in the selected category.',
        title: 'No Matching Expenses',
        icon: Icons.filter_list,
        actionText: 'Clear Filter',
        onAction: () {
          setState(() {
            _selectedFilter = null;
          });
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshExpenseData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredExpenses.length,
        itemBuilder: (ctx, i) {
          final expense = filteredExpenses[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ExpenseEntryScreen(
                      expense: expense,
                      isEditing: true,
                    ),
                  ),
                ).then((_) => _refreshExpenseData());
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            expense.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.formatCurrency(expense.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.current.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: AppColors.current.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatter.formatDate(expense.date),
                              style: TextStyle(
                                color: AppColors.current.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (expense.odometer != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.speed,
                                size: 14,
                                color: AppColors.current.textLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormatter.formatDistance(expense.odometer!),
                                style: TextStyle(
                                  color: AppColors.current.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(expense.category),
                      backgroundColor: _getCategoryColor(expense.category).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _getCategoryColor(expense.category),
                        fontSize: 12,
                      ),
                    ),
                    if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Divider(color: AppColors.current.border),
                      const SizedBox(height: 8),
                      Text(
                        expense.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppColors.current.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCharts() {
    final bikeProvider = Provider.of<BikeProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    if (!bikeProvider.hasBikes) {
      return EmptyState(
        message: 'Add your motorcycle to see expense charts',
        title: 'No Motorcycle Added',
        icon: Icons.show_chart,
        actionText: 'Add Motorcycle',
        onAction: () {},
      );
    }

    return FutureBuilder(
      future: Future.wait([
        expenseProvider.getExpenseStatistics(bikeProvider.currentBike!.id!),
        expenseProvider.getMonthlyExpenses(bikeProvider.currentBike!.id!),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.current.accent));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading chart data: ${snapshot.error}',
              style: TextStyle(color: AppColors.current.danger),
            ),
          );
        }

        final stats = snapshot.data?[0] as Map<String, dynamic>? ?? {};
        final monthlyData = snapshot.data?[1] as List<Map<String, dynamic>>? ?? [];

        if (stats.isEmpty || (stats['totalExpenses'] as double) <= 0) {
          return EmptyState(
            message: 'No expense data to display',
            title: 'No Chart Data',
            icon: Icons.show_chart,
            actionText: 'Add Expense',
            onAction: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const ExpenseEntryScreen()),
              ).then((_) => _refreshExpenseData());
            },
          );
        }

        return Column(
          children: [
            Expanded(
              flex: 1,
              child: monthlyData.isNotEmpty 
                ? ExpenseChart(
                    data: monthlyData,
                    title: 'Monthly Expenses',
                  )
                : Center(
                    child: Text(
                      'Not enough data for monthly chart',
                      style: TextStyle(color: AppColors.current.textLight),
                    ),
                  ),
            ),
            Expanded(
              flex: 1,
              child: ExpensePieChart(
                data: stats,
                title: 'Expenses by Category',
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    final colors = AppColors.current;
    switch (category) {
      case 'Fuel':
        return colors.accent;
      case 'Maintenance':
        return colors.warning;
      case 'Insurance':
        return Colors.purple;
      case 'Registration':
        return Colors.teal;
      case 'Gear & Accessories':
        return Colors.orange;
      case 'Modifications':
        return Colors.indigo;
      default:
        return colors.primary;
    }
  }
}
