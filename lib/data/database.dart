import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/users.dart';
import 'tables/licenses.dart';
import 'tables/clients.dart';
import 'tables/expenses.dart';
import 'tables/inventory_items.dart';
import 'tables/invoices.dart';
import 'tables/line_items.dart';
import 'tables/categories.dart'; // Import new table
import 'tables/suppliers.dart'; // Import new table

part 'database.g.dart';

@DriftDatabase(tables: [
  Users,
  Licenses,
  Clients,
  Expenses,
  InventoryItems,
  Invoices,
  LineItems,
  Categories, // Add new table
  Suppliers, // Add new table
])
class AppDatabase extends _$AppDatabase {
  // --- SINGLETON SETUP START ---
  AppDatabase._internal() : super(_openConnection());
  static final AppDatabase instance = AppDatabase._internal();
  // --- SINGLETON SETUP END ---

  factory AppDatabase() {
    return instance;
  }

  @override
  int get schemaVersion => 7; // INCREMENT SCHEMA VERSION

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // ... previous migrations
        if (from < 2) {
          await m.createTable(licenses);
          await m.drop(users);
          await m.createTable(users);
        }
        if (from < 3) {
          await m.createTable(clients);
        }
        if (from < 4) {
          await m.createTable(expenses);
        }
        if (from < 5) {
          await m.createTable(inventoryItems);
        }
        if (from < 6) {
          await m.createTable(invoices);
          await m.createTable(lineItems);
        }
        // NEW MIGRATION LOGIC
        if (from < 7) {
          // 1. Create new tables
          await m.createTable(categories);
          await m.createTable(suppliers);

          // 2. Add new columns to inventory_items table
          await m.addColumn(inventoryItems, inventoryItems.categoryId);
          await m.addColumn(inventoryItems, inventoryItems.supplierId);

          // 3. Data migration (this is a simplified version)
          // In a real app with existing data, you would migrate existing
          // category and supplier strings into the new tables.
          // For this new app, we can skip complex data migration.

          // 4. We can now drop the old columns if we were migrating from an
          // older version of inventoryItems with text fields. Since we are
          // just changing the definition, the generator will handle it.
        }
      },
    );
  }

  // --- Dashboard Data Fetching ---
  Future<DashboardData> getDashboardData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final totalReceivablesFuture = getTotalReceivables();
    final totalPayablesFuture = getTotalPayables();
    final activeClientsCountFuture = getActiveClientsCount();
    
    final overdueInvoicesCountFuture = (select(invoices)..where((i) => i.status.equals('Overdue'))).get().then((l) => l.length);
    final invoicesDueSoonCountFuture = (select(invoices)..where((i) => i.status.equals('Pending') & i.dueDate.isSmallerThanValue(now.add(const Duration(days: 7))))).get().then((l) => l.length);
    final draftInvoicesCountFuture = (select(invoices)..where((i) => i.status.equals('Draft'))).get().then((l) => l.length);

    final moneyInExpr = invoices.totalAmount.sum();
    final moneyInQuery = selectOnly(invoices)..addColumns([moneyInExpr])..where(invoices.status.equals('Paid') & invoices.issueDate.isBiggerOrEqualValue(startOfMonth));
    final moneyInFuture = moneyInQuery.map((row) => row.read(moneyInExpr) ?? 0.0).getSingle();

    final moneyOutExpr = expenses.amount.sum();
    final moneyOutQuery = selectOnly(expenses)..addColumns([moneyOutExpr])..where(expenses.date.isBiggerOrEqualValue(startOfMonth));
    final moneyOutFuture = moneyOutQuery.map((row) => row.read(moneyOutExpr) ?? 0.0).getSingle();

    final recentInvoicesFuture = (select(invoices)..orderBy([(i) => OrderingTerm.desc(i.createdAt)])..limit(2)).get();
    final recentClientsFuture = (select(clients)..orderBy([(c) => OrderingTerm.desc(c.createdAt)])..limit(2)).get();
    final recentExpensesFuture = (select(expenses)..orderBy([(e) => OrderingTerm.desc(e.createdAt)])..limit(2)).get();

    final results = await Future.wait([
      totalReceivablesFuture, totalPayablesFuture, activeClientsCountFuture,
      overdueInvoicesCountFuture, invoicesDueSoonCountFuture, draftInvoicesCountFuture,
      moneyInFuture, moneyOutFuture,
      recentInvoicesFuture, recentClientsFuture, recentExpensesFuture,
    ]);

    final allActivities = [
      ...(results[8] as List<Invoice>).map((i) => RecentActivity(date: i.createdAt, type: ActivityType.invoice, description: 'Invoice ${i.invoiceNumber} created', amount: i.totalAmount)),
      ...(results[9] as List<Client>).map((c) => RecentActivity(date: c.createdAt, type: ActivityType.client, description: 'New client added: ${c.name}', amount: c.balance)),
      ...(results[10] as List<Expense>).map((e) => RecentActivity(date: e.createdAt, type: ActivityType.expense, description: e.description, amount: -e.amount)),
    ];

    allActivities.sort((a, b) => b.date.compareTo(a.date));

    return DashboardData(
      totalReceivables: results[0] as double,
      totalPayables: results[1] as double,
      activeClients: results[2] as int,
      overdueInvoicesCount: results[3] as int,
      invoicesDueSoonCount: results[4] as int,
      draftInvoicesCount: results[5] as int,
      moneyInThisMonth: results[6] as double,
      moneyOutThisMonth: results[7] as double,
      recentActivities: allActivities.take(5).toList(),
    );
  }


  // --- KPI Methods (used by getDashboardData) ---
  Future<double> getTotalReceivables() {
    final total = clients.balance.sum();
    final query = selectOnly(clients)..addColumns([total])..where(clients.balance.isBiggerThanValue(0));
    return query.map((row) => row.read(total) ?? 0.0).getSingle();
  }

  Future<double> getTotalPayables() {
    final total = clients.balance.sum();
    final query = selectOnly(clients)..addColumns([total])..where(clients.balance.isSmallerThanValue(0));
    return query.map((row) => (row.read(total) ?? 0.0).abs()).getSingle();
  }

  Future<int> getActiveClientsCount() {
    final count = clients.id.count();
    final query = selectOnly(clients)..addColumns([count]);
    return query.map((row) => row.read(count) ?? 0).getSingle();
  }

  // --- Client Methods ---
  Future<List<Client>> getAllClients() => select(clients).get();
  Stream<List<Client>> watchAllClients() => select(clients).watch();
  Future<int> insertClient(ClientsCompanion client) => into(clients).insert(client);
  Future<bool> updateClient(ClientsCompanion client) => update(clients).replace(client);
  Future<int> deleteClient(int id) => (delete(clients)..where((c) => c.id.equals(id))).go();

  // --- Expense Methods ---
  Future<List<Expense>> getAllExpenses() => select(expenses).get();
  Stream<List<Expense>> watchAllExpenses() => select(expenses).watch();
  Future<int> insertExpense(ExpensesCompanion expense) => into(expenses).insert(expense);
  Future<bool> updateExpense(ExpensesCompanion expense) => update(expenses).replace(expense);
  Future<int> deleteExpense(int id) => (delete(expenses)..where((e) => e.id.equals(id))).go();

  // --- Inventory Methods ---
  Stream<List<InventoryItem>> watchAllInventoryItems() => select(inventoryItems).watch();
  Future<int> insertInventoryItem(InventoryItemsCompanion item) => into(inventoryItems).insert(item);
  Future<bool> updateInventoryItem(InventoryItemsCompanion item) => update(inventoryItems).replace(item);
  Future<int> deleteInventoryItem(int id) => (delete(inventoryItems)..where((i) => i.id.equals(id))).go();

  // --- Invoice & Line Item Methods ---
  Stream<List<InvoiceWithClient>> watchAllInvoicesWithClient() {
    final query = select(invoices).join([innerJoin(clients, clients.id.equalsExp(invoices.clientId))]);
    return query.watch().map((rows) {
      return rows.map((row) {
        return InvoiceWithClient(invoice: row.readTable(invoices), client: row.readTable(clients));
      }).toList();
    });
  }
  
  Future<InvoiceDetails?> getInvoiceDetails(int invoiceId) async {
    final invoiceQuery = select(invoices)..where((i) => i.id.equals(invoiceId));
    final invoiceResult = await invoiceQuery.getSingleOrNull();
    if (invoiceResult == null) return null;
    final clientQuery = select(clients)..where((c) => c.id.equals(invoiceResult.clientId));
    final clientResult = await clientQuery.getSingle();
    final lineItemsQuery = select(lineItems)..where((l) => l.invoiceId.equals(invoiceId));
    final lineItemsResult = await lineItemsQuery.get();
    return InvoiceDetails(invoice: invoiceResult, client: clientResult, lineItems: lineItemsResult);
  }

  Future<void> createOrUpdateInvoice(InvoicesCompanion invoice, List<LineItemsCompanion> items) {
    return transaction(() async {
      final invoiceId = await into(invoices).insert(invoice, mode: InsertMode.insertOrReplace);
      await (delete(lineItems)..where((l) => l.invoiceId.equals(invoiceId))).go();
      for (final item in items) {
        await into(lineItems).insert(item.copyWith(invoiceId: Value(invoiceId)));
      }
    });
  }

  Future<void> deleteInvoice(int invoiceId) {
    return transaction(() async {
      await (delete(lineItems)..where((l) => l.invoiceId.equals(invoiceId))).go();
      await (delete(invoices)..where((i) => i.id.equals(invoiceId))).go();
    });
  }

  // --- Auth & System Methods ---
  Future<License?> getLicense() => (select(licenses)..where((l) => l.id.equals(1))).getSingleOrNull();
  Future<void> saveLicense(LicensesCompanion license) => into(licenses).insert(license, mode: InsertMode.replace);
  Future<User?> getLocalUser() => (select(users)).getSingleOrNull();
  Future<void> createLocalUser(UsersCompanion user) => into(users).insert(user);
  Future<void> factoryReset() async {
    return transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}

class InvoiceWithClient {
  final Invoice invoice;
  final Client client;
  InvoiceWithClient({required this.invoice, required this.client});
}

class InvoiceDetails {
  final Invoice invoice;
  final Client client;
  final List<LineItem> lineItems;
  InvoiceDetails({required this.invoice, required this.client, required this.lineItems});
}

enum ActivityType { invoice, client, expense }

class RecentActivity {
  final DateTime date;
  final ActivityType type;
  final String description;
  final double amount;
  RecentActivity({required this.date, required this.type, required this.description, required this.amount});
}

class DashboardData {
  final double totalReceivables;
  final double totalPayables;
  final int activeClients;
  final int overdueInvoicesCount;
  final int invoicesDueSoonCount;
  final int draftInvoicesCount;
  final double moneyInThisMonth;
  final double moneyOutThisMonth;
  final List<RecentActivity> recentActivities;

  DashboardData({
    required this.totalReceivables,
    required this.totalPayables,
    required this.activeClients,
    required this.overdueInvoicesCount,
    required this.invoicesDueSoonCount,
    required this.draftInvoicesCount,
    required this.moneyInThisMonth,
    required this.moneyOutThisMonth,
    required this.recentActivities,
  });
}


LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'accountanter.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}