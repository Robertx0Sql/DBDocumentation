


CREATE view [dbo].[vwAutoMapFK] 
	AS 
SELECT fk.ServerName
	,fk.DatabaseName 
	, fk.column_id 
	,fk.TableSchemaName
	,fk.TableName
	,fk.name

	,pk.tableSchemaName AS ReferencedTableSchemaName
	,pk.TableName AS ReferencedTableName
	,pk.name AS referenced_column
	,CONCAT ('** AUTO MAP ** '  ,'FK_',fk.TableName 	,'_',pk.TableName, '_',fk.name ) AS FK_NAME
	
,matchid = row_number () over (partition by fk.ServerName
	,fk.DatabaseName 
	, fk.column_id 
	,fk.TableSchemaName
	,fk.TableName
	,fk.name
order by 	pk.tableSchemaName asc
	,pk.TableName 	desc ,pk.name desc
,pk.StagingID asc
)
, fk.DocumentationLoadDate
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
	) FK ON Fk.name = pk.name
	AND fk.ServerName = pk.ServerName
	AND fk.DatabaseName = pk.DatabaseName
	AND fk.TypeCode = pk.TypeCode
left join dbo.vwObjectType t on t.TypeCode = 'F'

WHERE pk.TypeCode = 'u'
 

	AND ((fk.TableSchemaName not in ('staging', 'tools')
and pk.tableSchemaName not in ('staging', 'tools')
and fk.DatabaseName in ('EDW','ODS')
) or fk.DatabaseName not in ('EDW','ODS'))
	--and fk.datatype=pk.datatype