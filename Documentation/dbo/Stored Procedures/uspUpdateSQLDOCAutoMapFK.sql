
CREATE PROCEDURE [dbo].[uspUpdateSQLDOCAutoMapFK] (
	@Server VARCHAR(128)
	,@Database VARCHAR(128)
	)
AS
BEGIN
	--SET NOCOUNT ON;

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
		,AFK.[ObjectSchemaName]
		,AFK.[ObjectName]
		,AFK.[ObjectSchemaName]
		,AFK.[FK_NAME]
		,AFK.[description]
		,AFK.[ColumnName]
	FROM [dbo].[vwAutoMapFKList] AFK
	LEFT JOIN [Staging].[ObjectDocumentation] E
		ON E.ServerName = AFK.ServerName
			AND E.DatabaseName = afk.DatabaseName
			AND e.ObjectType = afk.TypeCode
			AND e.ParentSchemaName = afk.[ObjectSchemaName]
			AND e.ParentObjectName = afk.[ObjectName]
			AND e.ObjectName = afk.FK_NAME
	WHERE E.StagingId IS NULL
		AND AFK.FKCount = 1
		AND AFK.[matchid] = 1
		AND AFK.ServerName = @Server
		AND AFK.DatabaseName = @Database

INSERT INTO [dbo].[SQLColumnReference] (
		[ServerName]
		,[DatabaseName]
		,[SchemaName]
		,[ObjectName]
		,[ColumnName]
		,[ColumnId]
		,[FK_NAME]
		,[ReferencedSchemaName]
		,[ReferencedObjectName]
		,[ReferencedColumnName]
		)
	SELECT AFK.[ServerName] AS [ServerName]
		,AFK.[DatabaseName] AS [DatabaseName]
		,AFK.[ObjectSchemaName] AS [SchemaName]
		,AFK.[ObjectName] AS [ObjectName]
		,AFK.[ColumnName] AS [ColumnName]
		,AFK.[ColumnId] AS [ColumnId]
		,AFK.[FK_NAME] AS [FK_NAME]
		,[ReferencedTableSchemaName] AS [ReferencedSchemaName]
		,[ReferencedTableName] AS [ReferencedObjectName]
		,[referenced_column] AS [ReferencedColumnName]

	FROM [dbo].[vwAutoMapFKList] AFK
	LEFT JOIN [dbo].[SQLColumnReference]  E
		ON E.ServerName = AFK.ServerName
			AND E.DatabaseName = afk.DatabaseName
			AND e.[SchemaName] = afk.[ObjectSchemaName]
			AND e.[ObjectName] = afk.[ObjectName]
			AND e.[ColumnName] = AFK.[ColumnName]
	WHERE E.[SQLColumnReferenceId] IS NULL
		AND AFK.FKCount = 1
		AND AFK.[matchid] = 1
		AND AFK.ServerName = @Server
		AND AFK.DatabaseName = @Database

END