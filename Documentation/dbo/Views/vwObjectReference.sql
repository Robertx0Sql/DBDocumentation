





CREATE VIEW [dbo].[vwObjectReference]
AS
WITH cte as (
SELECT [ServerName]
	,[DatabaseName]
	,[referencing_schema_name]
	,[referencing_entity_name]
	,[referencing_TypeCode]
	,referencing_TypeDescriptionSQL
	,[referenced_server_name]
	,[referenced_database_name]
	,[referenced_schema_name]
	,[referenced_entity_name]
FROM [Staging].[ObjectReference]

UNION ALL

SELECT COALESCE([referenced_server_name], r.[ServerName])
	,COALESCE([referenced_database_name], r.[DatabaseName])
	,[referenced_schema_name]
	,[referenced_entity_name]
	,od.TypeCode
	,od.TypeDescriptionSQL
	,R.[ServerName]
	,R.[DatabaseName]
	,[referencing_schema_name]
	,[referencing_entity_name]
FROM [Staging].[ObjectReference] R
LEFT JOIN [dbo].[vwObjectDoc] OD ON R.SERVERNAME = od.SERVERNAME
	AND r.DatabaseName = od.DatabaseName
	AND od.TableName = [referenced_entity_name]
	AND od.TableSchemaName = referenced_schema_name
WHERE referencing_schema_name IS NOT NULL
)

select [ServerName]
	,[DatabaseName]
	,[referencing_schema_name]
	,[referencing_entity_name]
	,[referencing_TypeCode] as TypeCode
	, ISNULL(t.TypeDescriptionUser,  cte.[referencing_TypeDescriptionSQL])as [TypeDescriptionUser]
	,[referenced_server_name]
	,[referenced_database_name]
	,[referenced_schema_name]
	,[referenced_entity_name]
	,t.TypeGroup
		,T.TypeGroupOrder
	,T.TypeOrder
	from cte 
	left join dbo.vwObjectType T on t.TypeCode =cte.[referencing_TypeCode] 
	where cte.[referencing_TypeDescriptionSQL] is not null