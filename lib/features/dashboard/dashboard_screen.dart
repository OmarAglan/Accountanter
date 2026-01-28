import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'package:accountanter/data/database.dart';
import 'package:accountanter/theme/app_colors.dart';
import 'widgets/kpi_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/action_item_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppDatabase _database = AppDatabase.instance;
  late Future<DashboardData> _dashboardDataFuture;
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _database.getDashboardData();
    _loadCurrencySymbol();
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await _database.getCurrencySymbol();
    if (!mounted) return;
    setState(() => _currencySymbol = symbol);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardData>(
      future: _dashboardDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(AppLocalizations.of(context)!.errorLoadingDashboard(snapshot.error.toString())));
        }
        if (!snapshot.hasData) {
          return Center(child: Text(AppLocalizations.of(context)!.noDataAvailable));
        }

        final data = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.quickActions, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            const QuickActions(),
            const SizedBox(height: 32),
            Text(AppLocalizations.of(context)!.overview, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildKpiGrid(data),
            const SizedBox(height: 32),
            _buildBottomCards(context, data),
            const SizedBox(height: 32),
            _buildRecentActivity(context, data),
          ],
        );
      },
    );
  }

  Widget _buildKpiGrid(DashboardData data) {
    final currencyFormat = NumberFormat.currency(symbol: _currencySymbol, decimalDigits: 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 1200) crossAxisCount = 2;
        if (constraints.maxWidth < 600) crossAxisCount = 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: (crossAxisCount == 1) ? 3.0 : 2.0,
          children: [
            KpiCard(
              title: AppLocalizations.of(context)!.totalReceivables,
              value: currencyFormat.format(data.totalReceivables),
              icon: LucideIcons.dollarSign,
              borderColor: AppColors.success,
            ),
            KpiCard(
              title: AppLocalizations.of(context)!.totalPayables,
              value: currencyFormat.format(data.totalPayables),
              icon: LucideIcons.trendingUp,
              borderColor: AppColors.warning,
            ),
            KpiCard(
              title: AppLocalizations.of(context)!.overdueInvoices,
              value: data.overdueInvoicesCount.toString(),
              icon: LucideIcons.triangleAlert,
              borderColor: AppColors.destructive,
            ),
            KpiCard(
              title: AppLocalizations.of(context)!.activeClients,
              value: data.activeClients.toString(),
              icon: LucideIcons.users,
              borderColor: AppColors.primary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomCards(BuildContext context, DashboardData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          return Column(
            children: [
              _buildCashFlowCard(context, data),
              const SizedBox(height: 24),
              _buildActionRequiredCard(context, data),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildCashFlowCard(context, data)),
            const SizedBox(width: 24),
            Expanded(child: _buildActionRequiredCard(context, data)),
          ],
        );
      },
    );
  }

  Widget _buildCashFlowCard(BuildContext context, DashboardData data) {
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat = NumberFormat.currency(symbol: _currencySymbol, decimalDigits: 2);
    final netFlow = data.moneyInThisMonth - data.moneyOutThisMonth;

    return Card(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.success, width: 4)),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.trendingUp, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.cashFlowThisMonth, style: textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 24),
              _buildCashFlowItem(context, AppLocalizations.of(context)!.moneyIn, currencyFormat.format(data.moneyInThisMonth), AppColors.success, true),
              const SizedBox(height: 16),
              _buildCashFlowItem(context, AppLocalizations.of(context)!.moneyOut, currencyFormat.format(data.moneyOutThisMonth), AppColors.destructive, false),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.netCashFlow, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                  Text(
                    '${netFlow >= 0 ? '+' : ''}${currencyFormat.format(netFlow)}', 
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: netFlow >= 0 ? AppColors.success : AppColors.destructive, fontFamily: 'monospace')
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCashFlowItem(BuildContext context, String label, String value, Color color, bool isUp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontFamily: 'monospace', fontSize: 20)),
            ],
          ),
          Icon(isUp ? LucideIcons.trendingUp : LucideIcons.trendingDown, color: color, size: 32),
        ],
      ),
    );
  }

  Widget _buildActionRequiredCard(BuildContext context, DashboardData data) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.warning, width: 4)),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.triangleAlert, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.actionRequired, style: textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 24),
              ActionItemCard(
                icon: LucideIcons.circleX,
                color: AppColors.destructive,
                title: AppLocalizations.of(context)!.overdueInvoicesCount(data.overdueInvoicesCount),
                subtitle: AppLocalizations.of(context)!.followUpRequired,
              ),
              const SizedBox(height: 16),
              ActionItemCard(
                icon: LucideIcons.triangleAlert,
                color: AppColors.warning,
                title: AppLocalizations.of(context)!.invoicesDueSoon(data.invoicesDueSoonCount),
                subtitle: AppLocalizations.of(context)!.dueWithinDays,
              ),
              const SizedBox(height: 16),
              ActionItemCard(
                icon: LucideIcons.fileText,
                color: AppColors.accent,
                title: AppLocalizations.of(context)!.draftInvoices(data.draftInvoicesCount),
                subtitle: AppLocalizations.of(context)!.readyToBeSent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, DashboardData data) {
    final currencyFormat = NumberFormat.currency(symbol: _currencySymbol);
    
    IconData getActivityIcon(ActivityType type) {
      switch (type) {
        case ActivityType.invoice:
          return LucideIcons.fileText;
        case ActivityType.client:
          return LucideIcons.users;
        case ActivityType.expense:
          return LucideIcons.receipt;
      }
    }
    
    Color getActivityColor(ActivityType type) {
      switch (type) {
        case ActivityType.invoice:
          return AppColors.info;
        case ActivityType.client:
          return AppColors.primary;
        case ActivityType.expense:
          return AppColors.warning;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.clock, size: 20, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.recentActivity, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 24),
            if (data.recentActivities.isEmpty)
              Center(child: Text(AppLocalizations.of(context)!.noRecentActivity))
            else
              ListView.separated(
                itemCount: data.recentActivities.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(height: 32),
                itemBuilder: (context, index) {
                  final activity = data.recentActivities[index];
                  final color = getActivityColor(activity.type);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(getActivityIcon(activity.type), color: color, size: 20),
                    ),
                    title: Text(activity.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(DateFormat.yMMMd().add_jm().format(activity.date)),
                    trailing: Text(
                      currencyFormat.format(activity.amount), 
                      style: TextStyle(
                        fontFamily: 'monospace', 
                        color: activity.amount >= 0 ? AppColors.success : AppColors.destructive
                      )
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
