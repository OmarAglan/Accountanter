import 'package:accountanter/data/database.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEditPaymentDialog extends StatefulWidget {
  final PaymentWithInvoiceAndClient? payment;
  final InvoiceWithStats? initialInvoice;

  const AddEditPaymentDialog({
    super.key,
    this.payment,
    this.initialInvoice,
  });

  @override
  State<AddEditPaymentDialog> createState() => _AddEditPaymentDialogState();
}

class _AddEditPaymentDialogState extends State<AddEditPaymentDialog> {
  final AppDatabase _database = AppDatabase.instance;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.payment != null;

  InvoiceWithStats? _selectedInvoice;
  DateTime _date = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _method = 'Cash';
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_date);
    _loadCurrencySymbol();

    final existing = widget.payment;
    if (existing != null) {
      _date = existing.payment.date;
      _dateController.text = DateFormat('yyyy-MM-dd').format(_date);
      _amountController.text = existing.payment.amount.toStringAsFixed(2);
      _referenceController.text = existing.payment.referenceNumber ?? '';
      _notesController.text = existing.payment.notes ?? '';
      _method = existing.payment.method;
      _selectedInvoice = InvoiceWithStats(
        invoice: existing.invoice,
        client: existing.client,
        paidAmount: 0.0, // Mocked for initial value
      );
    } else if (widget.initialInvoice != null) {
      _selectedInvoice = widget.initialInvoice;
      _amountController.text = widget.initialInvoice!.balance.toStringAsFixed(2);
    }
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await _database.getCurrencySymbol();
    if (!mounted) return;
    setState(() => _currencySymbol = symbol);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = DateFormat('yyyy-MM-dd').format(_date);
    });
  }

  Future<List<InvoiceWithStats>> _loadInvoices() async {
    return _database.watchAllInvoicesWithStats().first;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInvoice == null) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final companion = PaymentsCompanion(
      id: _isEditing ? Value(widget.payment!.payment.id) : const Value.absent(),
      invoiceId: Value(_selectedInvoice!.invoice.id),
      amount: Value(amount),
      date: Value(_date),
      method: Value(_method),
      referenceNumber: Value(_referenceController.text.isEmpty ? null : _referenceController.text),
      notes: Value(_notesController.text.isEmpty ? null : _notesController.text),
    );

    if (_isEditing) {
      await _database.updatePayment(companion);
    } else {
      await _database.insertPayment(companion);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Payment' : 'Record Payment'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<List<InvoiceWithStats>>(
                  future: _loadInvoices(),
                  builder: (context, snapshot) {
                    final invoices = snapshot.data ?? [];

                    final options = _isEditing
                        ? invoices
                        : invoices.where((i) => i.balance > 0).toList();

                    final selected = _selectedInvoice;
                    final hasSelected = selected != null &&
                        options.any((i) => i.invoice.id == selected.invoice.id);

                    final effectiveOptions = (!hasSelected && selected != null)
                        ? <InvoiceWithStats>[selected, ...options]
                        : options;

                    final effectiveSelected = selected == null
                        ? null
                        : effectiveOptions.firstWhere(
                            (i) => i.invoice.id == selected.invoice.id,
                          );

                    return DropdownButtonFormField<InvoiceWithStats>(
                      key: ValueKey(effectiveSelected?.invoice.id),
                      initialValue: effectiveSelected,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: '${l10n.invoices} *',
                        helperText: effectiveSelected == null
                            ? null
                            : 'Balance: ${NumberFormat.currency(symbol: _currencySymbol).format(effectiveSelected.balance)}',
                      ),
                      items: effectiveOptions.map((iwc) {
                        return DropdownMenuItem(
                          value: iwc,
                          child: Text(
                            '${iwc.invoice.invoiceNumber} • ${iwc.client.name} (Bal: ${NumberFormat.currency(symbol: _currencySymbol).format(iwc.balance)})',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedInvoice = value;
                          if (!_isEditing && value != null) {
                            _amountController.text =
                                value.balance.toStringAsFixed(2);
                          }
                        });
                      },
                      validator: (value) =>
                          value == null ? l10n.fieldRequired : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    labelText: '${l10n.date} *',
                    suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: '${l10n.amount} *', prefixText: _currencySymbol),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return l10n.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey(_method),
                  initialValue: _method,
                  decoration: const InputDecoration(labelText: 'Method'),
                  items: const ['Cash', 'Credit Card', 'Bank Transfer', 'Check', 'Other']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (value) => setState(() => _method = value ?? 'Cash'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referenceController,
                  decoration: const InputDecoration(labelText: 'Reference # (optional)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.notes),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(_isEditing ? l10n.update : l10n.save),
        ),
      ],
    );
  }
}
