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
	,ISNULL(d.[Definition], od.ReferencedSchemaName + '.' + od.ReferencedObjectName + '.' + od.ReferencedColumnName) AS [Definition]
	,d.ParentSchemaName
	,d.ParentObjectName
	--,d.ParentObjectType 
	,d.ParentTypeCode
	,od.ReferencedColumnName
	,od.ReferencedObjectName
	,iif(od.ReferencedObjectName IS NULL, NULL, 'U') AS ReferencedTypeCode
	,od.ReferencedSchemaName
	,od.ReferencedObjectType
	,d.UserModeFlag
FROM [REPORT].[DatabaseObjectDocumentation] d
LEFT JOIN dbo.SQLColumnReference od
	ON  d.SERVERNAME = od.ServerName
		AND d.DatabaseName = od.DatabaseName
		AND d.ParentSchemaName = od.[SchemaName]
		AND d.ParentObjectName = od.[ObjectName]
		AND od.FK_NAME = d.ObjectName
		AND d.TypeCode = 'F'
WHERE d.typecode NOT IN (
		'PK'
		,'U'
		)
