/// Sql String generator interface.
abstract interface class SqlString {
  /// Generate valid SQL string without context.
  String sqlString();
}

/// Exception when SQL Table has no columns in it.
class EmptyColumnsException implements Exception {
  @override
  String toString() =>
      'EmptyColumnsException: There are no SQL Columns to SQL Table added!';
}

/// Exception when SQL Column has no constrain in it.
class ForeignKeyConstrainMissingException implements Exception {
  @override
  String toString() =>
      'ForeignKeyConstrainMissingException: There is no Foreign Key Constrain to SQL Table added!';
}

/// Exception when no SQL Table query was build for any reason.
class TableNotBuildException implements Exception {
  final String message;

  const TableNotBuildException(this.message);

  @override
  String toString() => 'TableNotBuildException: $message';
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
    if (!referencedTable.created) {
      throw TableNotBuildException(
          "Please build $referencedTable SQL query first!");
    }

    StringBuffer stringBuffer = StringBuffer(
        'FOREIGN KEY (${column.name}) REFERENCES ${referencedTable.name} ($referencedColumn)');

    if (onDelete != null) {
      stringBuffer.write('\n\tON DELETE ${onDelete!.sqlString()}');
    }

    // Whitespaces are for nice formatting only.
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
  bool unique;
  SqlForeignKey? foreignKey;

  SqlColumn(
      {required this.name,
      required this.type,
      this.nullable = true,
      this.unique = false,
      this.foreignKey});

  String sqlString() {
    String nullableString =
        (!nullable && foreignKey == null) ? ' NOT NULL' : '';
    String uniqueString = (!unique && foreignKey == null) ? ' UNIQUE' : '';

    return '$name ${type.sqlString()}$nullableString$uniqueString';
  }
}

/// SQL Table.
class SqlTable {
  String name;
  SqlColumn primaryKey;
  List<SqlColumn> columns = [];
  bool _created = false;

  SqlTable({required this.name, required this.primaryKey});

  bool get created => _created;

  String buildSqlCreateQuery() {
    StringBuffer stringBuffer = StringBuffer(
        'CREATE TABLE $name (\n\t${primaryKey.name} ${primaryKey.type.sqlString()} PRIMARY KEY');

    // Whitespaces are for nice formatting only.
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

    // Mark table as created, to be sure that we do not create non valid constrain.
    _created = true;

    return stringBuffer.toString();
  }
}

/// SQL Table.
class SqlTableBuilder {
  late SqlTable table;

  SqlTableBuilder(String name, {SqlColumn? primaryKey}) {
    table = SqlTable(
        name: name,
        primaryKey:
            primaryKey ?? SqlColumn(name: "_id", type: SqlType.integer));
  }

  /// Add existing column to the table.
  void addColumn(SqlColumn column) {
    table.columns.add(column);
  }

  /// Create and add a column to the table.
  void createColumn(String name, SqlType type) {
    table.columns.add(SqlColumn(type: type, name: name));
  }

  /// Mark column as nullable.
  void nullable(bool isNullable) {
    if (table.columns.isEmpty) {
      throw EmptyColumnsException();
    }

    table.columns.last.nullable = isNullable;
  }

  /// Mark column as unique.
  void unique(bool isUnique) {
    if (table.columns.isEmpty) {
      throw EmptyColumnsException();
    }

    table.columns.last.unique = isUnique;
  }

  /// Add foreign key constrain.
  void foreignKey(
      SqlTableBuilder referencedTableBuilder, String referencedColumn) {
    if (table.columns.isEmpty) {
      throw EmptyColumnsException();
    }

    var lastColumn = table.columns.last;

    lastColumn.foreignKey = SqlForeignKey(
        column: lastColumn,
        referencedTable: referencedTableBuilder.table,
        referencedColumn: referencedColumn);
  }

  /// Set foreign key constrain "on update" strategy.
  void onUpdate(SqlForeignKeyConstrain constrain) {
    if (table.columns.isEmpty) {
      throw EmptyColumnsException();
    }

    if (table.columns.last.foreignKey == null) {
      throw ForeignKeyConstrainMissingException();
    }

    table.columns.last.foreignKey!.onUpdate = constrain;
  }

  /// Set foreign key constrain "on delete" strategy.
  void onDelete(SqlForeignKeyConstrain constrain) {
    if (table.columns.isEmpty) {
      throw EmptyColumnsException();
    }

    if (table.columns.last.foreignKey == null) {
      throw ForeignKeyConstrainMissingException();
    }

    table.columns.last.foreignKey!.onDelete = constrain;
  }

  String buildSqlCreateQuery() => table.buildSqlCreateQuery();
}
