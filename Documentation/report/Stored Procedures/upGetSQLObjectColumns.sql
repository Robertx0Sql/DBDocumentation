CREATE PROCEDURE [report].[upGetSQLObjectColumns] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255) = NULL
	,@Object VARCHAR(255) = NULL
	,@ObjectType VARCHAR(10)
	)
AS
BEGIN
	SELECT [ServerName]
		,[DatabaseName]
		,[TypeCode]
		,[TypeDescriptionUser]
		,[TableSchemaName]
		,[TableName]
		,cd.columnName AS [name]
		,[DocumentationDescription]
		,[column_id]
		,cd.[datatype] + cd.DataTypeExtension AS [datatype]
		,[length]
		,[collation_name]
		,[PKType] AS [PK]
		,[FK_NAME]
		,[ReferencedSchemaName]
		,[ReferencedObjectName]
		,[ReferencedTypeCode]
		,[ReferencedColumn]
		,[ReferencedTypeDescriptionUser]
		,[FKGeneratedName] AS [FK]
		,CAST(iif(cd.[is_nullable] = 1, 'yes', 'no') AS VARCHAR(3)) AS nulls
		,CAST(iif(cd.[is_computed] = 1, 'yes', 'no') AS VARCHAR(3)) AS computed
		,iif(cd.[is_identity] = 1, NULL, cd.[Column_Default]) AS [Column_Default]
		,iif([FK_NAME] IS NOT NULL, 'yes', NULL) AS isFK
		,iif(cd.TypeCode = 'V', 'Source', 'FK') AS fk_title
		,[DocumentationLoadDate]
	FROM [report].[DatabaseObjectColumn] cd
	WHERE cd.[ColumnName] IS NOT NULL
		AND cd.SERVERNAME = @Server
		AND cd.DatabaseName = @DatabaseName
		AND (
			(
				cd.[TableSchemaName] = @Schema
				AND cd.[TableName] = @Object
				AND cd.TypeCode = @ObjectType
				)
			OR (
				@Schema IS NULL
				AND @Object IS NULL
				)
			);
END;
