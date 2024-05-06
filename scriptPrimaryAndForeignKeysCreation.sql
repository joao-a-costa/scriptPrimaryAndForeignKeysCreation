DECLARE @SchemaName NVARCHAR(100) = 'dbo';
DECLARE @Prefix NVARCHAR(100) = 'UX_SD_';

DECLARE @PrimaryKeyScript NVARCHAR(MAX) = '';

-- Cursor to iterate through primary keys
DECLARE @PKName NVARCHAR(100);
DECLARE @PKTableName NVARCHAR(100);
DECLARE @PKColumns NVARCHAR(MAX);

DECLARE PK_Cursor CURSOR FOR
SELECT pk.name AS PKName,
       t.name AS TableName,
       STUFF((SELECT ', ' + c.name
              FROM sys.index_columns AS ic
              INNER JOIN sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
              WHERE ic.object_id = pk.parent_object_id AND ic.index_id = pk.unique_index_id
              FOR XML PATH('')), 1, 2, '') AS Columns
FROM sys.key_constraints AS pk
INNER JOIN sys.tables AS t ON pk.parent_object_id = t.object_id
INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id
WHERE s.name = @SchemaName AND t.name LIKE @Prefix + '%'
      AND pk.type = 'PK';

OPEN PK_Cursor;

FETCH NEXT FROM PK_Cursor INTO @PKName, @PKTableName, @PKColumns;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @PrimaryKeyScript += 'IF EXISTS (SELECT * FROM sys.tables WHERE name = ''' + @PKTableName + ''')' + CHAR(13);
    SET @PrimaryKeyScript += 'BEGIN' + CHAR(13);
    SET @PrimaryKeyScript += 'IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = ''' + @PKName + ''')' + CHAR(13);
    SET @PrimaryKeyScript += 'BEGIN' + CHAR(13);
    SET @PrimaryKeyScript += 'ALTER TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@PKTableName) + CHAR(13);
    SET @PrimaryKeyScript += 'ADD CONSTRAINT ' + QUOTENAME(@PKName) + ' PRIMARY KEY CLUSTERED (' + @PKColumns + ');' + CHAR(13);
    SET @PrimaryKeyScript += 'END;' + CHAR(13) + 'END;' + CHAR(13);-- + 'GO' + CHAR(13);

    FETCH NEXT FROM PK_Cursor INTO @PKName, @PKTableName, @PKColumns;
END

CLOSE PK_Cursor;
DEALLOCATE PK_Cursor;

-- Print the generated primary key script
PRINT @PrimaryKeyScript;

DECLARE @SchemaName NVARCHAR(100) = 'dbo';
DECLARE @Prefix NVARCHAR(100) = 'UX_SD_';

DECLARE @ForeignKeyScript NVARCHAR(MAX) = '';

-- Cursor to iterate through foreign keys
DECLARE @FKName NVARCHAR(100);
DECLARE @FKTableName NVARCHAR(100);
DECLARE @FKColumns NVARCHAR(MAX);
DECLARE @ReferencedTable NVARCHAR(100);

DECLARE FK_Cursor CURSOR FOR
SELECT fk.name AS FKName,
       t.name AS TableName,
       STUFF((SELECT ', ' + c.name
              FROM sys.columns AS c
              INNER JOIN sys.foreign_key_columns AS fkc ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
              WHERE fkc.constraint_object_id = fk.object_id
              FOR XML PATH('')), 1, 2, '') AS Columns,
       OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS t ON fk.parent_object_id = t.object_id
INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id
WHERE s.name = @SchemaName AND t.name LIKE @Prefix + '%';

OPEN FK_Cursor;

FETCH NEXT FROM FK_Cursor INTO @FKName, @FKTableName, @FKColumns, @ReferencedTable;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @ForeignKeyScript += 'IF EXISTS (SELECT * FROM sys.tables WHERE name = ''' + @FKTableName + ''')' + CHAR(13);
    SET @ForeignKeyScript += 'BEGIN' + CHAR(13);
    SET @ForeignKeyScript += 'IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = ''' + @FKName + ''')' + CHAR(13);
    SET @ForeignKeyScript += 'BEGIN' + CHAR(13);
    SET @ForeignKeyScript += 'ALTER TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@FKTableName) + CHAR(13);
    SET @ForeignKeyScript += 'ADD CONSTRAINT ' + QUOTENAME(@FKName) + ' FOREIGN KEY (' + @FKColumns + ') REFERENCES ' + QUOTENAME(@ReferencedTable) + ';' + CHAR(13);
    SET @ForeignKeyScript += 'END;' + CHAR(13) + 'END;' + CHAR(13);-- + 'GO' + CHAR(13);

    FETCH NEXT FROM FK_Cursor INTO @FKName, @FKTableName, @FKColumns, @ReferencedTable;
END

CLOSE FK_Cursor;
DEALLOCATE FK_Cursor;

-- Print the generated foreign key script
PRINT @ForeignKeyScript;
