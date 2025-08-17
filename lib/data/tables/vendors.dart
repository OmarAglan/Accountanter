import 'package:drift/drift.dart';

class Vendors extends Table {
  @override
  String get tableName => 'vendors';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique().withLength(min: 1, max: 100)();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}