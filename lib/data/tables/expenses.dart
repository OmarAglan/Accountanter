import 'package:drift/drift.dart';

// Defines the 'expenses' table
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get category => text()();
  TextColumn get vendor => text().nullable()();
  TextColumn get paymentMethod => text()();
  
  // Status can be 'pending', 'approved', or 'rejected'
  TextColumn get status => text()(); 
  
  TextColumn get receiptUrl => text().nullable()();
  TextColumn get project => text().nullable()();
  TextColumn get tags => text().nullable()(); // Storing tags as a comma-separated string
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}