CREATE VIEW [dbo].[vwSQLDocObjectReference]
AS
WITH cte
AS (
	SELECT [ServerName]
		,[DatabaseName]
		,[referencing_schema_name]
		,[referencing_entity_name]
		,[referencing_TypeCode]
		--,referencing_TypeDescriptionSQL
		,COALESCE([referenced_server_name], [ServerName]) AS [referenced_server_name]
		,COALESCE([referenced_database_name], [DatabaseName]) AS [referenced_database_name]
		,[referenced_schema_name]
		,[referenced_entity_name]
		,r.referenced_TypeCode AS [referenced_entity_TypeCode]
		,StagingDateTime AS DocumentationLoadDate
		,'I' AS DependencyTypeCode
	FROM [Staging].[SQLDocObjectReference] r
	
	UNION ALL
	
	SELECT COALESCE([referenced_server_name], r.[ServerName])
		,COALESCE([referenced_database_name], r.[DatabaseName])
		,[referenced_schema_name]
		,[referenced_entity_name]
		,od.TypeCode
		--,od.TypeDescriptionSQL
		,R.[ServerName]
		,R.[DatabaseName]
		,[referencing_schema_name]
		,[referencing_entity_name]
		,odr.TypeCode AS [referenced_entity_TypeCode]
		,R.StagingDateTime AS DocumentationLoadDate
		,'O' AS DependencyTypeCode
	FROM [Staging].[SQLDocObjectReference] R
	LEFT JOIN [REPORT].[DatabaseObjectDocumentation] OD
		ON R.SERVERNAME = od.SERVERNAME
			AND r.DatabaseName = od.DatabaseName
			AND od.ObjectName = [referenced_entity_name]
			AND od.SchemaName = referenced_schema_name
	LEFT JOIN [REPORT].[DatabaseObjectDocumentation] odr
		ON odr.DatabaseName = r.DatabaseName
			AND odr.ServerName = r.ServerName
			AND odr.ObjectName = r.referencing_entity_name
			AND odr.SchemaName = r.referencing_schema_name
	WHERE r.referencing_schema_name IS NOT NULL
	)
SELECT [ServerName]
	,[DatabaseName]
	,[referencing_schema_name]
	,[referencing_entity_name]
	,[referencing_TypeCode] AS TypeCode
	,t.TypeDescriptionUser AS [TypeDescriptionUser]
	,[referenced_server_name]
	,[referenced_database_name]
	,[referenced_schema_name]
	,[referenced_entity_name]
	,[referenced_entity_TypeCode]
	,t.TypeGroup
	,T.TypeGroupOrder
	,T.TypeOrder
	,DocumentationLoadDate
	,DependencyTypeCode AS DependencyTypeCode
	,t.UserModeFlag
FROM cte
LEFT JOIN dbo.vwObjectType T
	ON t.TypeCode = cte.[referencing_TypeCode]

