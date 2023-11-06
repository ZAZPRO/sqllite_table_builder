import 'package:sqllite_table_builder/sqllite_table_builder.dart';

void main() {
  final userProfileTableName = "user_profile";
  final userProfileUuidColumnName = "uuid";

  // Create a table builder with table name and specified primary key.
  final userProfileTableBuilder = SqlTableBuilder(
    userProfileTableName,
    primaryKey: SqlColumn(name: userProfileUuidColumnName, type: SqlType.text),
  );

  // Generate SQL query to create this table.
  final userProfileQuery = userProfileTableBuilder.buildSqlCreateQuery();

  /* Will print:
    CREATE TABLE user_profile (
          uuid TEXT PRIMARY KEY
    );
  */
  print(userProfileQuery);

  // Create a table builder with table name and default primary key.
  final someDataTable = SqlTableBuilder("some_data");
  // Create columns and foreign key linked to user profile.
  someDataTable
    ..createColumn("data", SqlType.integer)
    ..nullable(false)
    ..createColumn("more_data", SqlType.real)
    ..createColumn(userProfileUuidColumnName, SqlType.text)
    ..foreignKey(userProfileTableBuilder, userProfileUuidColumnName)
    ..onDelete(SqlForeignKeyConstrain.setNull);

  // Generate SQL query to create this table.
  final someDataQuery = someDataTable.buildSqlCreateQuery();

  /* Will print:
    CREATE TABLE some_data (
        _id INTEGER PRIMARY KEY,
        data INTEGER NOT NULL,
        more_data REAL,
        uuid TEXT,
        FOREIGN KEY (uuid) REFERENCES user_profile (uuid)
        ON DELETE SET NULL
    );
  */
  print(someDataQuery);
}
