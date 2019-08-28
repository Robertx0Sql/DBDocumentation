CREATE VIEW [dbo].[vwObjectDoc]
AS
SELECT [ServerName]
	,[DatabaseName]
	,TypeGroup
	,rtrim(d.[objectType]) AS TypeCode
	,TypeDescriptionUser
	,TypeDescriptionSQL
	,[SchemaName]
	,[ObjectName]
	,[DocumentationDescription]
	,TypeGroupOrder
	,TypeOrder
	,TypeCount
	,StagingDateTime AS DocumentationLoadDate
	,QUOTENAME([SchemaName]) + '.' + QUOTENAME([ObjectName]) AS QualifiedFullName
	,ParentObjectName
	,ParentSchemaName
	,fields
	,d.Definition
	,t.UserModeFlag
	,t.CodeFlag 
FROM [Staging].[ObjectDocumentation] d
LEFT JOIN dbo.vwObjectType t ON t.TypeCode = rtrim(d.[objectType]);
