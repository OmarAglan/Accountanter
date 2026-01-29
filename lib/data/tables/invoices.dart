import 'package:drift/drift.dart';
import 'clients.dart';

// The @Table annotation has been removed
class Invoices extends Table {
  @override
  String get tableName => 'invoices';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text().unique()();
  IntColumn get clientId => integer().references(Clients, #id)();
  
  DateTimeColumn get issueDate => dateTime()();
  DateTimeColumn get dueDate => dateTime()();
  
  RealColumn get totalAmount => real()();
  RealColumn get taxAmount => real()();
  RealColumn get subtotal => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  
  // Status can be 'Draft', 'Pending', 'Paid', 'Overdue'
  TextColumn get status => text()(); 
  
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}