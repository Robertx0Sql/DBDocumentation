CREATE VIEW [Staging].vwSQLColumnReference 
AS
WITH cte AS (/*Ensure only the 1st FK_NAME is used -- as FK_NAME can be a SQL auto generated name   */
	SELECT [SQLColumnReferenceId]
	,ServerName
	,DatabaseName
	,SchemaName
	,ObjectName
	,ObjectType 
	,ColumnName
	,ColumnId
	,FK_NAME
	,ReferencedSchemaName
	,ReferencedObjectName
	,ReferencedObjectType
	,ReferencedColumnName
	,LoadDateTime
	,rnk= ROW_NUMBER () OVER (PARTITION BY 
									ServerName
									,DatabaseName
									,SchemaName
									,ObjectName
									,ObjectType 
									,ColumnName
									,ReferencedSchemaName
									,ReferencedObjectName
									,ReferencedObjectType
									,ReferencedColumnName
								ORDER BY 
									FK_NAME ) 
	FROM [Staging].SQLColumnReference

)
SELECT [SQLColumnReferenceId]
	,ServerName
	,DatabaseName
	,SchemaName
	,ObjectName
	,ObjectType
	,ColumnName
	,ColumnId
	,FK_NAME
	,ReferencedSchemaName
	,ReferencedObjectName
	,ReferencedObjectType
	,ReferencedColumnName
	,LoadDateTime
FROM cte 
where rnk =1;