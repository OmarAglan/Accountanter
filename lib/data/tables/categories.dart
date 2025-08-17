import 'package:drift/drift.dart';

class Categories extends Table {
  @override
  String get tableName => 'categories';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  // 'inventory', 'expense', etc. to know where the category is used
  TextColumn get type => text()();
  
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => ['UNIQUE(name, type)'];
}