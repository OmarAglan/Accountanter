import 'package:flutter/material.dart';
import 'package:accountanter/data/database.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'widgets/add_edit_recurring_invoice_dialog.dart';


class RecurringInvoicesScreen extends StatefulWidget {
  const RecurringInvoicesScreen({super.key});

  @override
  State<RecurringInvoicesScreen> createState() => _RecurringInvoicesScreenState();
}

class _RecurringInvoicesScreenState extends State<RecurringInvoicesScreen> {
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _loadCurrencySymbol();
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await AppDatabase.instance.getCurrencySymbol();
    if (!mounted) return;
    setState(() => _currencySymbol = symbol);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.recurring, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text('Automate your billing', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddEditRecurringInvoiceDialog(),
                );
              },
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Create Recurring'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Content
        Card(
          clipBehavior: Clip.antiAlias,
          child: StreamBuilder<List<RecurringInvoiceWithClient>>(
            stream: AppDatabase.instance.watchAllRecurringInvoices(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: ${snapshot.error}'),
                ));
              }
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final list = snapshot.data!;
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.repeat, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No recurring invoices yet.'),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Client')),
                    DataColumn(label: Text('Title/Desc')),
                    DataColumn(label: Text('Frequency')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Next Run')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: list.map((item) {
                    final r = item.recurringInvoice;
                    final c = item.client;
                    final currencyFormat = NumberFormat.currency(symbol: _currencySymbol, decimalDigits: 2);
                    return DataRow(cells: [
                      DataCell(Text(c.name)),
                      DataCell(Text(r.description ?? '-')),
                      DataCell(Text(r.frequency)),
                      DataCell(Text(currencyFormat.format(r.amount), style: const TextStyle(fontFamily: 'monospace'))),
                      DataCell(Text(DateFormat('MMM d, y').format(r.nextRunDate))),
                      DataCell(_buildStatusBadge(context, r.status)),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.pencil, size: 16),
                            onPressed: () {
                               showDialog(
                                context: context,
                                builder: (context) => AddEditRecurringInvoiceDialog(recurringInvoice: r),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                            onPressed: () => _delete(context, r.id),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color = Colors.grey;
    if (status == 'Active') color = Colors.green;
    if (status == 'Paused') color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  void _delete(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Invoice?'),
        content: const Text('This will stop future invoice generation.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await AppDatabase.instance.deleteRecurringInvoice(id);
    }
  }
}
