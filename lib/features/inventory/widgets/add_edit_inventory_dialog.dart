import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  final AppDatabase _database = AppDatabase.instance;

  // Text Controllers
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minStockController = TextEditingController();
  final _unitPriceController = TextEditingController();
  
  // State for dropdowns
  Category? _selectedCategory;
  Supplier? _selectedSupplier;
  
  List<Category> _categories = [];
  List<Supplier> _suppliers = [];
  bool _isLoading = true;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // In a real app, you might want to fetch these based on type, e.g., 'inventory'
    final cats = await (_database.select(_database.categories)).get();
    final sups = await (_database.select(_database.suppliers)).get();

    setState(() {
      _categories = cats;
      _suppliers = sups;
      
      if (_isEditing) {
        final item = widget.item!;
        _nameController.text = item.name;
        _skuController.text = item.sku ?? '';
        _quantityController.text = item.quantity.toString();
        _minStockController.text = item.minStock.toString();
        _unitPriceController.text = item.unitPrice.toStringAsFixed(2);
        
        // Find and set the selected category and supplier from the fetched lists
        _selectedCategory = _categories.where((c) => c.id == item.categoryId).firstOrNull;
        if (item.supplierId != null) {
          _selectedSupplier = _suppliers.where((s) => s.id == item.supplierId).firstOrNull;
        }
      }
      _isLoading = false;
    });
  }


  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final itemCompanion = InventoryItemsCompanion(
      id: _isEditing ? Value(widget.item!.id) : const Value.absent(),
      name: Value(_nameController.text),
      sku: Value(_skuController.text),
      categoryId: Value(_selectedCategory!.id), // Use the ID from the selected object
      quantity: Value(int.tryParse(_quantityController.text) ?? 0),
      minStock: Value(int.tryParse(_minStockController.text) ?? 0),
      unitPrice: Value(double.tryParse(_unitPriceController.text) ?? 0.0),
      supplierId: Value(_selectedSupplier?.id), // Use the ID from the selected object
    );

    widget.onSave(itemCompanion);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? AppLocalizations.of(context)!.editInventoryItem : AppLocalizations.of(context)!.addInventoryItem),
      content: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(_nameController, '${AppLocalizations.of(context)!.itemName} *', isRequired: true),
                    const SizedBox(height: 16),
                    _buildTextField(_skuController, AppLocalizations.of(context)!.sku),
                    const SizedBox(height: 16),
                    // CATEGORY DROPDOWN
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildIntField(_quantityController, '${AppLocalizations.of(context)!.quantity} *', isRequired: true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildIntField(_minStockController, 'Min. Stock')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPriceField(),
                    const SizedBox(height: 16),
                    // SUPPLIER DROPDOWN
                    _buildSupplierDropdown(),
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
  
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<Category>(
      value: _selectedCategory,
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
  
  Widget _buildSupplierDropdown() {
    return DropdownButtonFormField<Supplier>(
      value: _selectedSupplier,
      decoration: InputDecoration(labelText: 'Supplier'),
      hint: Text('${AppLocalizations.of(context)!.pleaseSelect} (${AppLocalizations.of(context)!.optional})'),
      items: _suppliers.map((Supplier supplier) {
        return DropdownMenuItem<Supplier>(
          value: supplier,
          child: Text(supplier.name),
        );
      }).toList(),
      onChanged: (Supplier? newValue) {
        setState(() {
          _selectedSupplier = newValue;
        });
      },
    );
  }


  Widget _buildIntField(TextEditingController controller, String label, {bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) {
        if (isRequired && v!.isEmpty) return AppLocalizations.of(context)!.fieldRequired;
        if (v != null && v.isNotEmpty && int.tryParse(v) == null) return AppLocalizations.of(context)!.fieldRequired;
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _unitPriceController,
      decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.unitPrice} *', prefixText: '\$'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      validator: (v) {
        if (v == null || v.isEmpty) return AppLocalizations.of(context)!.fieldRequired;
        if (double.tryParse(v) == null) return AppLocalizations.of(context)!.fieldRequired;
        return null;
      },
    );
  }
}