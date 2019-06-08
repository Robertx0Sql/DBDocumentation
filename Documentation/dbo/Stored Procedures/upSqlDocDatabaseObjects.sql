
CREATE PROCEDURE [dbo].[upSqlDocDatabaseObjects] (
	@Server VARCHAR(255) = NULL
	,@DatabaseName VARCHAR(255) = NULL
	)
AS
SELECT 
	[ServerName]
	,[DatabaseName]
	,[TableSchemaName]
	,[TableName]
	,[TypeDescriptionUser]
	,[DocumentationDescription]
	,TypeGroup
FROM dbo.vwObjectDoc
WHERE DatabaseName = @DatabaseName
	AND ServerName = @Server

