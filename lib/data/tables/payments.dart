import 'package:drift/drift.dart';
import 'invoices.dart';

class Payments extends Table {
  @override
  String get tableName => 'payments';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId => integer().references(Invoices, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get method => text()(); // Cash, Credit Card, Bank Transfer, etc.
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
