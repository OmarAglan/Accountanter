import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:accountanter/data/database.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:accountanter/theme/app_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final AppDatabase _database = AppDatabase.instance;
  late Future<_ReportData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ReportData> _load() async {
    final currencySymbol = await _database.getCurrencySymbol();
    final revenueByMonth = await _database.getPaidRevenueByMonth(monthsBack: 12);
    final expensesByMonth = await _database.getExpensesByMonth(monthsBack: 12);
    final receivables = await _database.getTotalReceivables();
    final payables = await _database.getTotalPayables();
    final invoices = await (_database.select(_database.invoices)).get();
    final totalInvoices = invoices.length;
    final overdue = invoices.where((i) => i.status == 'Overdue').length;
    final pending = invoices.where((i) => i.status == 'Pending').length;
    final paid = invoices.where((i) => i.status == 'Paid').length;
    return _ReportData(
      currencySymbol: currencySymbol,
      revenueByMonth: revenueByMonth,
      expensesByMonth: expensesByMonth,
      receivables: receivables,
      payables: payables,
      totalInvoices: totalInvoices,
      overdueInvoices: overdue,
      pendingInvoices: pending,
      paidInvoices: paid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<_ReportData>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final currency = NumberFormat.currency(symbol: data.currencySymbol, decimalDigits: 2);

        final revenueTotal = data.revenueByMonth.fold<double>(0.0, (s, m) => s + m.total);
        final expenseTotal = data.expensesByMonth.fold<double>(0.0, (s, m) => s + m.total);
        final net = revenueTotal - expenseTotal;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reports, style: Theme.of(context).textTheme.headlineMedium),
                    Text('A quick overview of revenue, expenses, and outstanding balances.', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _future = _load()),
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 1100 ? 2 : 4;
                final childAspectRatio = constraints.maxWidth < 600 ? 2.3 : 2.6;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: childAspectRatio,
                  children: [
                    _ReportCard(title: 'Revenue (12m)', value: currency.format(revenueTotal), icon: LucideIcons.trendingUp, color: AppColors.success),
                    _ReportCard(title: 'Expenses (12m)', value: currency.format(expenseTotal), icon: LucideIcons.trendingDown, color: AppColors.destructive),
                    _ReportCard(title: 'Net (12m)', value: currency.format(net), icon: LucideIcons.chartBar, color: net >= 0 ? AppColors.success : AppColors.destructive),
                    _ReportCard(title: l10n.totalReceivables, value: currency.format(data.receivables), icon: LucideIcons.dollarSign, color: AppColors.primary),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 1100 ? 2 : 4;
                final childAspectRatio = constraints.maxWidth < 600 ? 2.3 : 2.6;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: childAspectRatio,
                  children: [
                    _ReportCard(title: l10n.totalPayables, value: currency.format(data.payables), icon: LucideIcons.banknote, color: AppColors.warning),
                    _ReportCard(title: 'Invoices (All)', value: data.totalInvoices.toString(), icon: LucideIcons.fileText, color: AppColors.primary),
                    _ReportCard(title: l10n.overdueInvoices, value: data.overdueInvoices.toString(), icon: LucideIcons.triangleAlert, color: AppColors.destructive),
                    _ReportCard(title: l10n.pending, value: data.pendingInvoices.toString(), icon: LucideIcons.clock, color: AppColors.warning),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            _buildMonthlyTable('Paid Revenue by Month', data.revenueByMonth, currency),
            const SizedBox(height: 24),
            _buildMonthlyTable('Expenses by Month', data.expensesByMonth, currency),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyTable(String title, List<MonthlyTotal> items, NumberFormat currency) {
    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('$title: No data.'),
        ),
      );
    }

    String monthLabel(int year, int month) {
      final dt = DateTime(year, month, 1);
      return DateFormat('MMM yyyy').format(dt);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Month')),
                DataColumn(label: Text('Total')),
              ],
              rows: items.map((m) {
                return DataRow(cells: [
                  DataCell(Text(monthLabel(m.year, m.month))),
                  DataCell(Text(currency.format(m.total), style: const TextStyle(fontFamily: 'monospace'))),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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

class _ReportData {
  final String currencySymbol;
  final List<MonthlyTotal> revenueByMonth;
  final List<MonthlyTotal> expensesByMonth;
  final double receivables;
  final double payables;
  final int totalInvoices;
  final int overdueInvoices;
  final int pendingInvoices;
  final int paidInvoices;

  _ReportData({
    required this.currencySymbol,
    required this.revenueByMonth,
    required this.expensesByMonth,
    required this.receivables,
    required this.payables,
    required this.totalInvoices,
    required this.overdueInvoices,
    required this.pendingInvoices,
    required this.paidInvoices,
  });
}
