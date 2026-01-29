import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'package:accountanter/data/database.dart';
import 'package:accountanter/theme/app_colors.dart';
import 'widgets/invoice_summary_card.dart';
import 'invoice_editor_screen.dart';
import '../payments/widgets/add_edit_payment_dialog.dart';
import '../main/widgets/empty_state.dart';
import '../../utils/csv_export_util.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen>
    with SingleTickerProviderStateMixin {
  static const List<String?> _statusFilters = <String?>[
    null, // All
    'Paid',
    'Pending',
    'Overdue',
    'Draft',
  ];

  final AppDatabase _database = AppDatabase.instance;
  late Stream<List<InvoiceWithStats>> _invoicesStream;
  String _searchTerm = '';
  late TabController _tabController;
  late List<String> _tabLabels;
  String _currencySymbol = '\$';
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    _tabLabels = const ['All', 'Paid', 'Pending', 'Overdue', 'Draft'];
    _tabController = TabController(length: _statusFilters.length, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _invoicesStream = _database.watchAllInvoicesWithStats();
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
    _tabLabels = [l10n.all, l10n.paid, l10n.pending, l10n.overdue, l10n.draft];
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
    return StreamBuilder<List<InvoiceWithStats>>(
      stream: _invoicesStream,
      builder: (context, snapshot) {
        final allInvoices = snapshot.data ?? [];
        final filteredInvoices = _filterInvoices(allInvoices);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, filteredInvoices),
            const SizedBox(height: 24),
            _buildSummaryCards(filteredInvoices),
            const SizedBox(height: 24),
            _buildFilterBar(),
            const SizedBox(height: 24),
            _buildDataTable(filteredInvoices),
          ],
        );
      },
    );
  }

  List<InvoiceWithStats> _filterInvoices(List<InvoiceWithStats> allInvoices) {
    final statusFilter = _statusFilters[_tabController.index];
    return allInvoices.where((iwc) {
      final searchLower = _searchTerm.toLowerCase();
      final clientMatches = iwc.client.name.toLowerCase().contains(searchLower);
      final numberMatches =
          iwc.invoice.invoiceNumber.toLowerCase().contains(searchLower);
      final statusMatches =
          statusFilter == null || (iwc.invoice.status == statusFilter);
      return (clientMatches || numberMatches) && statusMatches;
    }).toList();
  }

  Future<void> _exportToCsv(List<InvoiceWithStats> invoices) async {
    final path = await CsvExportUtil.exportInvoices(invoices);
    if (mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${AppLocalizations.of(context)!.export} ${AppLocalizations.of(context)!.success}: $path'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.error),
          backgroundColor: AppColors.destructive,
        ));
      }
    }
  }

  Widget _buildHeader(BuildContext context, List<InvoiceWithStats> invoices) {
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
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _exportToCsv(invoices),
              icon: const Icon(LucideIcons.download, size: 16),
              label: Text(AppLocalizations.of(context)!.export),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _navigateToInvoiceEditor,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: Text(AppLocalizations.of(context)!.newInvoice),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCards(List<InvoiceWithStats> invoices) {
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
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: _tabLabels.map((t) => Tab(text: t)).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => setState(() => _searchTerm = value),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchInvoices,
                prefixIcon: Icon(LucideIcons.search, size: 16),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildDataTable(List<InvoiceWithStats> invoices) {
    if (invoices.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return EmptyState(
        icon: LucideIcons.fileText,
        title: l10n.noInvoices,
        description: 'No invoices found. Create your first invoice to get started.',
        actionLabel: l10n.newInvoice,
        onAction: _navigateToInvoiceEditor,
      );
    }

    final source = _InvoicesDataSource(
      context: context,
      invoices: invoices,
      currencySymbol: _currencySymbol,
      statusChipBuilder: _buildStatusChip,
      onEdit: (id) => _navigateToInvoiceEditor(invoiceId: id),
      onRecordPayment: (iwc) {
        showDialog(
          context: context,
          builder: (context) => AddEditPaymentDialog(initialInvoice: iwc),
        );
      },
      onDelete: _confirmAndDeleteInvoice,
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
        columns: [
          DataColumn(label: Text(AppLocalizations.of(context)!.invoiceNumber)),
          DataColumn(label: Text(AppLocalizations.of(context)!.client)),
          DataColumn(label: Text(AppLocalizations.of(context)!.amount)),
          DataColumn(label: Text(AppLocalizations.of(context)!.outstandingBalance)),
          DataColumn(label: Text(AppLocalizations.of(context)!.status)),
          DataColumn(label: Text(AppLocalizations.of(context)!.dueDate)),
          DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
        ],
        source: source,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final l10n = AppLocalizations.of(context)!;

    Color color;
    String label;
    switch (status) {
      case 'Paid':
        color = AppColors.success;
        label = l10n.paid;
        break;
      case 'Pending':
        color = AppColors.warning;
        label = l10n.pending;
        break;
      case 'Overdue':
        color = AppColors.destructive;
        label = l10n.overdue;
        break;
      case 'Draft':
        color = AppColors.mutedForeground;
        label = l10n.draft;
        break;
      default:
        color = AppColors.mutedForeground;
        label = status;
    }
    return Chip(
      label: Text(label),
      backgroundColor: color.withAlpha(26),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _InvoicesDataSource extends DataTableSource {
  final BuildContext context;
  final List<InvoiceWithStats> invoices;
  final String currencySymbol;

  final Widget Function(String status) statusChipBuilder;
  final void Function(int invoiceId) onEdit;
  final void Function(InvoiceWithStats iwc) onRecordPayment;
  final void Function(Invoice invoice) onDelete;

  _InvoicesDataSource({
    required this.context,
    required this.invoices,
    required this.currencySymbol,
    required this.statusChipBuilder,
    required this.onEdit,
    required this.onRecordPayment,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index < 0 || index >= invoices.length) return null;
    final iwc = invoices[index];

    final currencyFormat =
        NumberFormat.currency(symbol: currencySymbol, decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');
    final l10n = AppLocalizations.of(context)!;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(iwc.invoice.invoiceNumber,
            style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(Text(iwc.client.name)),
        DataCell(Text(currencyFormat.format(iwc.invoice.totalAmount),
            style: const TextStyle(fontFamily: 'monospace'))),
        DataCell(Text(
          currencyFormat.format(iwc.balance),
          style: TextStyle(
            fontFamily: 'monospace',
            color: iwc.balance > 0 ? AppColors.destructive : AppColors.success,
            fontWeight: iwc.balance > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        )),
        DataCell(statusChipBuilder(iwc.invoice.status)),
        DataCell(Text(dateFormat.format(iwc.invoice.dueDate))),
        DataCell(PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit(iwc.invoice.id);
            if (value == 'record_payment') onRecordPayment(iwc);
            if (value == 'delete') onDelete(iwc.invoice);
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(value: 'edit', child: Text(l10n.edit)),
            PopupMenuItem<String>(
                value: 'record_payment', child: Text(l10n.recordPayment)),
            PopupMenuItem<String>(
              value: 'delete',
              child: Text(l10n.delete,
                  style: const TextStyle(color: AppColors.destructive)),
            ),
          ],
          icon: const Icon(LucideIcons.ellipsisVertical, size: 16),
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => invoices.length;

  @override
  int get selectedRowCount => 0;
}
