import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';

import 'package:accountanter/data/database.dart';
import 'package:accountanter/theme/app_colors.dart';
import 'widgets/add_edit_client_dialog.dart';
import 'widgets/client_summary_card.dart'; // We'll keep this widget as is

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final AppDatabase _database = AppDatabase.instance;
  late Stream<List<Client>> _clientsStream;
  String _searchTerm = '';
  String _filterType = 'All Clients';

  @override
  void initState() {
    super.initState();
    _clientsStream = _database.watchAllClients();
  }
  
  void _showAddClientDialog() {
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

  void _showEditClientDialog(Client clientToEdit) {
    showDialog(
      context: context,
      builder: (context) => AddEditClientDialog(
        client: clientToEdit,
        onSave: (name, email, type, balance) {
          final updatedClient = clientToEdit.toCompanion(false).copyWith(
            name: Value(name),
            email: Value(email),
            type: Value(type),
            balance: Value(type == 'Creditor' ? -balance : balance),
          );
          _database.updateClient(updatedClient);
        },
      ),
    );
  }

  void _confirmAndDeleteClient(Client client) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Client'),
          content: Text('Are you sure you want to delete "${client.name}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
              child: const Text('Delete'),
              onPressed: () {
                _database.deleteClient(client.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Client>>(
      stream: _clientsStream,
      builder: (context, snapshot) {
        final allClients = snapshot.data ?? [];
        
        final filteredClients = allClients.where((client) {
          final searchLower = _searchTerm.toLowerCase();
          final nameMatches = client.name.toLowerCase().contains(searchLower);
          final emailMatches = client.email?.toLowerCase().contains(searchLower) ?? false;
          final typeMatches = _filterType == 'All Clients' ||
                              (_filterType == 'Debtors' && client.type == 'Debtor') ||
                              (_filterType == 'Creditors' && client.type == 'Creditor');
          return (nameMatches || emailMatches) && typeMatches;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSummaryCards(allClients),
            const SizedBox(height: 24),
            _buildFilterBar(),
            const SizedBox(height: 24),
            _buildClientTable(context, filteredClients),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clients', style: Theme.of(context).textTheme.headlineMedium),
            Text(
              'Manage your client relationships and outstanding balances.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showAddClientDialog,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Add New Client'),
        )
      ],
    );
  }

  Widget _buildSummaryCards(List<Client> clients) {
    final totalReceivables = clients.where((c) => c.balance > 0).fold(0.0, (sum, c) => sum + c.balance);
    final totalPayables = clients.where((c) => c.balance < 0).fold(0.0, (sum, c) => sum + c.balance.abs());
    final debtors = clients.where((c) => c.type == 'Debtor').length;
    final creditors = clients.where((c) => c.type == 'Creditor').length;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);


    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 1100 ? 2 : 4;
        double childAspectRatio = constraints.maxWidth < 600 ? 2.0 : 2.2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          children: [
            ClientSummaryCard(icon: LucideIcons.users, title: 'Total Clients', value: clients.length.toString(), color: AppColors.primary),
            ClientSummaryCard(icon: LucideIcons.creditCard, title: 'Total Receivables', value: currencyFormat.format(totalReceivables), color: AppColors.success),
            ClientSummaryCard(icon: LucideIcons.banknote, title: 'Total Payables', value: currencyFormat.format(totalPayables), color: AppColors.warning),
            ClientSummaryCard(icon: LucideIcons.users, title: 'Client Breakdown', value: '$debtors  /  $creditors', subtitle: 'Debtors / Creditors', color: AppColors.info),
          ],
        );
      }
    );
  }
  
  Widget _buildFilterBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _searchTerm = value),
                decoration: const InputDecoration(
                  hintText: 'Search clients by name or email...',
                  prefixIcon: Icon(LucideIcons.search, size: 16),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: _filterType,
                decoration: const InputDecoration(isDense: true),
                items: ['All Clients', 'Debtors', 'Creditors']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _filterType = value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientTable(BuildContext context, List<Client> clients) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Client List', style: Theme.of(context).textTheme.titleLarge),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Client Name')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Outstanding Balance')),
                DataColumn(label: Text('Email Or Phone')),
                DataColumn(label: Text('Actions')),
              ],
              rows: clients.map((client) => _buildDataRow(client)).toList(),
            ),
          ),
           if (clients.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('No clients found.')),
            )
        ],
      ),
    );
  }

  DataRow _buildDataRow(Client client) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    return DataRow(cells: [
      DataCell(Text(client.name, style: const TextStyle(fontWeight: FontWeight.w500))),
      DataCell(
        Chip(
          label: Text(client.type),
          backgroundColor: client.type == 'Debtor' ? AppColors.info.withOpacity(0.1) : AppColors.accent.withOpacity(0.1),
          labelStyle: TextStyle(color: client.type == 'Debtor' ? AppColors.info : AppColors.accent, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
        ),
      ),
      DataCell(
        Text(
          currencyFormat.format(client.balance),
          style: TextStyle(
            color: client.balance == 0 ? null : (client.balance > 0 ? AppColors.success : AppColors.destructive),
            fontFamily: 'monospace'
          ),
        )
      ),
      DataCell(Text(client.email ?? client.phone ?? 'N/A')),
      DataCell(PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _showEditClientDialog(client);
          } else if (value == 'delete') {
            _confirmAndDeleteClient(client);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
          const PopupMenuItem<String>(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.destructive))),
        ],
        icon: const Icon(LucideIcons.ellipsisVertical, size: 16),
      )),
    ]);
  }
}