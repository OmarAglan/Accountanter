import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import '../../../data/database.dart';

class AddEditExpenseDialog extends StatefulWidget {
  final Expense? expense; // Optional expense for editing
  final Function(ExpensesCompanion expense) onSave;

  const AddEditExpenseDialog({super.key, this.expense, required this.onSave});

  @override
  State<AddEditExpenseDialog> createState() => _AddEditExpenseDialogState();
}

class _AddEditExpenseDialogState extends State<AddEditExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final AppDatabase _database = AppDatabase.instance;

  // Text Controllers
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _projectController = TextEditingController();
  final _tagsController = TextEditingController();
  
  // State for dropdowns
  Category? _selectedCategory;
  Vendor? _selectedVendor;
  String? _selectedPaymentMethod;
  
  List<Category> _categories = [];
  List<Vendor> _vendors = [];
  bool _isLoading = true;
  String _currencySymbol = '\$';

  DateTime _selectedDate = DateTime.now();
  
  bool get _isEditing => widget.expense != null;
  
  late List<String> _paymentMethods;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _paymentMethods = [
      l10n.cash,
      l10n.creditCard,
      l10n.bankTransfer,
      "Check",
      "Purchase Order",
    ];
  }
  
  Future<void> _loadInitialData() async {
    final catsQuery = _database.select(_database.categories)..where((c) => c.type.equals('expense'));
    final vendsQuery = _database.select(_database.vendors);

    final cats = await catsQuery.get();
    final vends = await vendsQuery.get();
    final currencySymbol = await _database.getCurrencySymbol();

    setState(() {
      _categories = cats;
      _vendors = vends;
      _currencySymbol = currencySymbol;
      
      if (_isEditing) {
        final expense = widget.expense!;
        _descriptionController.text = expense.description;
        _amountController.text = expense.amount.toStringAsFixed(2);
        _selectedDate = expense.date;
        _selectedPaymentMethod = expense.paymentMethod;
        _projectController.text = expense.project ?? '';
        _tagsController.text = expense.tags ?? '';
        
        _selectedCategory = _categories.where((c) => c.id == expense.categoryId).firstOrNull;
        if (expense.vendorId != null) {
          _selectedVendor = _vendors.where((v) => v.id == expense.vendorId).firstOrNull;
        }
      }
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _projectController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final expenseCompanion = ExpensesCompanion(
      id: _isEditing ? Value(widget.expense!.id) : const Value.absent(),
      description: Value(_descriptionController.text),
      amount: Value(double.tryParse(_amountController.text) ?? 0.0),
      categoryId: Value(_selectedCategory!.id),
      vendorId: Value(_selectedVendor?.id),
      paymentMethod: Value(_selectedPaymentMethod!),
      date: Value(_selectedDate),
      project: Value(_projectController.text),
      tags: Value(_tagsController.text),
      status: _isEditing ? Value(widget.expense!.status) : const Value('pending'),
    );
    
    widget.onSave(expenseCompanion);
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? AppLocalizations.of(context)!.editExpense : AppLocalizations.of(context)!.addExpense),
      content: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(_descriptionController, '${AppLocalizations.of(context)!.description} *', isRequired: true),
                  const SizedBox(height: 16),
                  _buildAmountField(),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                  _buildVendorDropdown(),
                  const SizedBox(height: 16),
                  _buildDropdown(_paymentMethods, '${AppLocalizations.of(context)!.paymentMethod} *', _selectedPaymentMethod, (val) => setState(() => _selectedPaymentMethod = val)),
                  const SizedBox(height: 16),
                  _buildDateField(),
                  const SizedBox(height: 16),
                  _buildTextField(_projectController, 'Project (Optional)'),
                  const SizedBox(height: 16),
                  _buildTextField(_tagsController, 'Tags (comma-separated)'),
                ],
              ),
            ),
          ),
        ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: Text(_isEditing ? AppLocalizations.of(context)!.update : AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (v) => (isRequired && v!.isEmpty) ? AppLocalizations.of(context)!.fieldRequired : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.amount} *', prefixText: _currencySymbol),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (v) {
        if (v == null || v.isEmpty) return AppLocalizations.of(context)!.fieldRequired;
        if (double.tryParse(v) == null) return AppLocalizations.of(context)!.fieldRequired;
        return null;
      },
    );
  }
  
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<Category>(
      key: ValueKey(_selectedCategory?.id),
      initialValue: _selectedCategory,
      decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.category} *'),
      hint: Text(AppLocalizations.of(context)!.pleaseSelect),
      items: _categories.map((Category category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (Category? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) => value == null ? AppLocalizations.of(context)!.fieldRequired : null,
    );
  }
  
  Widget _buildVendorDropdown() {
    return DropdownButtonFormField<Vendor>(
      key: ValueKey(_selectedVendor?.id),
      initialValue: _selectedVendor,
      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.vendor),
      hint: Text('${AppLocalizations.of(context)!.pleaseSelect} (${AppLocalizations.of(context)!.optional})'),
      items: _vendors.map((Vendor vendor) {
        return DropdownMenuItem<Vendor>(
          value: vendor,
          child: Text(vendor.name),
        );
      }).toList(),
      onChanged: (Vendor? newValue) {
        setState(() {
          _selectedVendor = newValue;
        });
      },
    );
  }
  
  Widget _buildDropdown(List<String> items, String label, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? AppLocalizations.of(context)!.fieldRequired : null,
    );
  }
  
  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.date} *', suffixIcon: const Icon(Icons.calendar_today)),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.fieldRequired : null,
    );
  }
}
