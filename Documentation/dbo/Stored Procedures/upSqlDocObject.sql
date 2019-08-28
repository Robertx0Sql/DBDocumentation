
CREATE PROCEDURE [dbo].[upSqlDocObject] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255) = NULL
	,@Object VARCHAR(255) = NULL
	,@ObjectType VARCHAR(255) = NULL
	)
AS
SELECT [ServerName]
	,[DatabaseName]
	,SchemaName AS [TableSchemaName]
	,ObjectName AS [TableName]
	,[TypeDescriptionUser]
	,[DocumentationDescription]
	,QualifiedFullName AS [QualifiedTableName]
	,TypeGroup
	,TypeCode
	,DocumentationLoadDate
	,CodeFlag
FROM dbo.vwObjectDoc
WHERE DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND (
		(
			SchemaName = @Schema
			AND ObjectName = @Object
			AND (
				[TypeDescriptionUser] = @ObjectType
				OR @ObjectType IS NULL
				)
			)
		OR (
			@Schema IS NULL
			AND @Object IS NULL
			AND @ObjectType IS NULL
			)
		);
