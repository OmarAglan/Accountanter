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

part 'database.g.dart';

@DriftDatabase(tables: [
  Users,
  Licenses,
  Clients,
  Expenses,
  InventoryItems,
  Invoices,
  LineItems
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
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
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
      },
    );
  }

  // --- Client Methods ---
  Future<List<Client>> getAllClients() => select(clients).get();
  Stream<List<Client>> watchAllClients() => select(clients).watch();
  Future<int> insertClient(ClientsCompanion client) =>
      into(clients).insert(client);
  Future<bool> updateClient(ClientsCompanion client) =>
      update(clients).replace(client);
  Future<int> deleteClient(int id) =>
      (delete(clients)..where((c) => c.id.equals(id))).go();

  // --- Expense Methods ---
  Future<List<Expense>> getAllExpenses() => select(expenses).get();
  Stream<List<Expense>> watchAllExpenses() => select(expenses).watch();
  Future<int> insertExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense);
  Future<bool> updateExpense(ExpensesCompanion expense) =>
      update(expenses).replace(expense);
  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((e) => e.id.equals(id))).go();

  // --- Inventory Methods ---
  Stream<List<InventoryItem>> watchAllInventoryItems() =>
      select(inventoryItems).watch();
  Future<int> insertInventoryItem(InventoryItemsCompanion item) =>
      into(inventoryItems).insert(item);
  Future<bool> updateInventoryItem(InventoryItemsCompanion item) =>
      update(inventoryItems).replace(item);
  Future<int> deleteInventoryItem(int id) =>
      (delete(inventoryItems)..where((i) => i.id.equals(id))).go();

  // --- Invoice & Line Item Methods ---
  Stream<List<InvoiceWithClient>> watchAllInvoicesWithClient() {
    final query = select(invoices).join(
        [innerJoin(clients, clients.id.equalsExp(invoices.clientId))]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return InvoiceWithClient(
          invoice: row.readTable(invoices),
          client: row.readTable(clients),
        );
      }).toList();
    });
  }

  Future<void> createOrUpdateInvoice(
      InvoicesCompanion invoice, List<LineItemsCompanion> items) {
    return transaction(() async {
      // Insert the invoice and get its ID
      final invoiceId =
          await into(invoices).insert(invoice, mode: InsertMode.insertOrReplace);

      // Delete existing line items for this invoice before inserting new ones (for updates)
      await (delete(lineItems)..where((l) => l.invoiceId.equals(invoiceId)))
          .go();

      // Insert the new line items
      for (final item in items) {
        await into(lineItems).insert(item.copyWith(invoiceId: Value(invoiceId)));
      }
    });
  }

  // --- Auth & System Methods ---
  Future<License?> getLicense() =>
      (select(licenses)..where((l) => l.id.equals(1))).getSingleOrNull();
  Future<void> saveLicense(LicensesCompanion license) =>
      into(licenses).insert(license, mode: InsertMode.replace);
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

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'accountanter.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}