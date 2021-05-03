CREATE VIEW [report].[vwDatabaseObjectReference]
AS
WITH cte
AS (
	SELECT [ServerName]
		,[DatabaseName]
		,r.referencingschemaname as [referencing_schema_name]
		,[referencingentityname] as [referencing_entity_name]
		,[referencingTypeCode] as [referencing_TypeCode]
		,COALESCE(isnull([referencedservername],''), [ServerName]) AS [referenced_server_name]
		,COALESCE(isnull([referenceddatabasename], ''), [DatabaseName]) AS [referenced_database_name]
		,[referencedschemaname] as [referenced_schema_name]
		,[referencedentityname]  as [referenced_entity_name]
		,r.referencedTypeCode AS [referenced_entity_TypeCode]
		,r.DocumentationDateTime as DocumentationLoadDate
		,'I' AS DependencyTypeCode
	FROM [report].[DatabaseObjectReference] r
	
	UNION ALL
	
	SELECT COALESCE(ISNULL([referencedservername],''), r.[ServerName])
		,COALESCE(ISNULL([referenceddatabasename], ''), r.[DatabaseName])
		,[referencedschemaname]
		,[referencedentityname]
		,od.TypeCode
		,R.[ServerName]
		,R.[DatabaseName]
		,[referencingschemaname]
		,[referencingentityname]
		,odr.TypeCode AS [referenced_entity_TypeCode]
		,r.DocumentationDateTime as DocumentationLoadDate
		,'O' AS DependencyTypeCode
	FROM [report].[DatabaseObjectReference] r
	LEFT JOIN [report].[DatabaseObjectDocumentation] OD
		ON R.SERVERNAME = od.SERVERNAME
			AND r.DatabaseName = od.DatabaseName
			AND od.ObjectName = r.[referencedentityname]
			AND od.SchemaName = r.referencedschemaname
	LEFT JOIN [report].[DatabaseObjectDocumentation] odr
		ON odr.DatabaseName = r.DatabaseName
			AND odr.ServerName = r.ServerName
			AND odr.ObjectName = r.referencingentityname
			AND odr.SchemaName = r.referencingschemaname
	WHERE r.referencingschemaname IS NOT NULL
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

