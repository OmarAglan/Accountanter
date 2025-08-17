import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';

import 'package:accountanter/data/database.dart';
import 'package:accountanter/theme/app_colors.dart';

class LineItem {
  String description;
  int quantity;
  double unitPrice;
  double get total => quantity * unitPrice;

  LineItem({
    this.description = '',
    this.quantity = 1,
    this.unitPrice = 0.0,
  });
}

class InvoiceEditorScreen extends StatefulWidget {
  final Invoice? invoice; // Pass an invoice to edit it

  const InvoiceEditorScreen({super.key, this.invoice});

  @override
  State<InvoiceEditorScreen> createState() => _InvoiceEditorScreenState();
}

class _InvoiceEditorScreenState extends State<InvoiceEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final AppDatabase _database = AppDatabase.instance;
  
  bool get _isEditing => widget.invoice != null;

  // Form State
  Client? _selectedClient;
  late TextEditingController _invoiceNumberController;
  late TextEditingController _issueDateController;
  late TextEditingController _dueDateController;
  late TextEditingController _notesController;
  late List<LineItem> _lineItems;
  DateTime _issueDate = DateTime.now();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    // Initialize form fields based on whether we are editing or creating
    if (_isEditing) {
      final inv = widget.invoice!;
      // In a real app, you would fetch the client and line items for this invoice
      _invoiceNumberController = TextEditingController(text: inv.invoiceNumber);
      _issueDate = inv.issueDate;
      _dueDate = inv.dueDate;
      _notesController = TextEditingController(text: inv.notes ?? '');
      _lineItems = []; // Placeholder, would be fetched from db
    } else {
      _invoiceNumberController = TextEditingController(text: 'INV-001'); // Placeholder
      _notesController = TextEditingController();
      _lineItems = [LineItem()]; // Start with one empty line item
    }
    _issueDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_issueDate));
    _dueDateController = TextEditingController(text: _dueDate != null ? DateFormat('yyyy-MM-dd').format(_dueDate!) : '');
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _issueDateController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _addLineItem() {
    setState(() {
      _lineItems.add(LineItem());
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _lineItems.removeAt(index);
    });
  }
  
  void _updateLineItem() {
    setState(() {}); // Just trigger a rebuild to update totals
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isIssueDate ? _issueDate : _dueDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
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

  @override
  Widget build(BuildContext context) {
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
                  _isEditing ? 'Edit Invoice ${widget.invoice!.invoiceNumber}' : 'Create New Invoice',
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
            OutlinedButton(onPressed: () {}, child: const Text('Save as Draft')),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: () {}, child: const Text('Save and Send')),
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
            const Text('Your Company Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('123 Business Street\nBusiness City, BC 12345'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildClientCard() {
    // In a real app, this would use a searchable dropdown or similar
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
                  value: _selectedClient,
                  hint: const Text('Select a client'),
                  items: clients.map((client) => DropdownMenuItem(
                    value: client,
                    child: Text(client.name),
                  )).toList(),
                  onChanged: (client) => setState(() => _selectedClient = client),
                   validator: (value) => value == null ? 'Please select a client' : null,
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
            Text('Invoice Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(children: [
                    TextFormField(controller: _invoiceNumberController, decoration: const InputDecoration(labelText: 'Invoice Number')),
                    const SizedBox(height: 16),
                    TextFormField(controller: _issueDateController, decoration: const InputDecoration(labelText: 'Issue Date', suffixIcon: Icon(LucideIcons.calendar)), readOnly: true, onTap: () => _selectDate(context, true)),
                    const SizedBox(height: 16),
                    TextFormField(controller: _dueDateController, decoration: const InputDecoration(labelText: 'Due Date', suffixIcon: Icon(LucideIcons.calendar)), readOnly: true, onTap: () => _selectDate(context, false)),
                  ]);
                }
                return Row(
                  children: [
                    Expanded(child: TextFormField(controller: _invoiceNumberController, decoration: const InputDecoration(labelText: 'Invoice Number'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextFormField(controller: _issueDateController, decoration: const InputDecoration(labelText: 'Issue Date', suffixIcon: Icon(LucideIcons.calendar)), readOnly: true, onTap: () => _selectDate(context, true))),
                    const SizedBox(width: 16),
                    Expanded(child: TextFormField(controller: _dueDateController, decoration: const InputDecoration(labelText: 'Due Date', suffixIcon: Icon(LucideIcons.calendar)), readOnly: true, onTap: () => _selectDate(context, false))),
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
            // Header
            Row(
              children: [
                const Expanded(flex: 4, child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                const Expanded(flex: 2, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                const Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                const SizedBox(width: 48), // For delete button
              ],
            ),
            const Divider(),
            // Items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lineItems.length,
              itemBuilder: (context, index) {
                return _buildLineItemRow(index);
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _addLineItem,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Add Line Item'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLineItemRow(int index) {
    final item = _lineItems[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: TextFormField(
            initialValue: item.description,
            onChanged: (val) => item.description = val,
            decoration: const InputDecoration(isDense: true, hintText: 'Item description'),
          )),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: TextFormField(
            initialValue: item.quantity.toString(),
            onChanged: (val) {
              item.quantity = int.tryParse(val) ?? 1;
              _updateLineItem();
            },
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(isDense: true),
          )),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: TextFormField(
            initialValue: item.unitPrice.toStringAsFixed(2),
            onChanged: (val) {
              item.unitPrice = double.tryParse(val) ?? 0.0;
              _updateLineItem();
            },
            textAlign: TextAlign.right,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            decoration: const InputDecoration(isDense: true, prefixText: '\$'),
          )),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              NumberFormat.currency(symbol: '\$').format(item.total),
              textAlign: TextAlign.right,
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
    final subtotal = _lineItems.fold(0.0, (sum, item) => sum + item.total);
    const taxRate = 0.1; // Placeholder 10% tax
    final tax = subtotal * taxRate;
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
            Text('Notes & Terms', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Payment terms, additional notes...'),
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
            _buildSummaryRow('Subtotal:', subtotal),
            _buildSummaryRow('Tax (10%):', tax),
            const Divider(height: 24),
            _buildSummaryRow('Total Amount Due:', total, isTotal: true),
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
          Text(NumberFormat.currency(symbol: '\$').format(amount), style: style),
        ],
      ),
    );
  }
}