
CREATE VIEW [dbo].[vwAutoMapFKList]
AS
SELECT fk.ServerName
	,fk.DatabaseName
	,fk.[ColumnId]
	,fk.[ObjectSchemaName]
	,fk.[ObjectName]
	,fk.[ColumnName]
	,pk.[ObjectSchemaName] AS ReferencedTableSchemaName
	,pk.[ObjectName] AS ReferencedTableName
	,pk.[ColumnName] AS referenced_column
	,CONCAT (
		'AFK_'
		,fk.[ObjectSchemaName]
		,'_'
		,fk.[ObjectName]
		,'_'
		,pk.[ObjectSchemaName]
		,'_'
		,pk.[ObjectName]
		,'_'
		,fk.[ColumnName]
		) AS FK_NAME
	,row_number() OVER (
		PARTITION BY fk.ServerName
		,fk.DatabaseName
		,fk.[ColumnId]
		,fk.[ObjectSchemaName]
		,fk.[ObjectName]
		,fk.[ColumnName] 
		ORDER BY pk.[ObjectSchemaName] ASC
			,pk.[ObjectName] DESC
			,pk.[ColumnName] DESC
			,pk.StagingID ASC
		) AS matchid
	,count(1) OVER (
		PARTITION BY fk.ServerName
		,fk.DatabaseName
		,fk.[ColumnId]
		,fk.[ObjectSchemaName]
		,fk.[ObjectName]
		,fk.[ColumnName]
		) AS FKCount
	,fk.DocumentationLoadDate
	,t.[TypeDescriptionUser]
	,t.TypeGroup
	,t.TypeCode
	,CONCAT (
		'Foreign key constraint referencing '
		,pk.[ObjectSchemaName]
		,'.'
		,pk.[ObjectName]
		,' (Auto Generated)'
		) AS description
FROM (
		SELECT cd.*
			,od.ReferencedSchemaName
			,od.[ReferencedObjectName]
			,od.[ReferencedColumnName]
		FROM [Staging].vwColumnDoc cd
		LEFT JOIN [Staging].SQLColumnReference od ON cd.SERVERNAME = od.ServerName
			AND cd.DatabaseName = od.DatabaseName
			AND cd.[ObjectSchemaName] = od.[SchemaName]
			AND cd.[ObjectName] = od.[ObjectName]
			AND cd.[ColumnName] = od.ColumnName
		WHERE cd.pkfieldcount = 1
			AND od.FK_NAME IS NULL
	) pk
INNER JOIN (
		SELECT cd.*
			,od.ReferencedSchemaName
			,od.[ReferencedObjectName]
			,od.[ReferencedColumnName]
		FROM [Staging].vwColumnDoc cd
		LEFT JOIN [Staging].SQLColumnReference od ON cd.SERVERNAME = od.ServerName
			AND cd.DatabaseName = od.DatabaseName
			AND cd.[ObjectSchemaName] = od.[SchemaName]
			AND cd.[ObjectName] = od.[ObjectName]
			AND cd.[ColumnName] = od.ColumnName
		WHERE (
				cd.[is_primary_key] IS NULL
				OR cd.[is_primary_key] = 0
				)
			AND od.FK_NAME IS NULL
	) FK
	ON Fk.[ColumnName] = pk.[ColumnName]
		AND fk.ServerName = pk.ServerName
		AND fk.DatabaseName = pk.DatabaseName
		AND fk.TypeCode = pk.TypeCode
LEFT JOIN dbo.vwObjectType t
	ON t.TypeCode = 'F'
LEFT JOIN [dbo].[AutoMapFKBuildFilter] AFKBF
	ON coalesce(AFKBF.DatabaseName, fk.DatabaseName) = fk.DatabaseName
		AND (
			pk.[ObjectSchemaName] LIKE AFKBF.ReferencedTableSchemaName
			OR pk.ReferencedSchemaName LIKE AFKBF.ReferencedTableSchemaName
			)
		AND pk.[ObjectName] LIKE AFKBF.ReferencedTableName
WHERE pk.TypeCode = 'u'
	AND AFKBF.[AutoMapFKBuildFilterId] IS NULL
