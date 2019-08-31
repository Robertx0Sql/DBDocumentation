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
		,count(1) OVER (
			PARTITION BY TableSchemaName
			,TableName
			,name
			) AS FKCount
	FROM dbo.vwAutoMapFK
	WHERE SERVERNAME = @Server
		AND DatabaseName = @DatabaseName
	ORDER BY TableSchemaName
		,TableName
		,name
		,ReferencedTableSchemaName
		,ReferencedTableName
END
