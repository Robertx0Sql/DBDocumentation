CREATE PROCEDURE [dbo].[uspUpdateSQLColumnReference] (@TVP [SQLColumnReferenceTableType] READONLY)
AS
BEGIN
	SET NOCOUNT ON;

	DELETE E
	FROM [dbo].[SQLColumnReference] E
	INNER JOIN @TVP X
		ON x.[ServerName] = E.[ServerName]
			AND X.[DatabaseName] = E.[DatabaseName];

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
	SELECT [ServerName]
		,[DatabaseName]
		,[SchemaName]
		,[ObjectName]
		,[ColumnName]
		,[ColumnId]
		,[FK_NAME]
		,[ReferencedSchemaName]
		,[ReferencedObjectName]
		,[ReferencedColumnName]
	FROM @TVP
	WHERE [FK_NAME] IS NOT NULL;
END;