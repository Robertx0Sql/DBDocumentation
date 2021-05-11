
CREATE PROCEDURE [report].[upGetSQLSearch] (
	@Search VARCHAR(255)
	,@server VARCHAR(255) = NULL
	,@database VARCHAR(255) = NULL
	)
AS

WITH cte
AS (
	SELECT CAST('column ' AS VARCHAR(50)) AS [Type]
		,CAST([ColumnName] AS VARCHAR(255)) AS [Name]
		,CAST([DocumentationDescription] AS VARCHAR(4000)) AS [Description]
		,CAST(SERVERNAME AS VARCHAR(255)) AS ServerName
		,CAST(DatabaseName AS VARCHAR(255)) AS DatabaseName
		,CAST([TableSchemaName] AS VARCHAR(255)) AS ReferencedSchemaName
		,CAST([TableName] AS VARCHAR(255)) AS ReferencedObjectName
		,CAST(t.TypeCode AS VARCHAR(255)) as ReferencedTypeCode
		,CAST(ot.TypeDescriptionUser AS VARCHAR(255)) AS TypeDescriptionUser
	FROM [report].[DatabaseObjectColumn] t
	LEFT JOIN dbo.vwObjectType ot
		ON ot.TypeCode = t.TypeCode
	WHERE (
			@server = SERVERNAME
			OR @server IS NULL
			)
		AND @database = DatabaseName
		AND (
			[ColumnName] LIKE '%' + @Search + '%'
			OR [DocumentationDescription] LIKE '%' + @Search + '%'
			)
		AND ot.TypeDescriptionUser != 'Stored Procedure'
	
	UNION ALL
	
	SELECT CAST(t.TypeDescriptionUser AS VARCHAR(50)) AS [Type]
		,CAST(t.ObjectName AS VARCHAR(255)) AS [Name]
		,CAST(t.[DocumentationDescription] AS VARCHAR(4000)) AS [Description]
		,CAST(t.SERVERNAME AS VARCHAR(255)) AS ServerName
		,CAST(t.DatabaseName AS VARCHAR(255)) AS DatabaseName
		,CAST(t.parentSchemaName AS VARCHAR(255)) AS ReferencedSchemaName
		,CAST(t.parentObjectName AS VARCHAR(255)) AS ReferencedObjectName
		,CAST(t.ParentTypeCode AS VARCHAR(255)) as ReferencedTypeCode
		,CAST(p.TypeDescriptionUser AS VARCHAR(255)) AS TypeDescriptionUser
	FROM [report].[DatabaseObjectDocumentation] t
	LEFT JOIN [report].[DatabaseObjectDocumentation] p
		ON t.ParentObjectName = p.ObjectName
			AND t.ParentSchemaName = p.SchemaName
	WHERE (
			@server = t.SERVERNAME
			OR @server IS NULL
			)
		AND @database = t.DatabaseName
		AND (
			t.[ObjectName] LIKE '%' + @Search + '%'
			OR t.[DocumentationDescription] LIKE '%' + @Search + '%'
			)
	)
SELECT DISTINCT 
	 [Type]
	,[Name]					
	,[Description]			
	,ServerName				
	,DatabaseName			
	,ReferencedSchemaName				
	,ReferencedObjectName 
	,ReferencedTypeCode
	,TypeDescriptionUser	
FROM cte
ORDER BY TypeDescriptionUser
	,ReferencedSchemaName
	,ReferencedObjectName
	,[Type];