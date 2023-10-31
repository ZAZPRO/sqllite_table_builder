import 'package:sqllite_table_builder/sqllite_table_builder.dart';

void main() {
  var userProfileUuidColumnName = "uuid";
  var userProfileTable = SqlTable("user_profile");
  userProfileTable
    ..addColumn(userProfileUuidColumnName, SqlType.text)
    ..nullable(false);

  var userProfileQuery = userProfileTable.buildSqlCreateQuery();
  print(userProfileQuery);

  var someDataTable = SqlTable("some_data");
  someDataTable
    ..addColumn("data", SqlType.integer)
    ..nullable(false)
    ..addColumn("more_data", SqlType.real)
    ..addColumn(userProfileUuidColumnName, SqlType.text)
    ..foreignKey(userProfileTable, userProfileUuidColumnName)
    ..onDelete(SqlForeignKeyConstrain.setNull);

  var someDataQuery = someDataTable.buildSqlCreateQuery();
  print(someDataQuery);
}
