
CREATE PROCEDURE [dbo].[usp_ViewColumnUpdate] 
	@TVPViewCol [ViewColumnTableType] READONLY
AS
BEGIN
	SET NOCOUNT ON

	DELETE E
	FROM [Staging].[ViewColumn] E
	INNER JOIN @TVPViewCol X
		ON x.[ServerName] = E.[ServerName]
			AND X.[DatabaseName] = E.[DatabaseName]

	INSERT INTO [Staging].[ViewColumn] (
		[ServerName]
		,[DatabaseName]
		,[VIEW_SCHEMA]
		,[VIEW_NAME]
		,[TABLE_SCHEMA]
		,[TABLE_NAME]
		,[COLUMN_NAME]
		,[ORDINAL_POSITION]
		,[is_ambiguous]
		,[Expression]
		)
	SELECT [ServerName]
		,[DatabaseName]
		,[VIEW_SCHEMA]
		,[VIEW_NAME]
		,[TABLE_SCHEMA]
		,[TABLE_NAME]
		,[COLUMN_NAME]
		,[ORDINAL_POSITION]
		,[is_ambiguous]
		,[Expression]
	FROM @TVPViewCol
END