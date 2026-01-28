import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:accountanter/data/database.dart';

class AddEditRecurringInvoiceDialog extends StatefulWidget {
  final RecurringInvoice? recurringInvoice;

  const AddEditRecurringInvoiceDialog({super.key, this.recurringInvoice});

  @override
  State<AddEditRecurringInvoiceDialog> createState() => _AddEditRecurringInvoiceDialogState();
}

class _AddEditRecurringInvoiceDialogState extends State<AddEditRecurringInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int? _selectedClientId;
  String _selectedFrequency = 'Monthly';
  DateTime _startDate = DateTime.now();
  
  bool _isLoading = false;
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _loadCurrencySymbol();
    if (widget.recurringInvoice != null) {
      _selectedClientId = widget.recurringInvoice!.clientId;
      _selectedFrequency = widget.recurringInvoice!.frequency;
      _amountController.text = widget.recurringInvoice!.amount.toString();
      _descriptionController.text = widget.recurringInvoice!.description ?? '';
      _startDate = widget.recurringInvoice!.startDate;
    }
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await AppDatabase.instance.getCurrencySymbol();
    if (!mounted) return;
    setState(() => _currencySymbol = symbol);
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate() && _selectedClientId != null) {
      setState(() => _isLoading = true);

      final db = AppDatabase.instance;
      final amount = double.parse(_amountController.text);
      
      final entry = RecurringInvoicesCompanion(
        clientId: drift.Value(_selectedClientId!),
        frequency: drift.Value(_selectedFrequency),
        amount: drift.Value(amount),
        description: drift.Value(_descriptionController.text),
        startDate: drift.Value(_startDate),
        nextRunDate: drift.Value(_startDate), // Simplification: Next run is start date initially
        // id is handled automatically for insert, explicitly for update if needed context
      );

      if (widget.recurringInvoice == null) {
        await db.insertRecurringInvoice(entry);
      } else {
        await db.updateRecurringInvoice(entry.copyWith(id: drift.Value(widget.recurringInvoice!.id)));
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: StreamBuilder<List<Client>>(
            stream: AppDatabase.instance.watchAllClients(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final clients = snapshot.data!;
              
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recurringInvoice == null ? 'New Recurring Invoice' : 'Edit Recurring Invoice',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    
                    // Client & Frequency Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            key: ValueKey(_selectedClientId),
                            initialValue: _selectedClientId,
                            decoration: const InputDecoration(labelText: 'Client'),
                            items: clients.map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            )).toList(),
                            onChanged: (v) => setState(() => _selectedClientId = v),
                            validator: (v) => v == null ? 'Select a client' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            key: ValueKey(_selectedFrequency),
                            initialValue: _selectedFrequency,
                            decoration: const InputDecoration(labelText: 'Frequency'),
                            items: ['Weekly', 'Monthly', 'Quarterly', 'Yearly']
                                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedFrequency = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Amount & Date
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            decoration: InputDecoration(labelText: 'Amount', prefixText: _currencySymbol),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                              );
                              if (picked != null) setState(() => _startDate = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Start Date', suffixIcon: Icon(LucideIcons.calendar)),
                              child: Text(_startDate.toLocal().toString().split(' ')[0]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description (Optional)'),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _save,
                          child: _isLoading ? const CircularProgressIndicator() : const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
