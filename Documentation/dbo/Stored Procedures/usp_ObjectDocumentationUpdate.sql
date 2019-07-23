
CREATE PROCEDURE [dbo].[usp_ObjectDocumentationUpdate] 
(
	@TVPObjDoc [dbo].[ObjectDocumentationTableType] READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	DELETE E
	FROM [Staging].[ObjectDocumentation] E
	INNER JOIN @TVPObjDoc X
		ON x.[ServerName] = E.[ServerName]
			AND X.[DatabaseName] = E.[DatabaseName];

	INSERT INTO [Staging].[ObjectDocumentation] (
		[ServerName]
		,[DatabaseName]
		,[ObjectType]
		,[ParentSchemaName]
		,[ParentObjectName]
		,[SchemaName]
		,[ObjectName]
		,Fields
		,[Definition]
		,[DocumentationDescription]
		)
	SELECT [ServerName]
		,[DatabaseName]
		,[ObjectType]
		,[ParentSchemaName]
		,[ParentObjectName]
		,[SchemaName]
		,[ObjectName]
		,Fields
		,[Definition]
		,[DocumentationDescription]
	FROM @TVPObjDoc;
END;
