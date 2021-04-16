CREATE PROCEDURE [report].[upGetSqlSchema] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	)
AS
BEGIN
	SELECT DISTINCT SchemaName
	FROM (
		SELECT SERVERNAME
			,DatabaseName
			,schemaName
		FROM dbo.vwChildObjects
		
		UNION ALL
		
		SELECT SERVERNAME
			,DatabaseName
			,ParentschemaName
		FROM dbo.vwChildObjects
		) AS T
	WHERE SchemaName IS NOT NULL
		AND DatabaseName = @DatabaseName
		AND SERVERNAME = @Server;
END;