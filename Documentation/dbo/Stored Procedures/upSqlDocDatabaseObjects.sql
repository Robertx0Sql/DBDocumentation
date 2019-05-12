CREATE PROCEDURE [dbo].[upSqlDocDatabaseObjects] (
	@Server VARCHAR(255) = NULL
	,@DatabaseName VARCHAR(255) = NULL
	)
AS
SELECT [object_type]
	,[ServerName]
	,[DatabaseName]

FROM dbo.vwObjectDoc
WHERE DatabaseName = @DatabaseName
	AND ServerName = @Server

