
CREATE PROCEDURE [dbo].[upSqlDocObjectCode] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255)
	,@Object VARCHAR(255)
	)
AS
SELECT code
FROM [Staging].[ObjectCode] oc
WHERE oc.SERVERNAME = @Server
	AND oc.DatabaseName = @DatabaseName
	AND (
		(
			oc.[SchemaName] = @Schema
			AND oc.[ObjectName] = @Object
			)
		OR (
			@Schema IS NULL
			AND @Object IS NULL
			)
		);