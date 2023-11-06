import 'package:sqllite_table_builder/sqllite_table_builder.dart';
import 'package:test/test.dart';

void main() {
  var tableName = "test_table";
  group('Empty table creation', () {
    test('Empty Table', () {
      final tableBuilder = SqlTableBuilder(tableName);
      final query = tableBuilder.buildSqlCreateQuery();

      expect(query, 'CREATE TABLE $tableName (\n\t_id INTEGER PRIMARY KEY\n);');
    });

    test('Empty Table with Primary Key', () {
      final primaryKeyName = "primary";
      final primaryKeyType = SqlType.text;

      final tableBuilder = SqlTableBuilder(tableName,
          primaryKey: SqlColumn(name: primaryKeyName, type: primaryKeyType));
      final query = tableBuilder.buildSqlCreateQuery();

      expect(query,
          'CREATE TABLE $tableName (\n\t$primaryKeyName ${primaryKeyType.sqlString()} PRIMARY KEY\n);');
    });
  });

  group('Regular Table creation', () {
    test('One Integer Column', () {
      final tableBuilder = SqlTableBuilder(tableName);
      tableBuilder.createColumn("column_1", SqlType.integer);

      final query = tableBuilder.buildSqlCreateQuery();

      expect(query,
          'CREATE TABLE $tableName (\n\t_id INTEGER PRIMARY KEY,\n\tcolumn_1 INTEGER\n);');
    });
  });

  group('Foreign key constraints', () {
    test('Foreign Key definition is in the end', () {
      final tableBuilder1 = SqlTableBuilder(tableName);
      tableBuilder1.buildSqlCreateQuery();

      final tableBuilder2 = SqlTableBuilder("${tableName}_2");
      tableBuilder2
        ..createColumn("foreign", SqlType.integer)
        ..foreignKey(tableBuilder1, "_id")
        ..createColumn("spacer", SqlType.integer);
      final query = tableBuilder2.buildSqlCreateQuery();

      expect(
          query,
          'CREATE TABLE ${tableName}_2 (\n'
          '\t_id INTEGER PRIMARY KEY,\n'
          '\tforeign INTEGER,\n'
          '\tspacer INTEGER,\n'
          '\tFOREIGN KEY (foreign) REFERENCES test_table (_id)\n'
          ');');
    });
  });
}
