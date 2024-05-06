# Database Script Automation

This repository contains SQL scripts for automating the generation of primary key and foreign key constraints in a SQL Server database.

## Primary Key Script

The primary key script iterates through the specified schema and tables with a given prefix to generate SQL statements for adding primary key constraints.

### Usage

1. Set the `@SchemaName` and `@Prefix` variables to specify the schema and table prefix, respectively.
2. Execute the script to generate primary key constraint statements.

## Foreign Key Script

The foreign key script iterates through the specified schema and tables with a given prefix to generate SQL statements for adding foreign key constraints.

### Usage

1. Set the `@SchemaName` and `@Prefix` variables to specify the schema and table prefix, respectively.
2. Execute the script to generate foreign key constraint statements.

## Instructions

1. Clone or download this repository.
2. Open the SQL script in your preferred SQL Server management tool.
3. Modify the variables `@SchemaName` and `@Prefix` as needed.
4. Execute the script to generate primary key and foreign key constraint statements.
5. Review the generated SQL script and apply it to your database.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
