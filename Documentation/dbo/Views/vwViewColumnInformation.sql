
CREATE VIEW [dbo].[vwViewColumnInformation]
AS
SELECT vc.[ServerName]
	,vc.[DatabaseName]
	,vc.[VIEW_SCHEMA]
	,vc.[VIEW_NAME]
	,vc.[TABLE_SCHEMA]
	,vc.[TABLE_NAME]
	,vc.[COLUMN_NAME]
	,vc.[ORDINAL_POSITION]
	,vc.[is_ambiguous]
	,vc.[Expression]
	,vc.[StagingId]
	,vc.[StagingDateTime]
	,cd.DocumentationDescription
	,od.TypeCode
	,od.TypeDescriptionSQL
	,od.TypeDescriptionUser
FROM [Staging].[ViewColumn] vc
LEFT JOIN [dbo].[vwColumnDoc] cd
	ON cd.SERVERNAME = vc.SERVERNAME
		AND cd.DatabaseName = vc.DatabaseName
		AND cd.[TableSchemaName] = vc.[TABLE_SCHEMA]
		AND cd.[TableName] = vc.[TABLE_NAME]
		AND cd.name = vc.[COLUMN_NAME]
LEFT JOIN [dbo].[vwObjectDoc] od
	ON od.SERVERNAME = vc.SERVERNAME
		AND od.DatabaseName = vc.DatabaseName
		AND od.[SchemaName] = vc.[TABLE_SCHEMA]
		AND od.[ObjectName] = vc.[TABLE_NAME]
		

		--AND cd.TypeCode = 'U'