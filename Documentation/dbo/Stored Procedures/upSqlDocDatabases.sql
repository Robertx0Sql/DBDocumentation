CREATE PROCEDURE [dbo].[upSqlDocDatabases] (
	@Server VARCHAR(255) = NULL
	,@DatabaseName VARCHAR(255) = NULL
	)
AS
SELECT DISTINCT SERVERNAME
	,DatabaseName
FROM dbo.vwObjectDoc
WHERE (
		DatabaseName = @DatabaseName
		OR @DatabaseName IS NULL
		)
	AND (
		SERVERNAME = @Server
		OR @Server IS NULL
		);
