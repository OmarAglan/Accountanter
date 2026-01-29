import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:accountanter/data/database.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'package:accountanter/theme/app_colors.dart';
import 'widgets/add_edit_payment_dialog.dart';
import '../main/widgets/empty_state.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final AppDatabase _database = AppDatabase.instance;
  late final Stream<List<PaymentWithInvoiceAndClient>> _paymentsStream;
  String _searchTerm = '';
  String _currencySymbol = '\$';
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    _paymentsStream = _database.watchAllPaymentsWithInvoiceAndClient();
    _loadCurrencySymbol();
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await _database.getCurrencySymbol();
    if (!mounted) return;
    setState(() => _currencySymbol = symbol);
  }

  void _openAddPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEditPaymentDialog(),
    );
  }

  void _openEditPaymentDialog(PaymentWithInvoiceAndClient payment) {
    showDialog(
      context: context,
      builder: (context) => AddEditPaymentDialog(payment: payment),
    );
  }

  void _confirmAndDeletePayment(PaymentWithInvoiceAndClient payment) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text(l10n.deleteConfirmation),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              await _database.deletePayment(payment.payment.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat =
        NumberFormat.currency(symbol: _currencySymbol, decimalDigits: 2);

    return StreamBuilder<List<PaymentWithInvoiceAndClient>>(
      stream: _paymentsStream,
      builder: (context, snapshot) {
        final all = snapshot.data ?? [];
        final filtered = all.where((p) {
          final q = _searchTerm.toLowerCase();
          return q.isEmpty ||
              p.invoice.invoiceNumber.toLowerCase().contains(q) ||
              p.client.name.toLowerCase().contains(q) ||
              p.payment.method.toLowerCase().contains(q) ||
              (p.payment.referenceNumber?.toLowerCase().contains(q) ?? false);
        }).toList();

        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final monthTotal = all.where((p) => p.payment.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1)))).fold<double>(
              0.0,
              (sum, p) => sum + p.payment.amount,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.payments, style: Theme.of(context).textTheme.headlineMedium),
                    Text('Record and track invoice payments.', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _openAddPaymentDialog,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Record Payment'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 900 ? 2 : 3;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: constraints.maxWidth < 600 ? 2.6 : 3.2,
                  children: [
                    _SummaryCard(
                      title: 'Payments This Month',
                      value: currencyFormat.format(monthTotal),
                      color: AppColors.success,
                      icon: LucideIcons.dollarSign,
                    ),
                    _SummaryCard(
                      title: 'Total Payments',
                      value: all.length.toString(),
                      color: AppColors.primary,
                      icon: LucideIcons.creditCard,
                    ),
                    _SummaryCard(
                      title: 'Search',
                      value: _searchTerm.isEmpty ? 'All' : _searchTerm,
                      color: AppColors.accent,
                      icon: LucideIcons.search,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (v) => setState(() => _searchTerm = v),
                  decoration: InputDecoration(
                    hintText: 'Search payments by invoice, client, method…',
                    prefixIcon: const Icon(LucideIcons.search, size: 16),
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(l10n.payments, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const Divider(height: 1),
                  if (filtered.isEmpty)
                    EmptyState(
                      icon: LucideIcons.creditCard,
                      title: l10n.noPayments,
                      description: 'No payments found. Record a payment for an outstanding invoice.',
                      actionLabel: l10n.recordPayment,
                      onAction: _openAddPaymentDialog,
                    )
                  else
                    Builder(builder: (context) {
                      final source = _PaymentsDataSource(
                        context: context,
                        payments: filtered,
                        currencySymbol: _currencySymbol,
                        onEdit: _openEditPaymentDialog,
                        onDelete: _confirmAndDeletePayment,
                      );

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: PaginatedDataTable(
                          showCheckboxColumn: false,
                          showFirstLastButtons: true,
                          availableRowsPerPage: const [10, 20, 50],
                          rowsPerPage: _rowsPerPage,
                          onRowsPerPageChanged: (v) {
                            if (v == null) return;
                            setState(() => _rowsPerPage = v);
                          },
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Invoice')),
                            DataColumn(label: Text('Client')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Method')),
                            DataColumn(label: Text('Reference')),
                            DataColumn(label: Text('Actions')),
                          ],
                          source: source,
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PaymentsDataSource extends DataTableSource {
  final BuildContext context;
  final List<PaymentWithInvoiceAndClient> payments;
  final String currencySymbol;
  final void Function(PaymentWithInvoiceAndClient payment) onEdit;
  final void Function(PaymentWithInvoiceAndClient payment) onDelete;

  _PaymentsDataSource({
    required this.context,
    required this.payments,
    required this.currencySymbol,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index < 0 || index >= payments.length) return null;
    final p = payments[index];

    final l10n = AppLocalizations.of(context)!;
    final currencyFormat =
        NumberFormat.currency(symbol: currencySymbol, decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(dateFormat.format(p.payment.date))),
        DataCell(Text(p.invoice.invoiceNumber)),
        DataCell(Text(p.client.name)),
        DataCell(Text(currencyFormat.format(p.payment.amount),
            style: const TextStyle(fontFamily: 'monospace'))),
        DataCell(Text(p.payment.method)),
        DataCell(Text(p.payment.referenceNumber ?? '-')),
        DataCell(
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit(p);
              if (value == 'delete') onDelete(p);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.delete,
                    style: const TextStyle(color: AppColors.destructive)),
              ),
            ],
            icon: const Icon(LucideIcons.ellipsisVertical, size: 16),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => payments.length;

  @override
  int get selectedRowCount => 0;
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
