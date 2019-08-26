
CREATE PROCEDURE [dbo].[upSqlDocObjectChildObjects] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255) = NULL
	,@Object VARCHAR(255) = NULL
	)
AS
SELECT [ServerName]
	,[DatabaseName]
	,SchemaName
	,ObjectName
	,[TypeDescriptionUser]
	,[DocumentationDescription]
	,TypeGroup
	,TypeCode
	,DocumentationLoadDate
	,fields
	,DEFINITION
	,referenced_column
	,ReferencedTableName
	,ReferencedTableSchemaName
	,ReferencedObjectType = 'Table'
FROM dbo.vwChildObjects
WHERE DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND (
		ParentSchemaName = @Schema
		AND ParentObjectName = @Object
		)
ORDER BY [ServerName]
	,[DatabaseName]
	,SchemaName
	,ObjectName;