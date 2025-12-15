import 'package:drift/drift.dart';

class SettingsEntries extends Table {
  @override
  String get tableName => 'settings_entries';

  TextColumn get key => text()();
  TextColumn get value => text()();
  TextColumn get type => text()(); // 'string', 'int', 'bool', 'double'
  
  @override
  Set<Column> get primaryKey => {key};
}
