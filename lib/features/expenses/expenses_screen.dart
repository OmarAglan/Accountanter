import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';

import 'package:accountanter/data/database.dart';
import 'package:accountanter/theme/app_colors.dart';
import 'widgets/expense_summary_card.dart';
import 'widgets/add_edit_expense_dialog.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final AppDatabase _database = AppDatabase.instance;
  late Stream<List<Expense>> _expensesStream;
  String _searchTerm = '';
  String _filterCategory = 'All Categories';
  String _filterStatus = 'All Statuses';

  final List<String> _expenseCategories = [
    "All Categories", "Office Supplies", "Software", "Equipment", "Travel", 
    "Meals & Entertainment", "Marketing", "Professional Services", 
    "Utilities", "Rent", "Insurance", "Training", "Other",
  ];

  final List<String> _expenseStatuses = [
    "All Statuses", "pending", "approved", "rejected",
  ];

  @override
  void initState() {
    super.initState();
    _expensesStream = _database.watchAllExpenses();
  }
  
  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditExpenseDialog(
        onSave: (expense) {
          _database.insertExpense(expense);
        },
      ),
    );
  }

  void _showEditExpenseDialog(Expense expenseToEdit) {
    showDialog(
      context: context,
      builder: (context) => AddEditExpenseDialog(
        expense: expenseToEdit,
        onSave: (expense) {
          _database.updateExpense(expense);
        },
      ),
    );
  }

  void _confirmAndDeleteExpense(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text('Are you sure you want to delete "${expense.description}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
              child: const Text('Delete'),
              onPressed: () {
                _database.deleteExpense(expense.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
      stream: _expensesStream,
      builder: (context, snapshot) {
        final allExpenses = snapshot.data ?? [];
        
        final filteredExpenses = allExpenses.where((expense) {
          final searchLower = _searchTerm.toLowerCase();
          final descriptionMatches = expense.description.toLowerCase().contains(searchLower);
          final vendorMatches = expense.vendor?.toLowerCase().contains(searchLower) ?? false;
          final categoryMatches = _filterCategory == 'All Categories' || expense.category == _filterCategory;
          final statusMatches = _filterStatus == 'All Statuses' || expense.status == _filterStatus;
          return (descriptionMatches || vendorMatches) && categoryMatches && statusMatches;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSummaryCards(allExpenses),
            const SizedBox(height: 24),
            _buildFilterBar(),
            const SizedBox(height: 24),
            _buildExpenseTable(context, filteredExpenses, allExpenses.length),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expense Management', style: Theme.of(context).textTheme.headlineMedium),
            Text(
              'Track and manage your business expenses efficiently.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showAddExpenseDialog,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Add Expense'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.accentForeground,
          ),
        )
      ],
    );
  }
  
  Widget _buildSummaryCards(List<Expense> expenses) {
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final pendingExpenses = expenses.where((e) => e.status == 'pending').fold(0.0, (sum, e) => sum + e.amount);
    final approvedExpenses = expenses.where((e) => e.status == 'approved').fold(0.0, (sum, e) => sum + e.amount);
    final avgExpense = expenses.isNotEmpty ? totalExpenses / expenses.length : 0.0;
    
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 1100 ? 2 : 4;
        double childAspectRatio = constraints.maxWidth < 600 ? 2.5 : 2.8;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          children: [
            ExpenseSummaryCard(icon: LucideIcons.dollarSign, title: 'Total Expenses', value: currencyFormat.format(totalExpenses), color: AppColors.primary, subtitle: 'This month'),
            ExpenseSummaryCard(icon: LucideIcons.clock, title: 'Pending Approval', value: currencyFormat.format(pendingExpenses), color: AppColors.warning, subtitle: '${expenses.where((e) => e.status == 'pending').length} expenses'),
            ExpenseSummaryCard(icon: LucideIcons.circleCheck, title: 'Approved', value: currencyFormat.format(approvedExpenses), color: AppColors.success, subtitle: '${expenses.where((e) => e.status == 'approved').length} expenses'),
            ExpenseSummaryCard(icon: LucideIcons.chartPie, title: 'Average Expense', value: currencyFormat.format(avgExpense), color: AppColors.info, subtitle: 'Per expense'),
          ],
        );
      }
    );
  }
  
  Widget _buildFilterBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                onChanged: (value) => setState(() => _searchTerm = value),
                decoration: const InputDecoration(
                  hintText: 'Search expenses...',
                  prefixIcon: Icon(LucideIcons.search, size: 16),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _filterCategory,
                decoration: const InputDecoration(isDense: true, labelText: 'Category'),
                items: _expenseCategories.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _filterCategory = value!),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _filterStatus,
                decoration: const InputDecoration(isDense: true, labelText: 'Status'),
                items: _expenseStatuses.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _filterStatus = value!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTable(BuildContext context, List<Expense> expenses, int totalCount) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expense List', style: textTheme.titleLarge),
                Text('${expenses.length} of $totalCount expenses', style: textTheme.bodyMedium),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: expenses.map((expense) => _buildDataRow(expense)).toList(),
            ),
          ),
          if (expenses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('No expenses found.')),
            ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(Expense expense) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');

    final statusChip = Chip(
      label: Text(expense.status),
      backgroundColor: _getStatusColor(expense.status).withOpacity(0.1),
      labelStyle: TextStyle(color: _getStatusColor(expense.status), fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
    
    return DataRow(cells: [
      DataCell(Text(dateFormat.format(expense.date))),
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w500)),
          if (expense.vendor != null && expense.vendor!.isNotEmpty)
            Text(expense.vendor!, style: Theme.of(context).textTheme.bodySmall),
        ],
      )),
      DataCell(Text(expense.category)),
      DataCell(Text(currencyFormat.format(expense.amount), style: const TextStyle(fontFamily: 'monospace'))),
      DataCell(statusChip),
      DataCell(PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _showEditExpenseDialog(expense);
          } else if (value == 'delete') {
            _confirmAndDeleteExpense(expense);
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
          const PopupMenuItem<String>(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.destructive))),
        ],
        icon: const Icon(LucideIcons.ellipsisVertical, size: 16),
      )),
    ]);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return AppColors.success;
      case 'pending': return AppColors.warning;
      case 'rejected': return AppColors.destructive;
      default: return AppColors.mutedForeground;
    }
  }
}