

CREATE PROCEDURE [dbo].[upSqlDocObject] 
	@Server VARCHAR(255) 
	,@DatabaseName VARCHAR(255) 
	,@Schema  VARCHAR(255) =NULL
	,@Object VARCHAR(255) =NULL
	,@ObjectType VARCHAR(255) =NULL
AS
SELECT [ServerName]
	,[DatabaseName]
	,SchemaName as [TableSchemaName]
	,ObjectName as [TableName]
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
		(
			SchemaName = @Schema
			AND ObjectName = @Object
			AND ([TypeDescriptionUser] = @ObjectType
			or @ObjectType is null)
			)
		OR (
			@Schema IS NULL
			AND @Object IS NULL
			AND @ObjectType IS NULL
			)
		)
