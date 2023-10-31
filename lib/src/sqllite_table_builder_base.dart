/// Sql String generator interface.
abstract interface class SqlString {
  /// Generate valid SQL string without context.
  String sqlString();
}

/// Sql Data Type. Blob is currently not supported.
enum SqlType implements SqlString {
  integer,
  real,
  text;

  @override
  String sqlString() => switch (this) {
        integer => "INTEGER",
        real => "REAL",
        text => "TEXT",
      };
}

/// Supported SQL Foreign Key Constrains.
enum SqlForeignKeyConstrain implements SqlString {
  restrict,
  noAction,
  cascade,
  setNull;

  @override
  String sqlString() => switch (this) {
        restrict => "RESTRICT",
        noAction => "NO ACTION",
        cascade => "CASCADE",
        setNull => "SET NULL",
      };

  /// Useful to be explicit about constrain.
  static SqlForeignKeyConstrain defaultValue() => restrict;
}

/// SQL Foreign Key linkage
class SqlForeignKey {
  SqlColumn column;
  SqlTable referencedTable;
  String referencedColumn;
  SqlForeignKeyConstrain? onUpdate;
  SqlForeignKeyConstrain? onDelete;

  SqlForeignKey({
    required this.column,
    required this.referencedTable,
    required this.referencedColumn,
    SqlForeignKeyConstrain? onUpdate,
    SqlForeignKeyConstrain? onDelete,
  }) {
    column = column;
    referencedTable = referencedTable;
    referencedColumn = referencedColumn;
    onUpdate = onUpdate;
    onDelete = onDelete;
  }

  String sqlString() {
    StringBuffer stringBuffer = StringBuffer(
        'FOREIGN KEY (${column.name}) REFERENCES ${referencedTable.name} ($referencedColumn)');

    if (onDelete != null) {
      stringBuffer.write('\n\tON DELETE ${onDelete!.sqlString()}');
    }
    if (onUpdate != null) {
      if (onDelete != null) {
        stringBuffer.write(' ');
      } else {
        stringBuffer.write('\n\t');
      }
      stringBuffer.write('ON UPDATE ${onUpdate!.sqlString()}');
    }
    return stringBuffer.toString();
  }
}

/// SQL data column.
class SqlColumn {
  SqlType type;
  String name;
  bool nullable;
  SqlForeignKey? foreignKey;

  SqlColumn(
      {required this.type,
      required this.name,
      this.nullable = true,
      this.foreignKey});

  String sqlString() {
    String nullableString =
        (!nullable && foreignKey == null) ? ' NOT NULL' : '';

    return '$name ${type.sqlString()}$nullableString';
  }
}

/// SQL Table.
class SqlTable {
  String name;
  List<SqlColumn> columns = [];

  SqlTable(this.name);

  void addColumn(String name, SqlType type) {
    columns.add(SqlColumn(type: type, name: name));
  }

  void nullable(bool isNullable) {
    if (columns.isNotEmpty) {
      columns.last.nullable = isNullable;
    }
  }

  void foreignKey(SqlTable referencedTable, String referencedColumn) {
    if (columns.isNotEmpty) {
      var lastColumn = columns.last;

      lastColumn.foreignKey = SqlForeignKey(
          column: lastColumn,
          referencedTable: referencedTable,
          referencedColumn: referencedColumn);
    }
  }

  void onUpdate(SqlForeignKeyConstrain constrain) {
    if (columns.isNotEmpty) {
      columns.last.foreignKey?.onUpdate = constrain;
    }
  }

  void onDelete(SqlForeignKeyConstrain constrain) {
    if (columns.isNotEmpty) {
      columns.last.foreignKey?.onDelete = constrain;
    }
  }

  String buildSqlCreateQuery() {
    StringBuffer stringBuffer =
        StringBuffer('CREATE TABLE $name (\n\t_id INTEGER PRIMARY KEY');

    for (var i = 0; i < columns.length; i++) {
      var column = columns[i];
      bool isLast = (i == columns.length);

      if (!isLast) {
        stringBuffer.write(',');
      }

      stringBuffer.write('\n\t${column.sqlString()}');

      if (column.foreignKey != null) {
        if (!isLast) {
          stringBuffer.write(',');
        }

        stringBuffer.write('\n\t${column.foreignKey!.sqlString()}');
      }
    }

    stringBuffer.write("\n);");

    return stringBuffer.toString();
  }
}
