CREATE VIEW [dbo].[vwObjectDoc]
AS
SELECT d.[ServerName]
	,d.[DatabaseName]
	,t.TypeGroup
	,rtrim(d.[objectType]) AS TypeCode
	,t.TypeDescriptionUser
	,t.TypeDescriptionSQL
	,d.[SchemaName]
	,d.[ObjectName]
	,d.[DocumentationDescription]
	,t.TypeGroupOrder
	,t.TypeOrder
	,t.TypeCount
	,d.StagingDateTime AS DocumentationLoadDate
	,QUOTENAME(d.[SchemaName]) + '.' + QUOTENAME(d.[ObjectName]) AS QualifiedFullName
	,d.ParentObjectName
	,d.ParentSchemaName
	,rtrim(pd.[ObjectType]) AS ParentTypeCode
	,iif(rtrim(d.[objectType]) in ('PK','D','UQ','C','F' ,'INDEX') , 'U',rtrim(d.[objectType]) ) as ParentObjectType

	,d.fields
	,d.Definition
	,t.UserModeFlag
	,t.CodeFlag 
/*Debug*/
	,d.StagingId
	,pd.Stagingid AS parentStagingId
FROM [Staging].[ObjectDocumentation] d
LEFT JOIN dbo.vwObjectType t
	ON t.TypeCode = rtrim(d.[objectType])
LEFT JOIN [Staging].[ObjectDocumentation] pd
	ON pd.ServerName = d.ServerName
		AND pd.DatabaseName = d.DatabaseName
		AND pd.ObjectName = d.ParentObjectName
		AND pd.SchemaName = d.ParentSchemaName
