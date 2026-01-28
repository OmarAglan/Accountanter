import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:accountanter/data/database.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:accountanter/theme/app_colors.dart';
import 'widgets/add_edit_tax_rate_dialog.dart';

class TaxManagementScreen extends StatefulWidget {
  const TaxManagementScreen({super.key});

  @override
  State<TaxManagementScreen> createState() => _TaxManagementScreenState();
}

class _TaxManagementScreenState extends State<TaxManagementScreen> {
  final AppDatabase _database = AppDatabase.instance;

  @override
  void initState() {
    super.initState();
    _ensureDefaultTaxRate();
  }

  Future<void> _ensureDefaultTaxRate() async {
    final existing = await (_database.select(_database.taxRates)).get();
    if (existing.isNotEmpty) return;
    final id = await _database.insertTaxRate(TaxRatesCompanion.insert(name: 'Standard', rate: 10.0));
    await _database.setDefaultTaxRate(id);
  }

  void _openAddDialog() {
    showDialog(context: context, builder: (context) => const AddEditTaxRateDialog());
  }

  void _openEditDialog(TaxRate rate) {
    showDialog(context: context, builder: (context) => AddEditTaxRateDialog(taxRate: rate));
  }

  void _confirmDelete(TaxRate rate) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tax Rate'),
        content: Text('${l10n.deleteConfirmation}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            onPressed: () async {
              await _database.deleteTaxRate(rate.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.taxes, style: Theme.of(context).textTheme.headlineMedium),
                Text('Manage tax rates used on invoices.', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _openAddDialog,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Add Tax Rate'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          clipBehavior: Clip.antiAlias,
          child: StreamBuilder<List<TaxRate>>(
            stream: _database.watchAllTaxRates(),
            builder: (context, snapshot) {
              final rates = snapshot.data ?? [];
              if (rates.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No tax rates yet.')),
                );
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Rate')),
                    DataColumn(label: Text('Default')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: rates.map((r) {
                    return DataRow(cells: [
                      DataCell(Text(r.name)),
                      DataCell(Text('${r.rate.toStringAsFixed(2)}%')),
                      DataCell(r.isDefault ? const Icon(Icons.check_circle, color: AppColors.success, size: 18) : const SizedBox.shrink()),
                      DataCell(Text(r.description ?? '-')),
                      DataCell(
                        PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'edit') _openEditDialog(r);
                            if (v == 'default') await _database.setDefaultTaxRate(r.id);
                            if (v == 'delete') _confirmDelete(r);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                            const PopupMenuItem(value: 'default', child: Text('Set Default')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(l10n.delete, style: const TextStyle(color: AppColors.destructive)),
                            ),
                          ],
                          icon: const Icon(LucideIcons.ellipsisVertical, size: 16),
                        ),
                      ),
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
}
