import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _seedInitialData(); // Add some data for demonstration
    _itemsStream = _watchInventoryWithDetails();
  }

  // Seed some initial categories and suppliers for demonstration
  void _seedInitialData() async {
    final existingCategories = await (_database.select(_database.categories)).get();
    if (existingCategories.isEmpty) {
      await _database.batch((batch) {
        batch.insertAll(_database.categories, [
          CategoriesCompanion.insert(name: 'Electronics', type: 'inventory'),
          CategoriesCompanion.insert(name: 'Accessories', type: 'inventory'),
          CategoriesCompanion.insert(name: 'Software', type: 'inventory'),
        ]);
      });
    }

    final existingSuppliers = await (_database.select(_database.suppliers)).get();
    if (existingSuppliers.isEmpty) {
      await _database.batch((batch) {
        batch.insertAll(_database.suppliers, [
          SuppliersCompanion.insert(name: 'TechCorp'),
          SuppliersCompanion.insert(name: 'OfficeSupply Co'),
          SuppliersCompanion.insert(name: 'CableTech'),
          SuppliersCompanion.insert(name: 'DisplayTech'),
        ]);
      });
    }
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
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "${item.name}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
              child: const Text('Delete'),
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
            Text('Inventory', style: Theme.of(context).textTheme.headlineMedium),
            Text(
              'Manage your product inventory and stock levels.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showAddItemDialog,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Add Product'),
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
        color: color.withOpacity(0.05),
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
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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
            InventorySummaryCard(icon: LucideIcons.package, title: 'Total Products', value: items.length.toString(), color: AppColors.primary),
            InventorySummaryCard(icon: LucideIcons.archive, title: 'Total Value', value: currencyFormat.format(totalValue), color: AppColors.success),
            InventorySummaryCard(icon: LucideIcons.triangleAlert, title: 'Low Stock', value: lowStockCount.toString(), color: AppColors.warning),
            InventorySummaryCard(icon: LucideIcons.packageX, title: 'Out of Stock', value: outOfStockCount.toString(), color: AppColors.destructive),
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
          decoration: const InputDecoration(
            hintText: 'Search products by name, SKU, or category...',
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
            child: Text('Product Inventory', style: textTheme.titleLarge),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Product Name')),
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Unit Price')),
                DataColumn(label: Text('Total Value')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: items.map((itemDetails) => _buildDataRow(itemDetails)).toList(),
            ),
          ),
           if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('No items found.')),
            )
        ],
      ),
    );
  }

  DataRow _buildDataRow(InventoryItemWithDetails details) {
    final item = details.item;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final totalValue = item.quantity * item.unitPrice;
    
    String status;
    Color statusColor;
    if (item.quantity == 0) {
      status = 'Out of Stock';
      statusColor = AppColors.destructive;
    } else if (item.quantity <= item.minStock) {
      status = 'Low Stock';
      statusColor = AppColors.warning;
    } else {
      status = 'In Stock';
      statusColor = AppColors.success;
    }

    final statusChip = Chip(
      label: Text(status),
      backgroundColor: statusColor.withOpacity(0.1),
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
          const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
          const PopupMenuItem<String>(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.destructive))),
        ],
        icon: const Icon(LucideIcons.ellipsisVertical, size: 16),
      )),
    ]);
  }
}