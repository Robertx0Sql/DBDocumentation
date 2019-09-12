CREATE VIEW [dbo].[vwSQLDocObjectReference]
AS
WITH cte
AS (
	SELECT [ServerName]
		,[DatabaseName]
		,[referencing_schema_name]
		,[referencing_entity_name]
		,[referencing_TypeCode]
		,referencing_TypeDescriptionSQL
		,COALESCE([referenced_server_name], [ServerName]) AS [referenced_server_name]
		,COALESCE([referenced_database_name], [DatabaseName]) AS [referenced_database_name]
		,[referenced_schema_name]
		,[referenced_entity_name]
		,StagingDateTime AS DocumentationLoadDate
		,'I' AS DependencyTypeCode
	FROM [Staging].[SQLDocObjectReference]
	
	UNION ALL
	
	SELECT COALESCE([referenced_server_name], r.[ServerName])
		,COALESCE([referenced_database_name], r.[DatabaseName])
		,[referenced_schema_name]
		,[referenced_entity_name]
		,od.TypeCode
		,od.TypeDescriptionSQL
		,R.[ServerName]
		,R.[DatabaseName]
		,[referencing_schema_name]
		,[referencing_entity_name]
		,R.StagingDateTime AS DocumentationLoadDate
		,'O' AS DependencyTypeCode
	FROM [Staging].[SQLDocObjectReference] R
	LEFT JOIN [dbo].[vwObjectDoc] OD
		ON R.SERVERNAME = od.SERVERNAME
			AND r.DatabaseName = od.DatabaseName
			AND od.ObjectName = [referenced_entity_name]
			AND od.SchemaName = referenced_schema_name
	WHERE referencing_schema_name IS NOT NULL
	)
SELECT [ServerName]
	,[DatabaseName]
	,[referencing_schema_name]
	,[referencing_entity_name]
	,[referencing_TypeCode] AS TypeCode
	,ISNULL(t.TypeDescriptionUser, cte.[referencing_TypeDescriptionSQL]) AS [TypeDescriptionUser]
	,[referenced_server_name]
	,[referenced_database_name]
	,[referenced_schema_name]
	,[referenced_entity_name]
	,t.TypeGroup
	,T.TypeGroupOrder
	,T.TypeOrder
	,DocumentationLoadDate
	,DependencyTypeCode AS DependencyTypeCode
	,t.UserModeFlag
FROM cte
LEFT JOIN dbo.vwObjectType T
	ON t.TypeCode = cte.[referencing_TypeCode]
WHERE cte.[referencing_TypeDescriptionSQL] IS NOT NULL
