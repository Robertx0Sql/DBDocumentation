
CREATE PROCEDURE [dbo].[upSqlDocDatabaseObjects] (
	@Server VARCHAR(255) = NULL
	,@DatabaseName VARCHAR(255) = NULL
	,@ObjectType VARCHAR(255) = NULL
	,@Schema VARCHAR(255) = NULL
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
	AND ServerName = @Server
	AND Typecode != 'C' -- Check Constraint
	AND (
		[TypeDescriptionUser] = @ObjectType
		OR @ObjectType IS NULL
		)
	AND (
		schemaName = @schema
		OR @schema IS NULL
		)
ORDER BY [ServerName]
	,[DatabaseName]
	,TypeGroupOrder
	,TypeOrder
	,TypeGroup
	,[TypeDescriptionUser]
	,[TableSchemaName]
	,[TableName]

