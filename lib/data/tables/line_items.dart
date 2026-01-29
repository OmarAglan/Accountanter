import 'package:drift/drift.dart';
import 'invoices.dart';
import 'inventory_items.dart';

// The @Table annotation has been removed
class LineItems extends Table {
  @override
  String get tableName => 'line_items';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId => integer().references(Invoices, #id)();

  IntColumn get inventoryItemId =>
      integer().nullable().references(InventoryItems, #id)();

  TextColumn get description => text()();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get total => real()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}