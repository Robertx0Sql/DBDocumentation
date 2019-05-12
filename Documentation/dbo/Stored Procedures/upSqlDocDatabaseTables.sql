
--EXEC [dbo].[upSqlDocDatabases]

--EXEC [dbo].[upSqlDocDatabases]

CREATE PROCEDURE [dbo].[upSqlDocDatabaseTables] (
	@Server VARCHAR(255) 
	,@DatabaseName VARCHAR(255) 
	)
AS
SELECT DISTINCT  [object_type]
	,[ServerName]
	,[DatabaseName]
	,[TableSchemaName]
	,[TableName]
	,[DocumentationDescription]
	,[QualifiedTableName]
FROM dbo.vwObjectDoc
WHERE DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND [object_type] ='Table';
