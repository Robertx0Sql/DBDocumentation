
CREATE PROCEDURE [report].[upGetSQLObject] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255) = NULL
	,@Object VARCHAR(255) = NULL
	,@ObjectType VARCHAR(10) = NULL
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
FROM [REPORT].[DatabaseObjectDocumentation]
WHERE DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND (
		(
			SchemaName = @Schema
			AND ObjectName = @Object
			AND (
				TypeCode = @ObjectType
				OR @ObjectType IS NULL
				)
			)
		OR (
			@Schema IS NULL
			AND @Object IS NULL
			AND @ObjectType IS NULL
			)
		);
