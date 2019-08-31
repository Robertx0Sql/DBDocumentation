
CREATE PROCEDURE [dbo].[usp_ColumnDocUpdate] (@TVP [ColumnDocTableType] READONLY)
AS
BEGIN
	SET NOCOUNT ON;

	DELETE E
	FROM [Staging].[ColumnDoc] E
	INNER JOIN @TVP X
		ON x.[ServerName] = E.[ServerName]
			AND X.[DatabaseName] = E.[DatabaseName];

	INSERT INTO [Staging].[ColumnDoc] (
		[ServerName]
		,[DatabaseName]
		,[objectType]
		,[ObjectSchemaName]
		,[ObjectName]
		,[ColumnName]
		,[ColumnId]
		,[datatype]
		,[max_length]
		,[precision]
		,[scale]
		,[collation_name]
		,[is_nullable]
		,[is_identity]
		,[is_computed]
		,[is_primary_key]
		,[Column_Default]
		,[DocumentationDescription]
		)
	SELECT [ServerName]
		,[DatabaseName]
		,[objectType]
		,[SchemaName]
		,[ObjectName]
		,[ColumnName]
		,[column_id]
		,[datatype]
		,[max_length]
		,[precision]
		,[scale]
		,[collation_name]
		,ISNULL([is_nullable], 0)
		,ISNULL([is_identity], 0)
		,ISNULL([is_computed], 0)
		,ISNULL([is_primary_key], 0) AS [is_primary_key]
		,CASE 
			WHEN ISNULL([is_identity], 0) = 1 /**/
				THEN CONCAT (
						'identity('
						,[ident_col_seed_value]
						,','
						,[ident_col_increment_value]
						,')'
						)
			ELSE [Column_Default]
			END
		,[DocumentationDescription]
	FROM @TVP;
END;
