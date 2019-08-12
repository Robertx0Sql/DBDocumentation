CREATE PROCEDURE [dbo].[upSqlDocDatabaseObject] (
	@Server VARCHAR(255) = NULL
	,@DatabaseName VARCHAR(255) = NULL
	)
AS
SELECT [ServerName]
	,[DatabaseName]
	,[DocumentationDescription]
	,StagingDateTime as  DocumentationLoadDate 
FROM [Staging].[ObjectDocumentation]
WHERE DatabaseName = @DatabaseName
	AND ServerName = @Server
	AND ObjectType= '-X-' -- DB