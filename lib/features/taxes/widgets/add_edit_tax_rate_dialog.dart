import 'package:accountanter/data/database.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddEditTaxRateDialog extends StatefulWidget {
  final TaxRate? taxRate;

  const AddEditTaxRateDialog({
    super.key,
    this.taxRate,
  });

  @override
  State<AddEditTaxRateDialog> createState() => _AddEditTaxRateDialogState();
}

class _AddEditTaxRateDialogState extends State<AddEditTaxRateDialog> {
  final AppDatabase _database = AppDatabase.instance;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.taxRate != null;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.taxRate;
    if (existing != null) {
      _nameController.text = existing.name;
      _rateController.text = existing.rate.toStringAsFixed(2);
      _descriptionController.text = existing.description ?? '';
      _isDefault = existing.isDefault;
    } else {
      _rateController.text = '10.00';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final companion = TaxRatesCompanion(
      id: _isEditing ? Value(widget.taxRate!.id) : const Value.absent(),
      name: Value(_nameController.text.trim()),
      rate: Value(rate),
      description: Value(_descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim()),
      isDefault: Value(_isDefault),
    );

    if (_isEditing) {
      await _database.updateTaxRate(companion);
    } else {
      final id = await _database.insertTaxRate(companion);
      if (_isDefault) {
        await _database.setDefaultTaxRate(id);
      }
    }

    if (_isEditing && _isDefault) {
      await _database.setDefaultTaxRate(widget.taxRate!.id);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Tax Rate' : 'Add Tax Rate'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rateController,
                  decoration: const InputDecoration(labelText: 'Rate (%) *'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                    final n = double.tryParse(v);
                    if (n == null || n < 0) return l10n.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _isDefault,
                  title: const Text('Default rate'),
                  onChanged: (v) => setState(() => _isDefault = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        ElevatedButton(onPressed: _save, child: Text(_isEditing ? l10n.update : l10n.save)),
      ],
    );
  }
}

