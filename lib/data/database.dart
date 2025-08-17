import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/users.dart';
import 'tables/licenses.dart';
import 'tables/clients.dart';
import 'tables/expenses.dart'; // Import the new expenses table

part 'database.g.dart';

@DriftDatabase(tables: [Users, Licenses, Clients, Expenses]) // Add Expenses here
class AppDatabase extends _$AppDatabase {
  // --- SINGLETON SETUP START ---
  // Private constructor
  AppDatabase._internal() : super(_openConnection());

  // The single, static instance
  static final AppDatabase instance = AppDatabase._internal();
  // --- SINGLETON SETUP END ---

  // The public constructor now just points to the internal one
  factory AppDatabase() {
    return instance;
  }

  @override
  int get schemaVersion => 4; // INCREMENT the schema version to 4

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
        if (from < 4) { // ADD this block for the new table
          await m.createTable(expenses);
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