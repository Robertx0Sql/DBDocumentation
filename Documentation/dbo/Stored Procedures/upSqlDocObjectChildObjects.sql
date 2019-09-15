CREATE PROCEDURE [dbo].[upSqlDocObjectChildObjects] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255) = NULL
	,@Object VARCHAR(255) = NULL
	,@ObjectType VARCHAR(10) = NULL
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
	,ReferencedColumnName  as ReferencedColumn
	,ReferencedObjectName  as ReferencedObjectName
	,ReferencedSchemaName  as ReferencedSchemaName
	,	ReferencedTypeCode
	,ReferencedObjectType = 'Table'
FROM dbo.vwChildObjects
WHERE DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND ParentSchemaName = @Schema
	AND ParentObjectName = @Object
	AND ParentTypeCode =@ObjectType

ORDER BY [ServerName]
	,[DatabaseName]
	,SchemaName
	,ObjectName;