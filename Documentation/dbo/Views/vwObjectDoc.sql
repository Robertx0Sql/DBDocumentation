


CREATE VIEW [dbo].[vwObjectDoc]
AS
SELECT 
	[ServerName]
	,[DatabaseName]
	,TypeCode 
	, TypeDescriptionUser
	,TypeDescriptionSQL
	,[TableSchemaName]
	,[TableName]
	,[DocumentationDescription]
	,QualifiedTableName
	,TypeGroup
FROM [dbo].[vwColumnDoc]
WHERE column_id IS NULL
and [typeCode]  is not null
