
CREATE VIEW [dbo].[vwColumnDoc]
AS
SELECT CASE 
		WHEN [objectType] IN ('U', 'V')
			AND column_id IS NOT NULL
			THEN 'Column'
		WHEN [objectType] = 'U'
			AND column_id IS NULL
			THEN 'Table'
		WHEN [objectType] = 'V'
			AND column_id IS NULL
			THEN 'View'
		ELSE [objectType]
		END AS object_type
	, [ServerName]
	, [DatabaseName]
	, [objectType]
	, [object_id]
	, [TableSchemaName]
	, [TableName]
	, [name]
	, [DocumentationDescription]
	, [column_id]
	, [datatype]
	, [max_length]
	, [precision]
	, [scale]
	, [collation_name]
	, [is_nullable]
	, [is_identity]
	, [ident_col_seed_value]
	, [ident_col_increment_value]
	, [is_computed]
	, [Column_Default]
	, [PK]
	, [FK_NAME]
	, [ReferencedTableObject_id]
	, [ReferencedTableSchemaName]
	, [ReferencedTableName]
	, [referenced_column]
	,  QUOTENAME([TableSchemaName]) + '.' + QUOTENAME( [TableName]) AS QualifiedTableName 
FROM Staging.[ColumnDoc];
