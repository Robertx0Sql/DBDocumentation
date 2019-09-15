
CREATE PROCEDURE [dbo].[upSqlDocDatabaseObjects] (
	@Server VARCHAR(255) = NULL
	,@DatabaseName VARCHAR(255) = NULL
	,@ObjectType VARCHAR(10) = NULL
	,@Schema VARCHAR(255) = NULL
	,@UserMode bit = 1
	)
AS
SELECT [ServerName]
	,[DatabaseName]
	,SchemaName AS ReferencedSchemaName 
	,ObjectName AS ReferencedObjectName 
	,TypeCode AS ReferencedTypeCode
	,TypeGroup
	,[TypeDescriptionUser]
	,TypeGroupOrder
	,TypeOrder
	,TypeCount
	,[DocumentationDescription]
	,DocumentationLoadDate

FROM dbo.vwObjectDoc
WHERE DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND Typecode != 'C' -- Check Constraint
	AND (
		TypeCode = @ObjectType
		OR @ObjectType IS NULL
		)
	AND (
		schemaName = @schema
		OR @schema IS NULL
		)
	and (@UserMode = usermodeFlag or @UserMode=0)
ORDER BY [ServerName]
	,[DatabaseName]
	,TypeGroupOrder
	,TypeOrder
	,TypeGroup
	,[TypeDescriptionUser]
	,[SchemaName]
	,[ObjectName];

