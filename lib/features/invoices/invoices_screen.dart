import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'package:accountanter/data/database.dart';
import 'package:accountanter/theme/app_colors.dart';
import 'widgets/invoice_summary_card.dart';
import 'invoice_editor_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> with SingleTickerProviderStateMixin {
  final AppDatabase _database = AppDatabase.instance;
  late Stream<List<InvoiceWithClient>> _invoicesStream;
  String _searchTerm = '';
  late TabController _tabController;
  late List<String> _tabs;
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _tabs = ['All', 'Paid', 'Pending', 'Overdue', 'Draft'];
    _tabController = TabController(length: _tabs.length, vsync: this);
    _invoicesStream = _database.watchAllInvoicesWithClient();
    _loadCurrencySymbol();
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await _database.getCurrencySymbol();
    if (!mounted) return;
    setState(() => _currencySymbol = symbol);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _tabs = [l10n.all, l10n.paid, l10n.pending, l10n.overdue, l10n.draft];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToInvoiceEditor({int? invoiceId}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => InvoiceEditorScreen(invoiceId: invoiceId)),
    );
  }

  void _confirmAndDeleteInvoice(Invoice invoice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteInvoice),
          content: Text('${AppLocalizations.of(context)!.confirmDeleteInvoice} "${invoice.invoiceNumber}"? ${AppLocalizations.of(context)!.deleteConfirmation}'),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
              child: Text(AppLocalizations.of(context)!.delete),
              onPressed: () {
                _database.deleteInvoice(invoice.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${AppLocalizations.of(context)!.invoices} ${invoice.invoiceNumber} deleted.'))
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InvoiceWithClient>>(
      stream: _invoicesStream,
      builder: (context, snapshot) {
        final allInvoices = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSummaryCards(allInvoices),
            const SizedBox(height: 24),
            _buildFilterBar(),
            const SizedBox(height: 24),
            _buildInvoicesTable(context, allInvoices),
          ],
        );
      },
    );
  }

  List<InvoiceWithClient> _filterInvoices(List<InvoiceWithClient> allInvoices) {
    final status = _tabs[_tabController.index];
    return allInvoices.where((iwc) {
      final searchLower = _searchTerm.toLowerCase();
      final clientMatches = iwc.client.name.toLowerCase().contains(searchLower);
      final numberMatches = iwc.invoice.invoiceNumber.toLowerCase().contains(searchLower);
      final statusMatches = (status == 'All') || (iwc.invoice.status == status);
      return (clientMatches || numberMatches) && statusMatches;
    }).toList();
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.invoices, style: Theme.of(context).textTheme.headlineMedium),
            Text('Create, manage, and track your invoices.', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _navigateToInvoiceEditor,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: Text(AppLocalizations.of(context)!.newInvoice),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(List<InvoiceWithClient> invoices) {
    final totalRevenue = invoices.where((i) => i.invoice.status == 'Paid').fold(0.0, (sum, i) => sum + i.invoice.totalAmount);
    final pendingRevenue = invoices.where((i) => i.invoice.status == 'Pending').fold(0.0, (sum, i) => sum + i.invoice.totalAmount);
    final overdueRevenue = invoices.where((i) => i.invoice.status == 'Overdue').fold(0.0, (sum, i) => sum + i.invoice.totalAmount);
    final currencyFormat = NumberFormat.currency(symbol: _currencySymbol, decimalDigits: 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 1100 ? 2 : 4;
        double childAspectRatio = constraints.maxWidth < 600 ? 3.0 : 3.5;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          children: [
            InvoiceSummaryCard(title: 'Paid Revenue', value: currencyFormat.format(totalRevenue), color: AppColors.success),
            InvoiceSummaryCard(title: 'Pending Revenue', value: currencyFormat.format(pendingRevenue), color: AppColors.warning),
            InvoiceSummaryCard(title: 'Overdue Revenue', value: currencyFormat.format(overdueRevenue), color: AppColors.destructive),
            InvoiceSummaryCard(title: 'Total Invoices', value: invoices.length.toString(), color: AppColors.primary),
          ],
        );
      },
    );
  }
  
  Widget _buildFilterBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          onChanged: (value) => setState(() => _searchTerm = value),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchInvoices,
            prefixIcon: Icon(LucideIcons.search, size: 16),
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildInvoicesTable(BuildContext context, List<InvoiceWithClient> allInvoices) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: _tabs.map((label) => Tab(text: label)).toList(),
            onTap: (_) => setState(() {}),
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((_) {
                final filteredList = _filterInvoices(allInvoices);
                return _buildDataTable(filteredList);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataTable(List<InvoiceWithClient> invoices) {
    if (invoices.isEmpty) {
      return Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(AppLocalizations.of(context)!.noInvoices),
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(AppLocalizations.of(context)!.invoiceNumber)),
          DataColumn(label: Text(AppLocalizations.of(context)!.client)),
          DataColumn(label: Text(AppLocalizations.of(context)!.amount)),
          DataColumn(label: Text(AppLocalizations.of(context)!.status)),
          DataColumn(label: Text(AppLocalizations.of(context)!.dueDate)),
          DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
        ],
        rows: invoices.map((iwc) => _buildDataRow(iwc)).toList(),
      ),
    );
  }

  DataRow _buildDataRow(InvoiceWithClient iwc) {
    final currencyFormat = NumberFormat.currency(symbol: _currencySymbol, decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return DataRow(cells: [
      DataCell(Text(iwc.invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w500))),
      DataCell(Text(iwc.client.name)),
      DataCell(Text(currencyFormat.format(iwc.invoice.totalAmount), style: const TextStyle(fontFamily: 'monospace'))),
      DataCell(_buildStatusChip(iwc.invoice.status)),
      DataCell(Text(dateFormat.format(iwc.invoice.dueDate))),
      DataCell(PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _navigateToInvoiceEditor(invoiceId: iwc.invoice.id);
          } else if (value == 'delete') {
            _confirmAndDeleteInvoice(iwc.invoice);
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(value: 'edit', child: Text(AppLocalizations.of(context)!.edit)),
          PopupMenuItem<String>(value: 'delete', child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: AppColors.destructive))),
        ],
        icon: const Icon(LucideIcons.ellipsisVertical, size: 16),
      )),
    ]);
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Paid': color = AppColors.success; break;
      case 'Pending': color = AppColors.warning; break;
      case 'Overdue': color = AppColors.destructive; break;
      case 'Draft': color = AppColors.mutedForeground; break;
      default: color = AppColors.mutedForeground;
    }
    return Chip(
      label: Text(status),
      backgroundColor: color.withAlpha(26),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }
}
