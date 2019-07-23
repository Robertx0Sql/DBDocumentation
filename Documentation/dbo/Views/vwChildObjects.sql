
CREATE VIEW [dbo].[vwChildObjects]
AS
SELECT d.[ServerName]
	,d.[DatabaseName]
	,d.SchemaName
	,d.ObjectName
	,d.[TypeDescriptionUser]
	,d.[DocumentationDescription]
	,d.QualifiedFullName AS [QualifiedTableName]
	,d.TypeGroup
	,d.TypeCode
	,d.DocumentationLoadDate
	,d.fields
	,ISNULL(d.[Definition], cd.ReferencedTableSchemaName + '.' + cd.ReferencedTableName + '.' + cd.referenced_column) AS [Definition]
	,ParentSchemaName
	,ParentObjectName
	,cd.referenced_column
	,cd.ReferencedTableName
	,cd.ReferencedTableSchemaName
FROM dbo.vwObjectDoc d
LEFT JOIN vwColumnDoc cd
	ON cd.FK_NAME = d.ObjectName
		AND d.ServerName = cd.ServerName
		AND d.DatabaseName = cd.DatabaseName
		AND d.ParentSchemaName = cd.TableSchemaName
		AND d.ParentObjectName = cd.TableName
		AND d.TypeCode = 'F'
WHERE d.typecode NOT IN (
		'PK'
		,'U'
		)

UNION ALL

SELECT d.[ServerName]
	,d.[DatabaseName]
	,SchemaName = d.TableSchemaName
	,ObjectName = FK_NAME
	,d.[TypeDescriptionUser]
	,NULL AS [DocumentationDescription]
	,NULL AS [QualifiedTableName]
	,d.TypeGroup
	,d.TypeCode
	,d.DocumentationLoadDate
	,d.name AS fields
	,d.ReferencedTableSchemaName + '.' +  d.ReferencedTableName + '.' + d.referenced_column AS [Definition]
	,ParentSchemaName = [TableSchemaName]
	,ParentObjectName = [TableName]
	,d.referenced_column
	,d.ReferencedTableName
	,d.ReferencedTableSchemaName
FROM dbo.vwAutoMapFK d
WHERE [matchid] = 1