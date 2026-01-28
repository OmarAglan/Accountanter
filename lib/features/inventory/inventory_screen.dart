import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:accountanter/data/database.dart';
import 'package:accountanter/theme/app_colors.dart';
import 'widgets/inventory_summary_card.dart';
import 'widgets/add_edit_inventory_dialog.dart';

// New data class to hold the result of the join
class InventoryItemWithDetails {
  final InventoryItem item;
  final Category category;
  final Supplier? supplier;

  InventoryItemWithDetails({
    required this.item,
    required this.category,
    this.supplier,
  });
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final AppDatabase _database = AppDatabase.instance;
  late Stream<List<InventoryItemWithDetails>> _itemsStream;
  String _searchTerm = '';
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _initializeLookups();
    _itemsStream = _watchInventoryWithDetails();
  }

  Future<void> _initializeLookups() async {
    final demoMode = await _database.isDemoModeEnabled();
    final currencySymbol = await _database.getCurrencySymbol();

    final inventoryCategories =
        await (_database.select(_database.categories)..where((c) => c.type.equals('inventory'))).get();
    if (inventoryCategories.isEmpty) {
      await _database.into(_database.categories).insert(CategoriesCompanion.insert(name: 'General', type: 'inventory'));
      if (demoMode) {
        await _database.batch((batch) {
          batch.insertAll(_database.categories, [
            CategoriesCompanion.insert(name: 'Electronics', type: 'inventory'),
            CategoriesCompanion.insert(name: 'Accessories', type: 'inventory'),
            CategoriesCompanion.insert(name: 'Software', type: 'inventory'),
          ]);
        });
      }
    } else if (demoMode && inventoryCategories.length < 3) {
      await _database.batch((batch) {
        batch.insertAll(_database.categories, [
          CategoriesCompanion.insert(name: 'Electronics', type: 'inventory'),
          CategoriesCompanion.insert(name: 'Accessories', type: 'inventory'),
          CategoriesCompanion.insert(name: 'Software', type: 'inventory'),
        ]);
      });
    }

    final existingSuppliers = await (_database.select(_database.suppliers)).get();
    if (demoMode && existingSuppliers.isEmpty) {
      await _database.batch((batch) {
        batch.insertAll(_database.suppliers, [
          SuppliersCompanion.insert(name: 'TechCorp'),
          SuppliersCompanion.insert(name: 'OfficeSupply Co'),
          SuppliersCompanion.insert(name: 'CableTech'),
          SuppliersCompanion.insert(name: 'DisplayTech'),
        ]);
      });
    }

    if (!mounted) return;
    setState(() {
      _currencySymbol = currencySymbol;
    });
  }
  
  Stream<List<InventoryItemWithDetails>> _watchInventoryWithDetails() {
    final query = _database.select(_database.inventoryItems).join([
      innerJoin(_database.categories, _database.categories.id.equalsExp(_database.inventoryItems.categoryId)),
      leftOuterJoin(_database.suppliers, _database.suppliers.id.equalsExp(_database.inventoryItems.supplierId)),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return InventoryItemWithDetails(
          item: row.readTable(_database.inventoryItems),
          category: row.readTable(_database.categories),
          supplier: row.readTableOrNull(_database.suppliers),
        );
      }).toList();
    });
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditInventoryDialog(
        onSave: (item) {
          _database.insertInventoryItem(item);
        },
      ),
    );
  }

  void _showEditItemDialog(InventoryItem itemToEdit) {
    showDialog(
      context: context,
      builder: (context) => AddEditInventoryDialog(
        item: itemToEdit,
        onSave: (item) {
          _database.updateInventoryItem(item);
        },
      ),
    );
  }

  void _confirmAndDeleteItem(InventoryItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteInventoryItem),
          content: Text('${AppLocalizations.of(context)!.confirmDeleteInventoryItem} "${item.name}"? ${AppLocalizations.of(context)!.deleteConfirmation}'),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
              child: Text(AppLocalizations.of(context)!.delete),
              onPressed: () {
                _database.deleteInventoryItem(item.id);
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
    return StreamBuilder<List<InventoryItemWithDetails>>(
      stream: _itemsStream,
      builder: (context, snapshot) {
        final allItems = snapshot.data ?? [];
        
        final filteredItems = allItems.where((details) {
          final item = details.item;
          final searchLower = _searchTerm.toLowerCase();
          return item.name.toLowerCase().contains(searchLower) ||
                 (item.sku?.toLowerCase().contains(searchLower) ?? false) ||
                 details.category.name.toLowerCase().contains(searchLower);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildAlerts(allItems.map((d) => d.item).toList()),
            const SizedBox(height: 24),
            _buildSummaryCards(allItems.map((d) => d.item).toList()),
            const SizedBox(height: 24),
            _buildFilterBar(),
            const SizedBox(height: 24),
            _buildInventoryTable(context, filteredItems),
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
            Text(AppLocalizations.of(context)!.inventory, style: Theme.of(context).textTheme.headlineMedium),
            Text(
              'Manage your product inventory and stock levels.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showAddItemDialog,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: Text(AppLocalizations.of(context)!.addInventoryItem),
        )
      ],
    );
  }

  Widget _buildAlerts(List<InventoryItem> items) {
    final lowStockItems = items.where((i) => i.quantity > 0 && i.quantity <= i.minStock).toList();
    final outOfStockItems = items.where((i) => i.quantity == 0).toList();

    if (lowStockItems.isEmpty && outOfStockItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (outOfStockItems.isNotEmpty)
          _buildAlert(
            '${outOfStockItems.length} product(s) are out of stock: ${outOfStockItems.map((i) => i.name).join(", ")}',
            AppColors.destructive,
          ),
        if (lowStockItems.isNotEmpty)
          _buildAlert(
            '${lowStockItems.length} product(s) are running low: ${lowStockItems.map((i) => i.name).join(", ")}',
            AppColors.warning,
          ),
      ],
    );
  }

  Widget _buildAlert(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
        color: color.withAlpha(13),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.triangleAlert, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCards(List<InventoryItem> items) {
    final totalValue = items.fold(0.0, (sum, i) => sum + (i.quantity * i.unitPrice));
    final lowStockCount = items.where((i) => i.quantity > 0 && i.quantity <= i.minStock).length;
    final outOfStockCount = items.where((i) => i.quantity == 0).length;
    final currencyFormat = NumberFormat.currency(symbol: _currencySymbol, decimalDigits: 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 1100 ? 2 : 4;
        double childAspectRatio = constraints.maxWidth < 600 ? 2.5 : 2.8;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          children: [
            InventorySummaryCard(icon: LucideIcons.package, title: AppLocalizations.of(context)!.inventory, value: items.length.toString(), color: AppColors.primary),
            InventorySummaryCard(icon: LucideIcons.archive, title: AppLocalizations.of(context)!.total, value: currencyFormat.format(totalValue), color: AppColors.success),
            InventorySummaryCard(icon: LucideIcons.triangleAlert, title: AppLocalizations.of(context)!.lowStock, value: lowStockCount.toString(), color: AppColors.warning),
            InventorySummaryCard(icon: LucideIcons.packageX, title: AppLocalizations.of(context)!.outOfStock, value: outOfStockCount.toString(), color: AppColors.destructive),
          ],
        );
      }
    );
  }
  
  Widget _buildFilterBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          onChanged: (value) => setState(() => _searchTerm = value),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchInventory,
            prefixIcon: Icon(LucideIcons.search, size: 16),
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryTable(BuildContext context, List<InventoryItemWithDetails> items) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(AppLocalizations.of(context)!.inventory, style: textTheme.titleLarge),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(AppLocalizations.of(context)!.itemName)),
                DataColumn(label: Text(AppLocalizations.of(context)!.sku)),
                DataColumn(label: Text(AppLocalizations.of(context)!.category)),
                DataColumn(label: Text(AppLocalizations.of(context)!.quantity)),
                DataColumn(label: Text(AppLocalizations.of(context)!.unitPrice)),
                DataColumn(label: Text(AppLocalizations.of(context)!.total)),
                DataColumn(label: Text(AppLocalizations.of(context)!.status)),
                DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
              ],
              rows: items.map((itemDetails) => _buildDataRow(itemDetails)).toList(),
            ),
          ),
           if (items.isEmpty)
            Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text(AppLocalizations.of(context)!.noInventoryItems)),
            )
        ],
      ),
    );
  }

  DataRow _buildDataRow(InventoryItemWithDetails details) {
    final item = details.item;
    final currencyFormat = NumberFormat.currency(symbol: _currencySymbol, decimalDigits: 2);
    final totalValue = item.quantity * item.unitPrice;
    
    String status;
    Color statusColor;
    if (item.quantity == 0) {
      status = AppLocalizations.of(context)!.outOfStock;
      statusColor = AppColors.destructive;
    } else if (item.quantity <= item.minStock) {
      status = AppLocalizations.of(context)!.lowStock;
      statusColor = AppColors.warning;
    } else {
      status = AppLocalizations.of(context)!.inStock;
      statusColor = AppColors.success;
    }

    final statusChip = Chip(
      label: Text(status),
      backgroundColor: statusColor.withAlpha(26),
      labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );

    return DataRow(cells: [
      DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500))),
      DataCell(Text(item.sku ?? 'N/A')),
      DataCell(Text(details.category.name)),
      DataCell(Text(item.quantity.toString())),
      DataCell(Text(currencyFormat.format(item.unitPrice), style: const TextStyle(fontFamily: 'monospace'))),
      DataCell(Text(currencyFormat.format(totalValue), style: const TextStyle(fontFamily: 'monospace'))),
      DataCell(statusChip),
      DataCell(PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _showEditItemDialog(item);
          } else if (value == 'delete') {
            _confirmAndDeleteItem(item);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(value: 'edit', child: Text(AppLocalizations.of(context)!.edit)),
          PopupMenuItem<String>(value: 'delete', child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: AppColors.destructive))),
        ],
        icon: const Icon(LucideIcons.ellipsisVertical, size: 16),
      )),
    ]);
  }
}
