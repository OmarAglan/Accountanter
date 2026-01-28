import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:accountanter/data/database.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:accountanter/features/main/app_shell_scope.dart';
import 'app_page.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/app_header.dart';
// We will create placeholder screens for these soon
import '../dashboard/dashboard_screen.dart'; 
import '../clients/clients_screen.dart';
import '../invoices/invoices_screen.dart';
import '../invoices/invoice_editor_screen.dart';
import '../inventory/inventory_screen.dart';
import '../expenses/expenses_screen.dart';
import '../payments/payments_screen.dart';
import '../recurring/recurring_invoices_screen.dart';
import '../taxes/tax_management_screen.dart';
import '../documents/documents_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../help/help_screen.dart';
import '../currency/currency_screen.dart';
import '../clients/widgets/add_edit_client_dialog.dart';
import '../inventory/widgets/add_edit_inventory_dialog.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final ValueChanged<Locale> onLocaleChanged;
  const MainScreen({super.key, required this.onLogout, required this.onLocaleChanged});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  AppPage _currentPage = AppPage.dashboard;
  final bool _isSidebarExpanded = true; // For now, let's keep it simple
  final AppDatabase _database = AppDatabase.instance;
  String _userName = 'User';

  // A map to easily get the widget for the current page
  Widget _getCurrentPageWidget() {
    switch (_currentPage) {
      case AppPage.dashboard:
        return const DashboardScreen();
      case AppPage.clients:
        return const ClientsScreen();
      case AppPage.invoices:
        return const InvoicesScreen();
      case AppPage.inventory:
        return const InventoryScreen();
      case AppPage.expenses:
        return const ExpensesScreen();
      case AppPage.recurring:
        return const RecurringInvoicesScreen();
      case AppPage.payments:
        return const PaymentsScreen();
      case AppPage.taxes:
        return const TaxManagementScreen();
      case AppPage.currency:
        return const CurrencyScreen();
      case AppPage.documents:
        return const DocumentsScreen();
      case AppPage.reports:
        return const ReportsScreen();
      case AppPage.settings:
        return SettingsScreen(onLocaleChanged: widget.onLocaleChanged);
      case AppPage.help:
        return const HelpScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _database.getLocalUser();
    if (!mounted) return;
    setState(() {
      _userName = user?.username ?? 'User';
    });
  }

  void _navigateTo(AppPage page) {
    setState(() {
      _currentPage = page;
    });
  }

  String _subtitleForPage(BuildContext context, AppPage page) {
    final l10n = AppLocalizations.of(context)!;
    switch (page) {
      case AppPage.dashboard:
        return l10n.dashboardSubtitle;
      case AppPage.clients:
        return l10n.clients;
      case AppPage.invoices:
        return l10n.invoices;
      case AppPage.inventory:
        return l10n.inventory;
      case AppPage.expenses:
        return l10n.expenses;
      case AppPage.recurring:
        return l10n.recurring;
      case AppPage.payments:
        return l10n.payments;
      case AppPage.taxes:
        return l10n.taxes;
      case AppPage.currency:
        return l10n.currency;
      case AppPage.documents:
        return l10n.documents;
      case AppPage.reports:
        return l10n.reports;
      case AppPage.settings:
        return l10n.settings;
      case AppPage.help:
        return l10n.help;
    }
  }

  void _createInvoice() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const InvoiceEditorScreen()),
    );
  }

  void _addClient() {
    showDialog(
      context: context,
      builder: (context) => AddEditClientDialog(
        onSave: (name, email, type, balance) {
          final newClient = ClientsCompanion.insert(
            name: name,
            email: Value(email),
            type: type,
            balance: Value(type == 'Creditor' ? -balance : balance),
          );
          _database.insertClient(newClient);
        },
      ),
    );
  }

  void _addInventoryItem() {
    showDialog(
      context: context,
      builder: (context) => AddEditInventoryDialog(
        onSave: (item) => _database.insertInventoryItem(item),
      ),
    );
  }

  void _openNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: FutureBuilder<_NotificationSummary>(
            future: _buildNotificationSummary(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 240,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final summary = snapshot.data!;
              final items = summary.toItems(l10n);
              if (items.isEmpty) {
                return SizedBox(
                  height: 240,
                  child: Center(child: Text(l10n.noRecentActivity)),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          leading: Icon(item.icon),
                          title: Text(item.title),
                          subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                          onTap: () {
                            Navigator.of(context).pop();
                            _navigateTo(item.page);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<_NotificationSummary> _buildNotificationSummary() async {
    final overdueInvoicesCount = await ( _database.select(_database.invoices)
          ..where((i) => i.status.equals('Overdue')))
        .get()
        .then((rows) => rows.length);

    final dueSoonCount = await (_database.select(_database.invoices)
          ..where((i) => i.status.equals('Pending') & i.dueDate.isSmallerThanValue(DateTime.now().add(const Duration(days: 7)))))
        .get()
        .then((rows) => rows.length);

    final outOfStockCount = await (_database.select(_database.inventoryItems)
          ..where((i) => i.quantity.equals(0)))
        .get()
        .then((rows) => rows.length);

    final lowStockCount = await (_database.select(_database.inventoryItems)
          ..where((i) => i.quantity.isBiggerThanValue(0) & i.quantity.isSmallerOrEqual(i.minStock)))
        .get()
        .then((rows) => rows.length);

    return _NotificationSummary(
      overdueInvoicesCount: overdueInvoicesCount,
      dueSoonInvoicesCount: dueSoonCount,
      outOfStockItemsCount: outOfStockCount,
      lowStockItemsCount: lowStockCount,
    );
  }

  void _openSearch() {
    showDialog<void>(
      context: context,
      builder: (context) => _GlobalSearchDialog(
        database: _database,
        onNavigate: (page) {
          Navigator.of(context).pop();
          _navigateTo(page);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShellScope(
      actions: AppShellActions(
        navigateTo: _navigateTo,
        createInvoice: _createInvoice,
        addClient: _addClient,
        addInventoryItem: _addInventoryItem,
        openNotifications: _openNotifications,
        openSearch: _openSearch,
        logout: widget.onLogout,
      ),
      child: Scaffold(
        body: Row(
          children: [
            AppSidebar(
              isExpanded: _isSidebarExpanded,
              currentPage: _currentPage,
              onPageSelected: _navigateTo,
              onLogout: widget.onLogout,
            ),
            Expanded(
              child: Column(
                children: [
                  AppHeader(
                    userName: _userName,
                    subtitle: _subtitleForPage(context, _currentPage),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: _getCurrentPageWidget(),
                    ),
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

class _NotificationSummary {
  final int overdueInvoicesCount;
  final int dueSoonInvoicesCount;
  final int outOfStockItemsCount;
  final int lowStockItemsCount;

  const _NotificationSummary({
    required this.overdueInvoicesCount,
    required this.dueSoonInvoicesCount,
    required this.outOfStockItemsCount,
    required this.lowStockItemsCount,
  });

  List<_NotificationItem> toItems(AppLocalizations l10n) {
    final items = <_NotificationItem>[];
    if (overdueInvoicesCount > 0) {
      items.add(_NotificationItem(
        icon: Icons.warning_amber_rounded,
        title: l10n.overdueInvoicesCount(overdueInvoicesCount),
        subtitle: l10n.followUpRequired,
        page: AppPage.invoices,
      ));
    }
    if (dueSoonInvoicesCount > 0) {
      items.add(_NotificationItem(
        icon: Icons.schedule_rounded,
        title: l10n.invoicesDueSoon(dueSoonInvoicesCount),
        subtitle: l10n.dueWithinDays,
        page: AppPage.invoices,
      ));
    }
    if (outOfStockItemsCount > 0) {
      items.add(_NotificationItem(
        icon: Icons.inventory_2_outlined,
        title: '${l10n.outOfStock}: $outOfStockItemsCount',
        page: AppPage.inventory,
      ));
    }
    if (lowStockItemsCount > 0) {
      items.add(_NotificationItem(
        icon: Icons.inventory_2_outlined,
        title: '${l10n.lowStock}: $lowStockItemsCount',
        page: AppPage.inventory,
      ));
    }
    return items;
  }
}

class _NotificationItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final AppPage page;

  const _NotificationItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.page,
  });
}

class _GlobalSearchDialog extends StatefulWidget {
  final AppDatabase database;
  final ValueChanged<AppPage> onNavigate;

  const _GlobalSearchDialog({
    required this.database,
    required this.onNavigate,
  });

  @override
  State<_GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends State<_GlobalSearchDialog> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.searchPlaceholder),
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: l10n.searchPlaceholder,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: FutureBuilder<_SearchResults>(
                future: _search(_query),
                builder: (context, snapshot) {
                  if (_query.isEmpty) {
                    return SizedBox(
                      height: 200,
                      child: Center(child: Text(l10n.noDataAvailable)),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final results = snapshot.data!;
                  if (results.isEmpty) {
                    return SizedBox(
                      height: 200,
                      child: Center(child: Text(l10n.noDataAvailable)),
                    );
                  }
                  final items = results.toItems(l10n);
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: Icon(item.icon),
                        title: Text(item.title),
                        subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                        onTap: () => widget.onNavigate(item.page),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  Future<_SearchResults> _search(String query) async {
    if (query.isEmpty) return const _SearchResults();

    final lower = query.toLowerCase();
    final clients = await widget.database.getAllClients();
    final matchingClients = clients.where((c) {
      return c.name.toLowerCase().contains(lower) || (c.email?.toLowerCase().contains(lower) ?? false);
    }).take(5).toList();

    final inventoryItems = await (widget.database.select(widget.database.inventoryItems)).get();
    final matchingInventory = inventoryItems.where((i) {
      return i.name.toLowerCase().contains(lower) || (i.sku?.toLowerCase().contains(lower) ?? false);
    }).take(5).toList();

    final expenses = await (widget.database.select(widget.database.expenses)).get();
    final matchingExpenses = expenses.where((e) => e.description.toLowerCase().contains(lower)).take(5).toList();

    final invoicesWithClient = await widget.database.watchAllInvoicesWithClient().first;
    final matchingInvoices = invoicesWithClient.where((iwc) {
      return iwc.invoice.invoiceNumber.toLowerCase().contains(lower) || iwc.client.name.toLowerCase().contains(lower);
    }).take(5).toList();

    return _SearchResults(
      clients: matchingClients,
      invoices: matchingInvoices,
      inventoryItems: matchingInventory,
      expenses: matchingExpenses,
    );
  }
}

class _SearchResults {
  final List<Client> clients;
  final List<InvoiceWithClient> invoices;
  final List<InventoryItem> inventoryItems;
  final List<Expense> expenses;

  const _SearchResults({
    this.clients = const [],
    this.invoices = const [],
    this.inventoryItems = const [],
    this.expenses = const [],
  });

  bool get isEmpty => clients.isEmpty && invoices.isEmpty && inventoryItems.isEmpty && expenses.isEmpty;

  List<_SearchItem> toItems(AppLocalizations l10n) {
    final items = <_SearchItem>[];
    for (final c in clients) {
      items.add(_SearchItem(
        icon: Icons.person_outline,
        title: c.name,
        subtitle: l10n.clients,
        page: AppPage.clients,
      ));
    }
    for (final iwc in invoices) {
      items.add(_SearchItem(
        icon: Icons.receipt_long_outlined,
        title: iwc.invoice.invoiceNumber,
        subtitle: '${l10n.invoices} • ${iwc.client.name}',
        page: AppPage.invoices,
      ));
    }
    for (final i in inventoryItems) {
      items.add(_SearchItem(
        icon: Icons.inventory_2_outlined,
        title: i.name,
        subtitle: l10n.inventory,
        page: AppPage.inventory,
      ));
    }
    for (final e in expenses) {
      items.add(_SearchItem(
        icon: Icons.payments_outlined,
        title: e.description,
        subtitle: l10n.expenses,
        page: AppPage.expenses,
      ));
    }
    return items;
  }
}

class _SearchItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final AppPage page;

  const _SearchItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.page,
  });
}
