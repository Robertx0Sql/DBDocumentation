



CREATE VIEW [dbo].[vwColumnDoc]
AS
SELECT  
	IIF(column_id IS NOT NULL ,
		CASE WHEN [objectType] IN ('U', 'V')
			THEN 'Column'
		ELSE 'Parameter'
		END 
		,T.[TypedescriptionUser]
		)
		AS [TypeDescriptionUser] 
	, [ServerName]
	, [DatabaseName]
	, rtrim([objectType] ) as TypeCode
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
	,t.TypeDescriptionSQL
	,t.TypeGroup
	,T.TypeGroupOrder
	,t.TypeOrder
	,t.TypeCount
	,StagingDateTime as DocumentationLoadDate 
	FROM Staging.[ColumnDoc] d
left join dbo.vwObjectType  t on t.TypeCode = rtrim(d. [objectType] ) ;
