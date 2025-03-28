import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/database_helper.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  List<Expense> _expenses = [];
  
  List<Expense> get expenses => [..._expenses];
  
  // Get expenses by bike
  List<Expense> getExpensesByBikeId(String bikeId) {
    return _expenses
        .where((expense) => expense.bikeId == bikeId)
        .toList();
  }
  
  // Get expenses by category
  List<Expense> getExpensesByCategory(String bikeId, String category) {
    if (category == 'All') {
      return getExpensesByBikeId(bikeId);
    }
    return _expenses
        .where((expense) => expense.bikeId == bikeId)
        .where((expense) => expense.category == category)
        .toList();
  }
  
  // Get total expenses
  double getTotalExpenses(String bikeId) {
    return _expenses
        .where((expense) => expense.bikeId == bikeId)
        .map((expense) => expense.amount)
        .fold(0, (prev, amount) => prev + amount);
  }
  
  // Get recent expenses count for dashboard
  int getRecentExpensesCount(String bikeId) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    return _expenses
        .where((expense) => expense.bikeId == bikeId)
        .where((expense) => expense.date.isAfter(thirtyDaysAgo))
        .length;
  }
  
  // Get expense category breakdown
  Map<String, double> getCategoryBreakdown(String bikeId) {
    final categoryMap = <String, double>{};
    
    for (final expense in _expenses.where((e) => e.bikeId == bikeId)) {
      categoryMap.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    
    return categoryMap;
  }
  
  // Load expenses for a specific bike
  Future<void> loadExpenses(String bikeId) async {
    try {
      final expensesData = await _dbHelper.getExpenses(bikeId);
      
      _expenses = expensesData
          .map((item) => Expense.fromMap(item))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading expenses: $e');
      _expenses = [];
      notifyListeners();
    }
  }
  
  // Add a new expense
  Future<void> addExpense(Expense expense) async {
    try {
      final expenseWithId = expense.copyWith(id: _uuid.v4());
      final expenseMap = expenseWithId.toMap();
      
      await _dbHelper.insertExpense(expenseMap);
      
      await loadExpenses(expense.bikeId);
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }
  
  // Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    try {
      if (expense.id == null) {
        throw Exception('Cannot update expense without id');
      }
      
      final expenseMap = expense.toMap();
      
      await _dbHelper.updateExpense(expenseMap);
      
      await loadExpenses(expense.bikeId);
    } catch (e) {
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }
  
  // Delete an expense
  Future<void> deleteExpense(String expenseId, String bikeId) async {
    try {
      await _dbHelper.deleteExpense(expenseId);
      
      await loadExpenses(bikeId);
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }
  
  // Get monthly expense totals for charts
  Map<String, double> getMonthlyExpenseTotals(String bikeId, int months) {
    final monthlyTotals = <String, double>{};
    final now = DateTime.now();
    
    // Initialize all months with zero amounts
    for (var i = 0; i < months; i++) {
      final month = now.month - i;
      final year = now.year - (month <= 0 ? 1 : 0);
      final adjustedMonth = month <= 0 ? month + 12 : month;
      
      final monthLabel = '${year}-${adjustedMonth.toString().padLeft(2, '0')}';
      monthlyTotals[monthLabel] = 0;
    }
    
    // Calculate actual amounts for each month
    for (final expense in _expenses.where((e) => e.bikeId == bikeId)) {
      final monthLabel = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      
      if (monthlyTotals.containsKey(monthLabel)) {
        monthlyTotals[monthLabel] = (monthlyTotals[monthLabel] ?? 0) + expense.amount;
      }
    }
    
    return monthlyTotals;
  }
}