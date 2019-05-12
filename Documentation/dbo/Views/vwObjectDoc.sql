
CREATE VIEW [dbo].[vwObjectDoc]
AS
SELECT [object_type]
	,[ServerName]
	,[DatabaseName]
	,[objectType]
	,[object_id]
	,[TableSchemaName]
	,[TableName]
	,[DocumentationDescription]
	,QualifiedTableName
FROM [dbo].[vwColumnDoc]
WHERE column_id IS NULL
