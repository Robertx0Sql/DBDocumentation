﻿CREATE PROCEDURE [staging].[uspUpdateSQLDocColumnReference] (@TVP [SQLColumnReferenceTableType] READONLY)
AS
BEGIN
	SET NOCOUNT ON;

	DELETE E
	FROM [Staging].[SQLColumnReference] E
	INNER JOIN @TVP X
		ON x.[ServerName] = E.[ServerName]
			AND X.[DatabaseName] = E.[DatabaseName];

	INSERT INTO [Staging].[SQLColumnReference] (
		[ServerName]
		,[DatabaseName]
		,[SchemaName]
		,[ObjectName]
		,[ObjectType]
		,[ColumnName]
		,[ColumnId]
		,[FK_NAME]
		,[ReferencedSchemaName]
		,[ReferencedObjectName]
		,[ReferencedObjectType]
		,[ReferencedColumnName]
		)
	SELECT [ServerName]
		,[DatabaseName]
		,[SchemaName]
		,[ObjectName]
		,[ObjectType]
		,[ColumnName]
		,[ColumnId]
		,[FK_NAME]
		,[ReferencedSchemaName]
		,[ReferencedObjectName]
		,[ReferencedObjectType]
		,[ReferencedColumnName]
	FROM @TVP
	WHERE [FK_NAME] IS NOT NULL;
END;