import 'package:drift/drift.dart';
import 'categories.dart';
import 'vendors.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  
  // REPLACED: Changed from TextColumn to IntColumn with a foreign key reference
  IntColumn get categoryId => integer().references(Categories, #id)();

  // REPLACED: Renamed and changed from TextColumn to IntColumn with a foreign key reference
  IntColumn get vendorId => integer().nullable().references(Vendors, #id)();
  
  TextColumn get paymentMethod => text()();
  
  // Status can be 'pending', 'approved', or 'rejected'
  TextColumn get status => text()(); 
  
  TextColumn get receiptUrl => text().nullable()();
  TextColumn get project => text().nullable()();
  TextColumn get tags => text().nullable()(); // Storing tags as a comma-separated string
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}