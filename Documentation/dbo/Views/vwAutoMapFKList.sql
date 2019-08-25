
CREATE VIEW [dbo].[vwAutoMapFKList]
AS
SELECT fk.ServerName
	,fk.DatabaseName
	,fk.column_id
	,fk.TableSchemaName
	,fk.TableName
	,fk.name
	,pk.tableSchemaName AS ReferencedTableSchemaName
	,pk.TableName AS ReferencedTableName
	,pk.name AS referenced_column
	,CONCAT (
		'AFK_'
		,fk.TableSchemaName
		,'_'
		,fk.TableName
		,'_'
		,pk.TableSchemaName
		,'_'
		,pk.TableName
		,'_'
		,fk.name
		) AS FK_NAME
	,row_number() OVER (
		PARTITION BY fk.ServerName
		,fk.DatabaseName
		,fk.column_id
		,fk.TableSchemaName
		,fk.TableName
		,fk.name ORDER BY pk.tableSchemaName ASC
			,pk.TableName DESC
			,pk.name DESC
			,pk.StagingID ASC
		) AS matchid
	,count(1) OVER (
		PARTITION BY fk.ServerName
		,fk.DatabaseName
		,fk.column_id
		,fk.TableSchemaName
		,fk.TableName
		,fk.name
		) AS FKCount
	,fk.DocumentationLoadDate
	,t.[TypeDescriptionUser]
	,t.TypeGroup
	,t.TypeCode
	,CONCAT (
		'Foreign key constraint referencing '
		,pk.TableSchemaName
		,'.'
		,pk.TableName
		,' (Auto Generated)'
		) AS description
FROM (
	SELECT *
	FROM vwColumnDoc
	WHERE pkfieldcount = 1
		AND FK_NAME IS NULL
	) pk
INNER JOIN (
	SELECT *
	FROM vwColumnDoc
	WHERE (
			pk IS NULL
			OR pk = 0
			)
		AND FK_NAME IS NULL
	) FK
	ON Fk.name = pk.name
		AND fk.ServerName = pk.ServerName
		AND fk.DatabaseName = pk.DatabaseName
		AND fk.TypeCode = pk.TypeCode
LEFT JOIN dbo.vwObjectType t
	ON t.TypeCode = 'F'
LEFT JOIN [dbo].[AutoMapFKBuildFilter] AFKBF
	ON coalesce(AFKBF.DatabaseName, fk.DatabaseName) = fk.DatabaseName
		AND (
			pk.TableSchemaName LIKE AFKBF.ReferencedTableSchemaName
			OR pk.ReferencedTableSchemaName LIKE AFKBF.ReferencedTableSchemaName
			)
		AND pk.TableName LIKE AFKBF.ReferencedTableName
WHERE pk.TypeCode = 'u'
	AND AFKBF.[AutoMapFKBuildFilterId] IS NULL
