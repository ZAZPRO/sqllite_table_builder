import 'package:sqllite_table_builder/sqllite_table_builder.dart';
import 'package:test/test.dart';

void main() {
  group('Basic table creation', () {
    var tableName = "test_table";

    test('Empty Table', () {
      var table = SqlTable(tableName);
      var query = table.buildSqlCreateQuery();

      expect(query, 'CREATE TABLE $tableName (\n\t_id INTEGER PRIMARY KEY\n);');
    });
  });
}
