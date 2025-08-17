import 'package:drift/drift.dart';
import 'categories.dart';
import 'suppliers.dart';

class InventoryItems extends Table {
  @override
  String get tableName => 'inventory_items';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  
  // REPLACED: Changed from TextColumn to IntColumn with a foreign key reference
  IntColumn get categoryId => integer().references(Categories, #id)();
  
  IntColumn get quantity => integer()();
  IntColumn get minStock => integer().withDefault(const Constant(0))();
  RealColumn get unitPrice => real()();
  
  // REPLACED: Changed from TextColumn to IntColumn with a foreign key reference
  IntColumn get supplierId => integer().nullable().references(Suppliers, #id)();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}