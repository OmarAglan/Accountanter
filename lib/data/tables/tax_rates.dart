import 'package:drift/drift.dart';

class TaxRates extends Table {
  @override
  String get tableName => 'tax_rates';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get rate => real()(); // Percentage, e.g., 15.0 for 15%
  TextColumn get description => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
