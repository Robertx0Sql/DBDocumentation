
CREATE PROCEDURE [report].[upGetSQLObjectCode] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255)
	,@Object VARCHAR(255)
	,@ObjectType VARCHAR(10)
	)
AS
SELECT code
FROM [Staging].[ObjectCode] oc
INNER JOIN [dbo].[vwObjectType] ot
	ON ot.SMOObjectType = oc.SMOObjectType
WHERE oc.SERVERNAME = @Server
	AND oc.DatabaseName = @DatabaseName
	AND (
		(
			oc.[SchemaName] = @Schema
			AND oc.[ObjectName] = @Object
			AND ot.TypeCode = @ObjectType
			)
		OR (
			@Schema IS NULL
			AND @Object IS NULL
			)
		);