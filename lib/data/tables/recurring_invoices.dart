import 'package:drift/drift.dart';
import 'clients.dart';

class RecurringInvoices extends Table {
  @override
  String get tableName => 'recurring_invoices';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().references(Clients, #id)();
  
  // Schedule
  TextColumn get frequency => text()(); // Monthly, Weekly, Yearly
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get nextRunDate => dateTime()();
  DateTimeColumn get lastRunDate => dateTime().nullable()();
  
  // Template Data
  RealColumn get amount => real()();
  TextColumn get description => text().nullable()();
  
  TextColumn get status => text().withDefault(const Constant('Active'))(); // Active, Paused, Cancelled
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
