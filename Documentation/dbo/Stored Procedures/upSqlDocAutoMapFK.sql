
CREATE PROCEDURE [dbo].[upSqlDocAutoMapFK] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	)
AS
BEGIN
	SELECT ServerName
		,DatabaseName
		,column_id
		,TableSchemaName
		,TableName
		,name
		,ReferencedTableSchemaName
		,ReferencedTableName
		,referenced_column
		,FK_NAME
		,matchid
		, count(1) over (partition by  
						TableSchemaName
		,TableName
		,name
					) as FKCount
	FROM dbo.vwAutoMapFK
	WHERE SERVERNAME = @Server
		AND DatabaseName = @DatabaseName
	order by TableSchemaName
		,TableName
		,name
		,ReferencedTableSchemaName
		,ReferencedTableName
	END