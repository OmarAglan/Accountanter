import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';

import 'package:accountanter/data/database.dart';
import 'package:accountanter/theme/app_colors.dart';
import 'widgets/expense_summary_card.dart';
import 'widgets/add_edit_expense_dialog.dart';
import '../main/widgets/empty_state.dart';

// New data class to hold the result of the join
class ExpenseWithDetails {
  final Expense expense;
  final Category category;
  final Vendor? vendor;

  ExpenseWithDetails({
    required this.expense,
    required this.category,
    this.vendor,
  });
}


class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final AppDatabase _database = AppDatabase.instance;
  late Stream<List<ExpenseWithDetails>> _expensesStream;
  String _searchTerm = '';
  String _filterCategory = 'All Categories';
  String _filterStatus = 'All Statuses';
  String _currencySymbol = '\$';

  List<String> _expenseCategories = ["All Categories"];
  final List<String> _expenseStatuses = [
    "All Statuses", "pending", "approved", "rejected",
  ];

  @override
  void initState() {
    super.initState();
    _initializeLookups();
    _expensesStream = _watchExpensesWithDetails();
    _loadCategories();
  }
  
  void _loadCategories() async {
    final cats = await (_database.select(_database.categories)..where((c) => c.type.equals('expense'))).get();
    if (!mounted) return;
    setState(() {
      _expenseCategories = ["All Categories", ...cats.map((c) => c.name)];
    });
  }
  
  Future<void> _initializeLookups() async {
    final demoMode = await _database.isDemoModeEnabled();
    final currencySymbol = await _database.getCurrencySymbol();

    final existingCategories =
        await (_database.select(_database.categories)..where((c) => c.type.equals('expense'))).get();
    if (existingCategories.isEmpty) {
      await _database.into(_database.categories).insert(CategoriesCompanion.insert(name: 'General', type: 'expense'));
      if (demoMode) {
        await _database.batch((batch) {
          batch.insertAll(_database.categories, [
            CategoriesCompanion.insert(name: 'Office Supplies', type: 'expense'),
            CategoriesCompanion.insert(name: 'Software', type: 'expense'),
            CategoriesCompanion.insert(name: 'Travel', type: 'expense'),
            CategoriesCompanion.insert(name: 'Meals & Entertainment', type: 'expense'),
          ]);
        });
      }
    } else if (demoMode && existingCategories.length < 3) {
      await _database.batch((batch) {
        batch.insertAll(_database.categories, [
          CategoriesCompanion.insert(name: 'Office Supplies', type: 'expense'),
          CategoriesCompanion.insert(name: 'Software', type: 'expense'),
          CategoriesCompanion.insert(name: 'Travel', type: 'expense'),
          CategoriesCompanion.insert(name: 'Meals & Entertainment', type: 'expense'),
        ]);
      });
    }

    final existingVendors = await (_database.select(_database.vendors)).get();
    if (demoMode && existingVendors.isEmpty) {
      await _database.batch((batch) {
        batch.insertAll(_database.vendors, [
          VendorsCompanion.insert(name: 'Office Depot'),
          VendorsCompanion.insert(name: 'Adobe Systems'),
          VendorsCompanion.insert(name: 'American Airlines'),
        ]);
      });
    }

    if (!mounted) return;
    setState(() {
      _currencySymbol = currencySymbol;
    });
  }

  Stream<List<ExpenseWithDetails>> _watchExpensesWithDetails() {
    final query = _database.select(_database.expenses).join([
      innerJoin(_database.categories, _database.categories.id.equalsExp(_database.expenses.categoryId)),
      leftOuterJoin(_database.vendors, _database.vendors.id.equalsExp(_database.expenses.vendorId)),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ExpenseWithDetails(
          expense: row.readTable(_database.expenses),
          category: row.readTable(_database.categories),
          vendor: row.readTableOrNull(_database.vendors),
        );
      }).toList();
    });
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
          title: Text(AppLocalizations.of(context)!.deleteExpense),
          content: Text('${AppLocalizations.of(context)!.confirmDeleteExpense} "${expense.description}"? ${AppLocalizations.of(context)!.deleteConfirmation}'),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
              child: Text(AppLocalizations.of(context)!.delete),
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
    return StreamBuilder<List<ExpenseWithDetails>>(
      stream: _expensesStream,
      builder: (context, snapshot) {
        final allExpensesDetails = snapshot.data ?? [];
        
        final filteredExpenses = allExpensesDetails.where((details) {
          final expense = details.expense;
          final searchLower = _searchTerm.toLowerCase();
          final descriptionMatches = expense.description.toLowerCase().contains(searchLower);
          final vendorMatches = details.vendor?.name.toLowerCase().contains(searchLower) ?? false;
          final categoryMatches = _filterCategory == 'All Categories' || details.category.name == _filterCategory;
          final statusMatches = _filterStatus == 'All Statuses' || expense.status == _filterStatus;
          return (descriptionMatches || vendorMatches) && categoryMatches && statusMatches;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, filteredExpenses),
            const SizedBox(height: 24),
            _buildSummaryCards(allExpensesDetails.map((d) => d.expense).toList()),
            const SizedBox(height: 24),
            _buildFilterBar(),
            const SizedBox(height: 24),
            _buildExpenseTable(context, filteredExpenses),
          ],
        );
      },
    );
  }

  Future<void> _exportToCsv(List<ExpenseWithDetails> expenses) async {
    final path = await CsvExportUtil.exportExpenses(expenses);
    if (mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${AppLocalizations.of(context)!.export} ${AppLocalizations.of(context)!.success}: $path'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.error),
          backgroundColor: AppColors.destructive,
        ));
      }
    }
  }

  Widget _buildHeader(BuildContext context, List<ExpenseWithDetails> expenses) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.expenses, style: Theme.of(context).textTheme.headlineMedium),
            Text(
              'Track and manage your business expenses efficiently.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _exportToCsv(expenses),
              icon: const Icon(LucideIcons.download, size: 16),
              label: Text(AppLocalizations.of(context)!.export),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showAddExpenseDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: Text(AppLocalizations.of(context)!.addExpense),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.accentForeground,
              ),
            ),
          ],
        )
      ],
    );
  }
  }
  
  Widget _buildSummaryCards(List<Expense> expenses) {
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final pendingExpenses = expenses.where((e) => e.status == 'pending').fold(0.0, (sum, e) => sum + e.amount);
    final approvedExpenses = expenses.where((e) => e.status == 'approved').fold(0.0, (sum, e) => sum + e.amount);
    final avgExpense = expenses.isNotEmpty ? totalExpenses / expenses.length : 0.0;
    
    final currencyFormat = NumberFormat.currency(symbol: _currencySymbol, decimalDigits: 2);

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
            ExpenseSummaryCard(icon: LucideIcons.dollarSign, title: AppLocalizations.of(context)!.totalExpenses, value: currencyFormat.format(totalExpenses), color: AppColors.primary, subtitle: AppLocalizations.of(context)!.thisMonth),
            ExpenseSummaryCard(icon: LucideIcons.clock, title: AppLocalizations.of(context)!.pendingPayments, value: currencyFormat.format(pendingExpenses), color: AppColors.warning, subtitle: '${expenses.where((e) => e.status == 'pending').length} ${AppLocalizations.of(context)!.expenses}'),
            ExpenseSummaryCard(icon: LucideIcons.circleCheck, title: 'Approved', value: currencyFormat.format(approvedExpenses), color: AppColors.success, subtitle: '${expenses.where((e) => e.status == 'approved').length} ${AppLocalizations.of(context)!.expenses}'),
            ExpenseSummaryCard(icon: LucideIcons.chartBar, title: 'Average', value: currencyFormat.format(avgExpense), color: AppColors.info, subtitle: 'Per expense'),
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
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchExpenses,
                  prefixIcon: Icon(LucideIcons.search, size: 16),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                key: ValueKey(_filterCategory),
                initialValue: _filterCategory,
                decoration: InputDecoration(isDense: true, labelText: AppLocalizations.of(context)!.category),
                items: _expenseCategories.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _filterCategory = value!),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                key: ValueKey(_filterStatus),
                initialValue: _filterStatus,
                decoration: InputDecoration(isDense: true, labelText: AppLocalizations.of(context)!.status),
                items: _expenseStatuses.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _filterStatus = value!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTable(BuildContext context, List<ExpenseWithDetails> expenses) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(AppLocalizations.of(context)!.expenses, style: textTheme.titleLarge),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(AppLocalizations.of(context)!.date)),
                DataColumn(label: Text(AppLocalizations.of(context)!.description)),
                DataColumn(label: Text(AppLocalizations.of(context)!.category)),
                DataColumn(label: Text(AppLocalizations.of(context)!.amount)),
                DataColumn(label: Text(AppLocalizations.of(context)!.status)),
                DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
              ],
              rows: expenses.map((details) => _buildDataRow(details)).toList(),
            ),
          ),
          if (expenses.isEmpty)
            EmptyState(
              icon: LucideIcons.dollarSign,
              title: AppLocalizations.of(context)!.noExpenses,
              description: 'No expenses found. Track your business spending to see reports.',
              actionLabel: AppLocalizations.of(context)!.addExpense,
              onAction: _showAddExpenseDialog,
            )
        ],
      ),
    );
  }

  DataRow _buildDataRow(ExpenseWithDetails details) {
    final expense = details.expense;
    final currencyFormat = NumberFormat.currency(symbol: _currencySymbol, decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');

    final statusChip = Chip(
      label: Text(expense.status),
      backgroundColor: _getStatusColor(expense.status).withAlpha(26),
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
          if (details.vendor != null)
            Text(details.vendor!.name, style: Theme.of(context).textTheme.bodySmall),
        ],
      )),
      DataCell(Text(details.category.name)),
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
          PopupMenuItem<String>(value: 'edit', child: Text(AppLocalizations.of(context)!.edit)),
          PopupMenuItem<String>(value: 'delete', child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: AppColors.destructive))),
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
