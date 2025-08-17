import 'package:flutter/material.dart';
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
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _vendorController = TextEditingController();
  final _dateController = TextEditingController();
  final _projectController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _selectedCategory;
  String? _selectedPaymentMethod;
  DateTime _selectedDate = DateTime.now();
  
  bool get _isEditing => widget.expense != null;
  
  final List<String> _expenseCategories = [
    "Office Supplies", "Software", "Equipment", "Travel", 
    "Meals & Entertainment", "Marketing", "Professional Services", 
    "Utilities", "Rent", "Insurance", "Training", "Other",
  ];

  final List<String> _paymentMethods = [
    "Cash", "Company Credit Card", "Personal Credit Card", 
    "Bank Transfer", "Check", "Purchase Order",
  ];


  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final expense = widget.expense!;
      _descriptionController.text = expense.description;
      _amountController.text = expense.amount.toStringAsFixed(2);
      _vendorController.text = expense.vendor ?? '';
      _selectedDate = expense.date;
      _selectedCategory = expense.category;
      _selectedPaymentMethod = expense.paymentMethod;
      _projectController.text = expense.project ?? '';
      _tagsController.text = expense.tags ?? '';
    }
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _vendorController.dispose();
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
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      
      final expenseCompanion = ExpensesCompanion(
        id: _isEditing ? Value(widget.expense!.id) : const Value.absent(),
        description: Value(_descriptionController.text),
        amount: Value(amount),
        category: Value(_selectedCategory!),
        vendor: Value(_vendorController.text),
        paymentMethod: Value(_selectedPaymentMethod!),
        date: Value(_selectedDate),
        project: Value(_projectController.text),
        tags: Value(_tagsController.text),
        // Keep original status when editing, default to 'pending' on create
        status: _isEditing ? Value(widget.expense!.status) : const Value('pending'),
      );
      
      widget.onSave(expenseCompanion);
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Expense' : 'Add New Expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_descriptionController, 'Description *'),
                const SizedBox(height: 16),
                _buildAmountField(),
                const SizedBox(height: 16),
                _buildDropdown(_expenseCategories, 'Category *', _selectedCategory, (val) => setState(() => _selectedCategory = val)),
                const SizedBox(height: 16),
                _buildTextField(_vendorController, 'Vendor'),
                const SizedBox(height: 16),
                 _buildDropdown(_paymentMethods, 'Payment Method *', _selectedPaymentMethod, (val) => setState(() => _selectedPaymentMethod = val)),
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: Text(_isEditing ? 'Update Expense' : 'Save Expense'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (v) => (isRequired && v!.isEmpty) ? '$label is required' : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(labelText: 'Amount *', prefixText: '\$'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (v) {
        if (v == null || v.isEmpty) return 'Amount is required';
        if (double.tryParse(v) == null) return 'Enter a valid number';
        return null;
      },
    );
  }
  
  Widget _buildDropdown(List<String> items, String label, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? '$label is required' : null,
    );
  }
  
  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      decoration: const InputDecoration(labelText: 'Date *', suffixIcon: Icon(Icons.calendar_today)),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (v) => v!.isEmpty ? 'Date is required' : null,
    );
  }
}