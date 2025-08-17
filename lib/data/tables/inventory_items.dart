import 'package:drift/drift.dart';

// No annotation is needed here
class InventoryItems extends Table {
  @override
  String get tableName => 'inventory_items';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get category => text()();
  IntColumn get quantity => integer()();
  IntColumn get minStock => integer().withDefault(const Constant(0))();
  RealColumn get unitPrice => real()();
  TextColumn get supplier => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}