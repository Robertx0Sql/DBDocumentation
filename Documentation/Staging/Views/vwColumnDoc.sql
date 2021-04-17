
CREATE VIEW [Staging].[vwColumnDoc]
AS
WITH cte
AS (
	SELECT cd.ServerName
		,cd.DatabaseName
		,cd.objectType
		
		,cd.[ObjectSchemaName]
		,cd.[ObjectName]
		,cd.[ColumnName]
		,cd.DocumentationDescription
		,cd.[ColumnId]
		,cd.datatype
		,cd.max_length
		,cd.precision
		,cd.scale
		,cd.collation_name
		,cd.is_nullable
		,cd.is_identity
		,cd.is_computed
		,cd.Column_Default
		,cd.[is_primary_key]
		,cd.StagingId
		,cd.StagingDateTime
		,IIF([ColumnId] IS NOT NULL, CASE 
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
	,[ObjectSchemaName]
	,[ObjectName]
	,[ColumnName]
	,[DocumentationDescription]
	,[ColumnId]
	,[datatype]
	,[max_length]
	,[precision]
	,[scale]
	,[collation_name]
	,[is_nullable]
	,[is_identity]
	,[is_computed]
	,[is_primary_key]
	,[Column_Default]
	,CAST(iif([is_primary_key] = 1, SUM(CAST([is_primary_key] AS INT)) OVER (
				PARTITION BY cd.[TypeDescriptionUser]
				,cd.[ServerName]
				,cd.[DatabaseName]
				,cd.[ObjectSchemaName]
				,cd.[ObjectName]
				), NULL) AS VARCHAR(25)) AS [PKFieldCount]
	,QUOTENAME([ObjectSchemaName]) + '.' + QUOTENAME([ObjectName]) AS QualifiedTableName
	,cd.TypeDescriptionSQL
	,cd.TypeGroup
	,cd.TypeGroupOrder
	,cd.TypeOrder
	,cd.TypeCount
	,StagingDateTime AS DocumentationLoadDate
	,StagingId
FROM cte cd
