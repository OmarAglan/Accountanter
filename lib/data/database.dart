import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/users.dart';
import 'tables/licenses.dart';
import 'tables/clients.dart';
import 'tables/expenses.dart';
import 'tables/inventory_items.dart'; // 1. Import the new inventory table

part 'database.g.dart';

@DriftDatabase(tables: [Users, Licenses, Clients, Expenses, InventoryItems]) // 2. Add InventoryItems here
class AppDatabase extends _$AppDatabase {
  // --- SINGLETON SETUP START ---
  AppDatabase._internal() : super(_openConnection());
  static final AppDatabase instance = AppDatabase._internal();
  // --- SINGLETON SETUP END ---

  factory AppDatabase() {
    return instance;
  }

  @override
  int get schemaVersion => 5; // 3. INCREMENT the schema version to 5

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
        if (from < 5) { // 4. ADD this block for the new table
          await m.createTable(inventoryItems);
        }
      },
    );
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

  // --- Inventory Methods --- // 5. ADD new methods for inventory
  Stream<List<InventoryItem>> watchAllInventoryItems() => select(inventoryItems).watch();
  Future<int> insertInventoryItem(InventoryItemsCompanion item) => into(inventoryItems).insert(item);
  Future<bool> updateInventoryItem(InventoryItemsCompanion item) => update(inventoryItems).replace(item);
  Future<int> deleteInventoryItem(int id) => (delete(inventoryItems)..where((i) => i.id.equals(id))).go();


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

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'accountanter.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}