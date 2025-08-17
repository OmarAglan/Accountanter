import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:accountanter/data/database.dart';

class AddEditInventoryDialog extends StatefulWidget {
  final InventoryItem? item; // Optional item for editing
  final Function(InventoryItemsCompanion item) onSave;

  const AddEditInventoryDialog({super.key, this.item, required this.onSave});

  @override
  State<AddEditInventoryDialog> createState() => _AddEditInventoryDialogState();
}

class _AddEditInventoryDialogState extends State<AddEditInventoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minStockController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _supplierController = TextEditingController();

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final item = widget.item!;
      _nameController.text = item.name;
      _skuController.text = item.sku ?? '';
      _categoryController.text = item.category;
      _quantityController.text = item.quantity.toString();
      _minStockController.text = item.minStock.toString();
      _unitPriceController.text = item.unitPrice.toStringAsFixed(2);
      _supplierController.text = item.supplier ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _unitPriceController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final itemCompanion = InventoryItemsCompanion(
        id: _isEditing ? Value(widget.item!.id) : const Value.absent(),
        name: Value(_nameController.text),
        sku: Value(_skuController.text),
        category: Value(_categoryController.text),
        quantity: Value(int.tryParse(_quantityController.text) ?? 0),
        minStock: Value(int.tryParse(_minStockController.text) ?? 0),
        unitPrice: Value(double.tryParse(_unitPriceController.text) ?? 0.0),
        supplier: Value(_supplierController.text),
      );

      widget.onSave(itemCompanion);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Item' : 'Add New Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_nameController, 'Product Name *', isRequired: true),
                const SizedBox(height: 16),
                _buildTextField(_skuController, 'SKU'),
                const SizedBox(height: 16),
                _buildTextField(_categoryController, 'Category *', isRequired: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildIntField(_quantityController, 'Quantity *', isRequired: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildIntField(_minStockController, 'Min. Stock')),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPriceField(),
                const SizedBox(height: 16),
                _buildTextField(_supplierController, 'Supplier'),
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
          child: Text(_isEditing ? 'Update Item' : 'Save Item'),
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

  Widget _buildIntField(TextEditingController controller, String label, {bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) {
        if (isRequired && v!.isEmpty) return '$label is required';
        if (v != null && v.isNotEmpty && int.tryParse(v) == null) return 'Enter a valid number';
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _unitPriceController,
      decoration: const InputDecoration(labelText: 'Unit Price *', prefixText: '\$'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      validator: (v) {
        if (v == null || v.isEmpty) return 'Price is required';
        if (double.tryParse(v) == null) return 'Enter a valid price';
        return null;
      },
    );
  }
}