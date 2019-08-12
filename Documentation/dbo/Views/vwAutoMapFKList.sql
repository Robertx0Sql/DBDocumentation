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
		'** AUTO MAP ** '
		,'FK_'
		,fk.TableName
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
		AND pk.TableName NOT LIKE AFKBF.ReferencedTableName
--AND coalesce(AFKBF.TableSchemaName, fk.TableSchemaName) = fk.TableSchemaName
--AND coalesce(AFKBF.TableName, fk.TableName) = fk.TableName
--AND coalesce(AFKBF.columnName, fk.name) = fk.name
--AND coalesce(AFKBF.ReferencedTableSchemaName, pk.tableSchemaName) = pk.tableSchemaName
--AND coalesce(AFKBF.ReferencedTableName, pk.TableName) = pk.TableName
WHERE pk.TypeCode = 'u'
	AND (
		(
			fk.TableSchemaName NOT IN ('staging', 'tools')
			AND pk.tableSchemaName NOT IN ('staging', 'tools')
			AND fk.DatabaseName IN ('EDW', 'ODS')
			)
		OR fk.DatabaseName NOT IN ('EDW', 'ODS')
		)
