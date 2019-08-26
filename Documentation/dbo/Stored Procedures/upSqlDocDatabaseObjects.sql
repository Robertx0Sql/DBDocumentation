
CREATE PROCEDURE [dbo].[upSqlDocDatabaseObjects] (
	@Server VARCHAR(255) = NULL
	,@DatabaseName VARCHAR(255) = NULL
	,@ObjectType VARCHAR(255) = NULL
	,@Schema VARCHAR(255) = NULL
	,@UserMode bit = 1
	)
AS
SELECT [ServerName]
	,[DatabaseName]
	,TypeGroup
	,[TypeDescriptionUser]
	,SchemaName AS [TableSchemaName]
	,ObjectName AS [TableName]
	,[DocumentationDescription]
	,TypeGroupOrder
	,TypeOrder
	,TypeCount
	,DocumentationLoadDate
FROM dbo.vwObjectDoc
WHERE DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND Typecode != 'C' -- Check Constraint
	AND (
		[TypeDescriptionUser] = @ObjectType
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
	,[TableSchemaName]
	,[TableName];

