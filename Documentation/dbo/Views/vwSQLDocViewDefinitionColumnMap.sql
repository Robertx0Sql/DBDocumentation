CREATE VIEW [dbo].[vwSQLDocViewDefinitionColumnMap]
AS
SELECT vc.[ServerName]
	,vc.[DatabaseName]
	,vc.[ViewSchema]
	,vc.[ViewName]
	,vc.[SourceTableSchema]
	,vc.[SourceTableName]
	,vc.[ColumnName]
	,vc.[ColumnId]
	,vc.[is_ambiguous]
	,vc.[Expression]
	,vc.[StagingId]
	,vc.[StagingDateTime]
	,cd.DocumentationDescription
	,od.TypeCode
	,od.TypeDescriptionSQL
	,od.TypeDescriptionUser
FROM [Staging].[SQLDocViewDefinitionColumnMap] vc
LEFT JOIN [dbo].[vwColumnDoc] cd
	ON cd.SERVERNAME = vc.SERVERNAME
		AND cd.DatabaseName = vc.DatabaseName
		AND cd.[TableSchemaName] = vc.[SourceTableSchema]
		AND cd.[TableName] = vc.[SourceTableName]
		AND cd.name = vc.[ColumnName]
LEFT JOIN [dbo].[vwObjectDoc] od
	ON od.SERVERNAME = vc.SERVERNAME
		AND od.DatabaseName = vc.DatabaseName
		AND od.[SchemaName] = vc.[SourceTableSchema]
		AND od.[ObjectName] = vc.[SourceTableName];