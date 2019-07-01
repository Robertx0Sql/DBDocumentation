



CREATE VIEW [dbo].[vwObjectDoc]
AS
SELECT 
	[ServerName]
	,[DatabaseName]
	,TypeGroup
	,TypeCode 
	, TypeDescriptionUser
	,TypeDescriptionSQL
	,[SchemaName]
	,[ObjectName]
	,[DocumentationDescription]
	,TypeGroupOrder
	,TypeOrder
	,TypeCount
	,StagingDateTime as  DocumentationLoadDate
	,QUOTENAME([SchemaName]) + '.' + QUOTENAME( [ObjectName]) AS QualifiedFullName 
	,ParentObjectName
	,ParentSchemaName
FROM [Staging].[ObjectDocumentation] d
left join dbo.vwObjectType  t on t.TypeCode = rtrim(d. [objectType] ) ;
