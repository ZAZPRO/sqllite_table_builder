<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

Programmatically create SQL Lite tables.

Currently SQFLite is tested.
> Warning: This package is in alpha. Use it at own risk.

## Features

- Programmatically create SQL Lite tables.
- User Foreign Keys to link tables.
- Use nice programming interface to ensure better safety.

## Getting started

```bash
dart pub add sqllite_table_builder
```

## Usage

```dart
// Create a table builder with table name and default primary key.
final someDataTable = SqlTableBuilder("some_data");
// Generate SQL query to create this table.
final someDataQuery = someDataTable.buildSqlCreateQuery();
```

```dart
// Create a table builder with table name and specified primary key.
final userProfileTableBuilder = SqlTableBuilder(
    "user_data",
    primaryKey: SqlColumn(name: "uuid", type: SqlType.text),
);

// Add required columns to a table.
userProfileTableBuilder
    ..createColumn("name", SqlType.text)
    ..nullable(false)
    ..createColumn("age", SqlType.integer)

// Generate SQL query to create this table.
final userProfileQuery = userProfileTableBuilder.buildSqlCreateQuery();
```

More examples in ```/examples``` directory and ```/tests```.

## Additional information

If you would like to contribute to the plugin, check out it's [Github page](https://github.com/ZAZPRO/sqllite_table_builder).
