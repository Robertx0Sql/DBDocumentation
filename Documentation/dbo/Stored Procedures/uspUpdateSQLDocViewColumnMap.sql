
CREATE PROCEDURE [dbo].[uspUpdateSQLDocViewDefinitionColumnMap] 
	@TVPViewCol [SQLDocViewDefinitionColumnMapTableType] READONLY
AS
BEGIN
	SET NOCOUNT ON

	DELETE E
	FROM [Staging].[SQLDocViewDefinitionColumnMap] E
	INNER JOIN @TVPViewCol X
		ON x.[ServerName] = E.[ServerName]
			AND X.[DatabaseName] = E.[DatabaseName]

	INSERT INTO [Staging].[SQLDocViewDefinitionColumnMap] (
		[ServerName]
		,[DatabaseName]
		,[ViewSchema]
		,[ViewName]
		,[SourceTableSchema]
		,[SourceTableName]
		,[ColumnName]
		,[ColumnId]
		,[is_ambiguous]
		,[Expression]
		)
	SELECT [ServerName]
		,[DatabaseName]
		,[ViewSchema]
		,[ViewName]
		,[SourceTableSchema]
		,[SourceTableName]
		,[ColumnName]
		,[ColumnId]
		,[is_ambiguous]
		,[Expression]
	FROM @TVPViewCol
END