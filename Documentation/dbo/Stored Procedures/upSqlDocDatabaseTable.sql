
CREATE PROCEDURE [dbo].[upSqlDocDatabaseTable] 
	@Server VARCHAR(255) 
	,@DatabaseName VARCHAR(255) 
	,@Schema  VARCHAR(255) =NULL
	,@Object VARCHAR(255) =NULL
	,@ObjectType VARCHAR(255) =NULL
AS
SELECT [ServerName]
	,[DatabaseName]
	,[TableSchemaName]
	,[TableName]
	,[TypeDescriptionUser]
	,[DocumentationDescription]
	,[QualifiedTableName]
	,TypeGroup
	,TypeCode
	,DocumentationLoadDate 
FROM dbo.vwObjectDoc
WHERE DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND (
		(
			[TableSchemaName] = @Schema
			AND [TableName] = @Object
			AND ([TypeDescriptionUser] = @ObjectType
			or @ObjectType is null)
			)
		OR (
			@Schema IS NULL
			AND @Object IS NULL
			AND @ObjectType IS NULL
			)
		)
