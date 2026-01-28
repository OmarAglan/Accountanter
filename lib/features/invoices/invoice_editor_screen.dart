import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';

import 'package:accountanter/data/database.dart';
import 'package:accountanter/theme/app_colors.dart';

class LineItemControllers {
  final TextEditingController descriptionController;
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;
  int? inventoryItemId;

  LineItemControllers({String? description, int? quantity, double? unitPrice, this.inventoryItemId})
      : descriptionController = TextEditingController(text: description ?? ''),
        quantityController = TextEditingController(text: (quantity ?? 1).toString()),
        unitPriceController = TextEditingController(text: (unitPrice ?? 0.0).toStringAsFixed(2));

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }
}

class InvoiceEditorScreen extends StatefulWidget {
  final int? invoiceId;

  const InvoiceEditorScreen({super.key, this.invoiceId});

  @override
  State<InvoiceEditorScreen> createState() => _InvoiceEditorScreenState();
}

class _InvoiceEditorScreenState extends State<InvoiceEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final AppDatabase _database = AppDatabase.instance;
  
  bool get _isEditing => widget.invoiceId != null;
  bool _isLoading = true;
  String _currencySymbol = '\$';
  String _companyName = 'Your Company Name';
  String _companyAddress = '123 Business Street\nBusiness City, BC 12345';
  double _taxRatePercent = 10.0;

  Client? _selectedClient;
  late TextEditingController _invoiceNumberController;
  late TextEditingController _issueDateController;
  late TextEditingController _dueDateController;
  late TextEditingController _notesController;
  final List<LineItemControllers> _lineItemControllers = [];
  DateTime _issueDate = DateTime.now();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _invoiceNumberController = TextEditingController();
    _issueDateController = TextEditingController();
    _dueDateController = TextEditingController();
    _notesController = TextEditingController();

    _loadDefaults();
    if (_isEditing) {
      _loadInvoiceData();
    } else {
      _invoiceNumberController.text = 'INV-${DateTime.now().millisecondsSinceEpoch}';
      _issueDateController.text = DateFormat('yyyy-MM-dd').format(_issueDate);
      _addLineItem();
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDefaults() async {
    final companyName = await _database.getSettingString('company.name');
    final companyAddress = await _database.getSettingString('company.address');
    final currencySymbol = await _database.getSettingString('currency.symbol');
    final defaultTaxRate = await _database.getDefaultTaxRate();

    if (!mounted) return;
    setState(() {
      _companyName = (companyName == null || companyName.trim().isEmpty) ? _companyName : companyName.trim();
      _companyAddress = (companyAddress == null || companyAddress.trim().isEmpty) ? _companyAddress : companyAddress.trim();
      _currencySymbol = (currencySymbol == null || currencySymbol.trim().isEmpty) ? _currencySymbol : currencySymbol.trim();
      _taxRatePercent = defaultTaxRate?.rate ?? _taxRatePercent;
    });
  }

  Future<void> _loadInvoiceData() async {
    final details = await _database.getInvoiceDetails(widget.invoiceId!);
    if (!mounted) return;
    if (details != null) {
      setState(() {
        _selectedClient = details.client;
        _invoiceNumberController.text = details.invoice.invoiceNumber;
        _issueDate = details.invoice.issueDate;
        _issueDateController.text = DateFormat('yyyy-MM-dd').format(_issueDate);
        _dueDate = details.invoice.dueDate;
        _dueDateController.text = _dueDate != null ? DateFormat('yyyy-MM-dd').format(_dueDate!) : '';
        _notesController.text = details.invoice.notes ?? '';

        for (var item in details.lineItems) {
          _lineItemControllers.add(LineItemControllers(
            description: item.description,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          ));
        }
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _issueDateController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    for (var controller in _lineItemControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  void _addLineItem() {
    setState(() {
      _lineItemControllers.add(LineItemControllers());
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _lineItemControllers[index].dispose();
      _lineItemControllers.removeAt(index);
    });
  }
  
  void _updateTotals() {
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isIssueDate ? _issueDate : _dueDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
          _issueDateController.text = DateFormat('yyyy-MM-dd').format(_issueDate);
        } else {
          _dueDate = picked;
          _dueDateController.text = DateFormat('yyyy-MM-dd').format(_dueDate!);
        }
      });
    }
  }

  Future<void> _handleSave(String status) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.pleaseSelect} ${l10n.client}')));
      return;
    }
    if (_lineItemControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.add} ${AppLocalizations.of(context)!.items}')));
      return;
    }
    
    final subtotal = _calculateSubtotal();
    final tax = subtotal * (_taxRatePercent / 100.0);
    final total = subtotal + tax;

    final invoiceCompanion = InvoicesCompanion(
      id: _isEditing ? Value(widget.invoiceId!) : const Value.absent(),
      invoiceNumber: Value(_invoiceNumberController.text),
      clientId: Value(_selectedClient!.id),
      issueDate: Value(_issueDate),
      dueDate: Value(_dueDate ?? _issueDate.add(const Duration(days: 30))),
      subtotal: Value(subtotal),
      taxAmount: Value(tax),
      totalAmount: Value(total),
      status: Value(status),
      notes: Value(_notesController.text),
    );

    final lineItemsCompanions = _lineItemControllers.map((controllers) {
      final quantity = int.tryParse(controllers.quantityController.text) ?? 0;
      final unitPrice = double.tryParse(controllers.unitPriceController.text) ?? 0.0;
      return LineItemsCompanion(
        description: Value(controllers.descriptionController.text),
        quantity: Value(quantity),
        unitPrice: Value(unitPrice),
        total: Value(quantity * unitPrice),
      );
    }).toList();
    
    await _database.createOrUpdateInvoice(invoiceCompanion, lineItemsCompanions);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.invoices} ${AppLocalizations.of(context)!.save} $status')));
      Navigator.of(context).pop();
    }
  }

  double _calculateSubtotal() {
    return _lineItemControllers.fold(0.0, (sum, controllers) {
      final quantity = int.tryParse(controllers.quantityController.text) ?? 0;
      final unitPrice = double.tryParse(controllers.unitPriceController.text) ?? 0.0;
      return sum + (quantity * unitPrice);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildClientAndCompanyDetails(),
              const SizedBox(height: 24),
              _buildInvoiceDetails(),
              const SizedBox(height: 24),
              _buildLineItems(),
              const SizedBox(height: 24),
              _buildSummaryAndNotes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? '${AppLocalizations.of(context)!.editInvoice} ${_invoiceNumberController.text}' : AppLocalizations.of(context)!.createInvoice,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  _isEditing ? 'Update invoice details' : 'Fill in the details for a new invoice',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton(onPressed: () => _handleSave('Draft'), child: Text(AppLocalizations.of(context)!.saveAsDraft)),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: () => _handleSave('Pending'), child: Text(AppLocalizations.of(context)!.saveAndSend)),
          ],
        ),
      ],
    );
  }
  
  Widget _buildClientAndCompanyDetails() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Column(children: [
            _buildCompanyCard(), 
            const SizedBox(height: 16),
            _buildClientCard()
          ]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildCompanyCard()),
            const SizedBox(width: 24),
            Expanded(child: _buildClientCard()),
          ],
        );
      }
    );
  }

  Widget _buildCompanyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(_companyName, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(_companyAddress),
          ],
        ),
      ),
    );
  }
  
  Widget _buildClientCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bill To', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            FutureBuilder<List<Client>>(
              future: _database.getAllClients(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final clients = snapshot.data!;
                return DropdownButtonFormField<Client>(
                  key: ValueKey(_selectedClient?.id),
                  initialValue: _selectedClient,
                  hint: Text(AppLocalizations.of(context)!.selectClient),
                  items: clients.map((client) => DropdownMenuItem(
                    value: client,
                    child: Text(client.name),
                  )).toList(),
                  onChanged: (client) => setState(() => _selectedClient = client),
                   validator: (value) => value == null ? AppLocalizations.of(context)!.fieldRequired : null,
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.invoices, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(children: [
                    TextFormField(controller: _invoiceNumberController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.invoiceNumber)),
                    const SizedBox(height: 16),
                    TextFormField(controller: _issueDateController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.date, suffixIcon: const Icon(LucideIcons.calendar)), readOnly: true, onTap: () => _selectDate(context, true)),
                    const SizedBox(height: 16),
                    TextFormField(controller: _dueDateController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.dueDate, suffixIcon: const Icon(LucideIcons.calendar)), readOnly: true, onTap: () => _selectDate(context, false)),
                  ]);
                }
                return Row(
                  children: [
                    Expanded(child: TextFormField(controller: _invoiceNumberController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.invoiceNumber))),
                    const SizedBox(width: 16),
                    Expanded(child: TextFormField(controller: _issueDateController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.date, suffixIcon: const Icon(LucideIcons.calendar)), readOnly: true, onTap: () => _selectDate(context, true))),
                    const SizedBox(width: 16),
                    Expanded(child: TextFormField(controller: _dueDateController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.dueDate, suffixIcon: const Icon(LucideIcons.calendar)), readOnly: true, onTap: () => _selectDate(context, false))),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLineItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(flex: 4, child: Text(AppLocalizations.of(context)!.description, style: const TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.quantity, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text(AppLocalizations.of(context)!.price, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
                Expanded(flex: 2, child: Text(AppLocalizations.of(context)!.total, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
                const SizedBox(width: 48),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lineItemControllers.length,
              itemBuilder: (context, index) {
                return _buildLineItemRow(index);
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _addLineItem,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: Text(AppLocalizations.of(context)!.addItem),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLineItemRow(int index) {
    final controllers = _lineItemControllers[index];
    final quantity = int.tryParse(controllers.quantityController.text) ?? 0;
    final unitPrice = double.tryParse(controllers.unitPriceController.text) ?? 0.0;
    final total = quantity * unitPrice;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              children: [
                StreamBuilder<List<InventoryItem>>(
                  stream: _database.watchAllInventoryItems(),
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? const <InventoryItem>[];
                    if (items.isEmpty) return const SizedBox.shrink();

                    final selectedId = controllers.inventoryItemId;
                    final hasSelected = selectedId != null && items.any((i) => i.id == selectedId);
                    final effectiveSelectedId = hasSelected ? selectedId : null;

                    return DropdownButtonFormField<int?>(
                      key: ValueKey('line:$index:inventory:${effectiveSelectedId ?? 'none'}'),
                      initialValue: effectiveSelectedId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: '${l10n.inventory} ${l10n.items}',
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text('${l10n.pleaseSelect} (${l10n.optional})'),
                        ),
                        ...items.map((item) {
                          final sku = item.sku;
                          final label = (sku != null && sku.trim().isNotEmpty) ? '${item.name} • $sku' : item.name;
                          return DropdownMenuItem<int?>(value: item.id, child: Text(label, overflow: TextOverflow.ellipsis));
                        }),
                      ],
                      onChanged: (id) {
                        setState(() {
                          controllers.inventoryItemId = id;
                          if (id == null) return;
                          final selected = items.firstWhere((i) => i.id == id);
                          controllers.descriptionController.text = selected.name;
                          controllers.unitPriceController.text = selected.unitPrice.toStringAsFixed(2);
                        });
                        _updateTotals();
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controllers.descriptionController,
                  decoration: InputDecoration(isDense: true, hintText: l10n.description),
                  validator: (v) => v!.isEmpty ? l10n.required : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: TextFormField(
            controller: controllers.quantityController,
            onChanged: (_) => _updateTotals(),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(isDense: true),
            validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null) ? '!' : null,
          )),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: TextFormField(
            controller: controllers.unitPriceController,
            onChanged: (_) => _updateTotals(),
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            decoration: InputDecoration(isDense: true, prefixText: _currencySymbol),
            validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null) ? '!' : null,
          )),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              NumberFormat.currency(symbol: _currencySymbol).format(total),
              textAlign: TextAlign.end,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          )),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.destructive),
            onPressed: () => _removeLineItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryAndNotes() {
    final subtotal = _calculateSubtotal();
    final tax = subtotal * (_taxRatePercent / 100.0);
    final total = subtotal + tax;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Column(children: [
            _buildNotesCard(),
            const SizedBox(height: 16),
            _buildSummaryCard(subtotal, tax, total),
          ]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildNotesCard()),
            const SizedBox(width: 24),
            Expanded(flex: 1, child: _buildSummaryCard(subtotal, tax, total)),
          ],
        );
      }
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.notes, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(hintText: AppLocalizations.of(context)!.notes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double subtotal, double tax, double total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildSummaryRow('${AppLocalizations.of(context)!.subtotal}:', subtotal),
            _buildSummaryRow('${AppLocalizations.of(context)!.tax} (${_taxRatePercent.toStringAsFixed(0)}%):', tax),
            const Divider(height: 24),
            _buildSummaryRow('${AppLocalizations.of(context)!.total}:', total, isTotal: true),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    final style = isTotal 
      ? Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'monospace')
      : Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'monospace');
      
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text(NumberFormat.currency(symbol: _currencySymbol).format(amount), style: style),
        ],
      ),
    );
  }
}
