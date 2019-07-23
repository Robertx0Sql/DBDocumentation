
CREATE VIEW [dbo].[vwColumnDoc]
AS
WITH cte
AS (
	SELECT cd.ServerName
		,cd.DatabaseName
		,cd.objectType
		,cd.object_id
		,cd.TableSchemaName
		,cd.TableName
		,cd.name
		,cd.DocumentationDescription
		,cd.column_id
		,cd.datatype
		,cd.max_length
		,cd.precision
		,cd.scale
		,cd.collation_name
		,cd.is_nullable
		,cd.is_identity
		,cd.ident_col_seed_value
		,cd.ident_col_increment_value
		,cd.is_computed
		,cd.Column_Default
		,cd.PK
		,cd.FK_NAME
		,cd.ReferencedTableObject_id
		,cd.ReferencedTableSchemaName
		,cd.ReferencedTableName
		,cd.referenced_column
		,cd.StagingId
		,cd.StagingDateTime
		,cd.objectTypeDescription
		,IIF(column_id IS NOT NULL, CASE 
				WHEN [objectType] IN (
						'U'
						,'V'
						)
					THEN 'Column'
				ELSE 'Parameter'
				END, T.[TypedescriptionUser]) AS [TypeDescriptionUser]
		,t.TypeDescriptionSQL
		,t.TypeGroup
		,T.TypeGroupOrder
		,t.TypeOrder
		,t.TypeCount
	FROM Staging.[ColumnDoc] cd
	LEFT JOIN dbo.vwObjectType t ON t.TypeCode = rtrim(cd.[objectType])
	)
SELECT [ServerName]
	,[DatabaseName]
	,rtrim([objectType]) AS TypeCode
	,[TypeDescriptionUser]
	,[TableSchemaName]
	,[TableName]
	,[name]
	,[DocumentationDescription]
	,[column_id]
	,[datatype]
	,[max_length]
	,[precision]
	,[scale]
	,[collation_name]
	,[is_nullable]
	,[is_identity]
	,[ident_col_seed_value]
	,[ident_col_increment_value]
	,[is_computed]
	,[Column_Default]
	,[PK]
	,CAST(iif(PK = 1, SUM(CAST(PK AS INT)) OVER (
				PARTITION BY cd.[TypeDescriptionUser]
				,cd.[ServerName]
				,cd.[DatabaseName]
				,cd.[TableSchemaName]
				,cd.[TableName]
				), NULL) AS VARCHAR(25)) AS [PKFieldCount]
	,[FK_NAME]
	,[ReferencedTableObject_id]
	,[ReferencedTableSchemaName]
	,[ReferencedTableName]
	,[referenced_column]
	,QUOTENAME([TableSchemaName]) + '.' + QUOTENAME([TableName]) AS QualifiedTableName
	,cd.TypeDescriptionSQL
	,cd.TypeGroup
	,cd.TypeGroupOrder
	,cd.TypeOrder
	,cd.TypeCount
	,StagingDateTime AS DocumentationLoadDate
	,StagingId
FROM cte cd
