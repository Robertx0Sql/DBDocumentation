

CREATE VIEW [dbo].[vwObjectDoc]
AS
SELECT 
	[ServerName]
	,[DatabaseName]
	,TypeGroup
	,TypeCode 
	, TypeDescriptionUser
	,TypeDescriptionSQL
	,[TableSchemaName]
	,[TableName]
	,[DocumentationDescription]
	,QualifiedTableName
	,TypeGroupOrder
	,TypeOrder
	,TypeCount
FROM [dbo].[vwColumnDoc]
WHERE column_id IS NULL
and [typeCode]  is not null
