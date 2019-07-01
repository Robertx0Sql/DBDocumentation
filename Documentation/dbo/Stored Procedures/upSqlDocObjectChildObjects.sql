

CREATE PROCEDURE [dbo].[upSqlDocObjectChildObjects] 
	@Server VARCHAR(255) 
	,@DatabaseName VARCHAR(255) 
	,@Schema  VARCHAR(255) =NULL
	,@Object VARCHAR(255) =NULL
	,@ObjectType VARCHAR(255) =NULL
AS
SELECT [ServerName]
	,[DatabaseName]
	,SchemaName 
	,ObjectName 
	,[TypeDescriptionUser]
	,[DocumentationDescription]
	,QualifiedFullName as  [QualifiedTableName]
	,TypeGroup
	,TypeCode
	,DocumentationLoadDate 
FROM dbo.vwObjectDoc
WHERE DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND (
			ParentSchemaName = @Schema
			AND ParentObjectName = @Object
			AND ([TypeDescriptionUser] = @ObjectType
			or @ObjectType is null)
			)