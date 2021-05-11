CREATE PROCEDURE [report].[upGetSQLObjectCode] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255)
	,@Object VARCHAR(255)
	,@ObjectType VARCHAR(10)
	)
AS
SELECT ObjectCode AS code
FROM [report].[DatabaseObjectCode] AS oc
WHERE oc.SERVERNAME = @Server
	AND oc.DatabaseName = @DatabaseName
	AND (
		(
			oc.[objectSchemaName] = @Schema
			AND oc.[ObjectName] = @Object
			AND oc.TypeCode = @ObjectType
			)
		OR (
			@Schema IS NULL
			AND @Object IS NULL
			)
		);
