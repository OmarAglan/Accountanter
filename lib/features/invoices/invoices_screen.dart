import 'package:flutter/material.dart';
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
  final List<String> _tabs = ['All', 'Paid', 'Pending', 'Overdue', 'Draft'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _invoicesStream = _database.watchAllInvoicesWithClient();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToInvoiceEditor() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const InvoiceEditorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InvoiceWithClient>>(
      stream: _invoicesStream,
      builder: (context, snapshot) {
        final allInvoices = snapshot.data ?? [];

        // This logic will be inside the TabBarView builder
        // final filteredInvoices = _filterInvoices(allInvoices);

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
      
      final statusMatches = (status == 'All') || (iwc.invoice.status.toLowerCase() == status.toLowerCase());

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
            Text('Invoices', style: Theme.of(context).textTheme.headlineMedium),
            Text('Create, manage, and track your invoices.', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _navigateToInvoiceEditor,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('New Invoice'),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(List<InvoiceWithClient> invoices) {
    final totalRevenue = invoices.where((i) => i.invoice.status == 'Paid').fold(0.0, (sum, i) => sum + i.invoice.totalAmount);
    final pendingRevenue = invoices.where((i) => i.invoice.status == 'Pending').fold(0.0, (sum, i) => sum + i.invoice.totalAmount);
    final overdueRevenue = invoices.where((i) => i.invoice.status == 'Overdue').fold(0.0, (sum, i) => sum + i.invoice.totalAmount);
    
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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
          decoration: const InputDecoration(
            hintText: 'Search invoices by ID or client...',
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
            onTap: (_) => setState(() {}), // Rebuild to apply filter
          ),
          SizedBox(
            height: 400, // Define a height for the TabBarView
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
      return const Center(child: Text('No invoices found.'));
    }

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Invoice #')),
          DataColumn(label: Text('Client')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Due Date')),
          DataColumn(label: Text('Actions')),
        ],
        rows: invoices.map((iwc) => _buildDataRow(iwc)).toList(),
      ),
    );
  }

  DataRow _buildDataRow(InvoiceWithClient iwc) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
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
            // TODO: Navigate to edit screen with iwc.invoice
          } else if (value == 'delete') {
            // TODO: Show delete confirmation dialog
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
          const PopupMenuItem<String>(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.destructive))),
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
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }
}