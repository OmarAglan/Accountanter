import 'package:drift/drift.dart';

class Documents extends Table {
  @override
  String get tableName => 'documents';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get filePath => text()();
  TextColumn get fileType => text()(); // PDF, Image, etc.
  IntColumn get sizeBytes => integer().nullable()();
  
  // Optional: link to other entities
  TextColumn get relatedEntityType => text().nullable()(); // 'Invoice', 'Expense', 'Client'
  IntColumn get relatedEntityId => integer().nullable()();
  
  DateTimeColumn get uploadDate => dateTime().withDefault(currentDateAndTime)();
}
