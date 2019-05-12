CREATE PROCEDURE [dbo].[upSqlDocDatabaseTable] (
	@Server VARCHAR(255) 
	,@DatabaseName VARCHAR(255) 
	,@QualifiedTableName VARCHAR(255) 
	)
AS
SELECT [object_type]
	,[ServerName]
	,[DatabaseName]
	,[objectType]
	,[object_id]
	,[TableSchemaName]
	,[TableName]
	,[DocumentationDescription]
	,[QualifiedTableName]
FROM dbo.vwObjectDoc
WHERE DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND QualifiedTableName = @QualifiedTableName;
