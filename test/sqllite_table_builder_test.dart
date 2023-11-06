import 'package:sqllite_table_builder/sqllite_table_builder.dart';
import 'package:test/test.dart';

void main() {
  group('Basic table creation', () {
    var tableName = "test_table";

    test('Empty Table', () {
      var tableBuilder = SqlTableBuilder(tableName);
      var query = tableBuilder.buildSqlCreateQuery();

      expect(query, 'CREATE TABLE $tableName (\n\t_id INTEGER PRIMARY KEY\n);');
    });

    test('Empty Table with Primary Key', () {
      final primaryKeyName = "primary";
      final primaryKeyType = SqlType.text;

      var tableBuilder = SqlTableBuilder(tableName,
          primaryKey: SqlColumn(name: primaryKeyName, type: primaryKeyType));
      var query = tableBuilder.buildSqlCreateQuery();

      expect(query,
          'CREATE TABLE $tableName (\n\t$primaryKeyName ${primaryKeyType.sqlString()} PRIMARY KEY\n);');
    });
  });
}
