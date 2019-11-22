
CREATE PROCEDURE [dbo].[usp_ObjectCodeUpdate] (@TVPObjectCode [ObjectCodeTableType] READONLY)
AS
BEGIN
	SET NOCOUNT ON;

	DELETE E
	FROM [Staging].[ObjectCode] E
	INNER JOIN @TVPObjectCode X
		ON x.[ServerName] = E.[ServerName]
			AND X.[DatabaseName] = E.[DatabaseName];

	INSERT INTO [Staging].[ObjectCode] (
		[ServerName]
		,[DatabaseName]
		,[SMOObjectType]
		,[SchemaName]
		,[ObjectName]
		,[Code]
		)
	SELECT [ServerName]
		,[DatabaseName]
		,[SMOObjectType]
		,[SchemaName]
		,[ObjectName]
		,[Code]
	FROM @TVPObjectCode;
END;