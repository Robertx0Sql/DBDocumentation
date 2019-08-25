
CREATE PROCEDURE [dbo].[uspUpdateSQLDOCAutoMapFK] (
	@Server VARCHAR(128)
	,@Database VARCHAR(128)
	)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [Staging].[ObjectDocumentation] (
		[ServerName]
		,[DatabaseName]
		,[ObjectType]
		,[ParentSchemaName]
		,[ParentObjectName]
		,[SchemaName]
		,[ObjectName]
		,[DocumentationDescription]
		,[Fields]
		)
	SELECT AFK.[ServerName]
		,AFK.[DatabaseName]
		,AFK.[TypeCode]
		,AFK.[TableSchemaName]
		,AFK.[TableName]
		,AFK.[TableSchemaName]
		,AFK.[FK_NAME]
		,AFK.[description]
		,AFK.[name]
	FROM [dbo].[vwAutoMapFKList] AFK
	LEFT JOIN [Staging].[ObjectDocumentation] E
		ON E.ServerName = AFK.ServerName
			AND E.DatabaseName = afk.DatabaseName
			AND e.ObjectType = afk.TypeCode
			AND e.ParentSchemaName = afk.TableSchemaName
			AND e.ParentObjectName = afk.TableName
			AND e.ObjectName = afk.FK_NAME
	WHERE E.StagingId IS NULL
		AND AFK.FKCount = 1
		AND AFK.[matchid] = 1
		AND AFK.ServerName = @Server
		AND AFK.DatabaseName = @Database

	UPDATE E
	SET [FK_NAME] = AFK.[FK_NAME]
		,[ReferencedTableSchemaName] = AFK.ReferencedTableSchemaName
		,[ReferencedTableName] = AFK.ReferencedTableName
		,[referenced_column] = AFK.referenced_column
	FROM [dbo].[vwAutoMapFKList] AFK
	INNER JOIN [Staging].ColumnDoc E
		ON E.ServerName = AFK.ServerName
			AND E.DatabaseName = afk.DatabaseName
			AND e.TableSchemaName = afk.TableSchemaName
			AND e.TableName = afk.TableName
			AND e.name = AFK.name
	WHERE E.[FK_NAME] IS NULL
		AND AFK.FKCount = 1
		AND AFK.[matchid] = 1
		AND AFK.ServerName = @Server
		AND AFK.DatabaseName = @Database
END