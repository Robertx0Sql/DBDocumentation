
CREATE PROCEDURE [dbo].[upSqlDocObjectColumns] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255) = NULL
	,@Object VARCHAR(255) = NULL
	)
AS
SELECT cd.[ServerName]
	,cd.[DatabaseName]
	,cd.[TypeCode]
	,cd.[TypeDescriptionUser]
	,cd.[TableSchemaName]
	,cd.[TableName]
	,cd.[name]
	,COALESCE(cd.[DocumentationDescription], vc.[DocumentationDescription]) AS [DocumentationDescription]
	,cd.[column_id]
	,cd.[datatype] + iif(cd.[is_identity] = 1, ' identity(' + CAST(ISNULL(cd.[ident_col_seed_value], 1) AS VARCHAR(10)) + ',' + CAST(ISNULL(cd.[ident_col_increment_value], 1) AS VARCHAR(10)) + ')', '') + iif(cd.[datatype] LIKE '%char%', '(' + CASE 
			WHEN cd.[max_length] = - 1
				THEN 'max'
			WHEN LEFT(cd.[datatype], 1) = 'n'
				THEN CAST(CAST(cd.[max_length] / 2.0 AS INT) AS VARCHAR(10))
			ELSE CAST(cd.[max_length] AS VARCHAR(10))
			END + ')', '') AS [datatype]
	,CASE 
		WHEN cd.[datatype] = 'uniqueidentifier'
			THEN '36'
		WHEN cd.[max_length] = - 1
			THEN 'max'
		WHEN LEFT(cd.[datatype], 1) = 'n'
			AND cd.[datatype] LIKE '%char%'
			THEN CAST(CAST(cd.[max_length] / 2.0 AS INT) AS VARCHAR(10))
		WHEN cd.[datatype] LIKE '%char%'
			THEN CAST(cd.[max_length] AS VARCHAR(10))
		ELSE CAST(iif(cd.[precision] > cd.[max_length], cd.[precision], cd.[max_length]) AS VARCHAR(10))
		END AS [length]
	,cd.[collation_name]
	,CAST(iif(cd.[is_nullable] = 1, 'yes', 'no') AS VARCHAR(3)) AS nulls
	,CAST(iif(cd.[is_computed] = 1, 'yes', 'no') AS VARCHAR(3)) AS computed
	,cd.[Column_Default]
	,CAST(iif(PK = 1, iif(SUM(CAST(PK AS INT)) OVER (
					PARTITION BY cd.[TypeDescriptionUser]
					,cd.[ServerName]
					,cd.[DatabaseName]
					,cd.[TableSchemaName]
					,cd.[TableName]
					) > 1, 'composite PK', 'yes'), NULL) AS VARCHAR(25)) AS [PK]
	,ISNULL(cd.[FK_NAME], AFK.[FK_NAME]) AS [FK_NAME]
	,iif(cd.TypeCode = 'V', vc.TABLE_SCHEMA, ISNULL(cd.[ReferencedTableSchemaName], afk.[ReferencedTableSchemaName])) AS [ReferencedTableSchemaName]
	,iif(cd.TypeCode = 'V', vc.TABLE_NAME, ISNULL(cd.[ReferencedTableName], afk.[ReferencedTableName])) AS [ReferencedTableName]
	,iif(cd.TypeCode = 'V', vc.COLUMN_NAME, ISNULL(cd.[referenced_column], afk.[referenced_column])) AS [referenced_column]
	,iif(cd.TypeCode = 'V', vc.TABLE_NAME + '.' + vc.COLUMN_NAME, ISNULL(cd.[ReferencedTableName] + '.' + cd.[referenced_column], AFK.[ReferencedTableName] + '.' + AFK.[referenced_column])) AS FK
	,iif(cd.TypeCode = 'V', vc.TypeDescriptionUser, 'Table') AS ReferencedObjectType
	,iif(cd.[FK_NAME] IS NOT NULL
		OR AFK.fk_Name IS NOT NULL, 'yes', NULL) AS isFK
	,iif(cd.TypeCode = 'V', 'Source', 'FK') AS fk_title
	,cd.DocumentationLoadDate
FROM [dbo].[vwColumnDoc] cd
LEFT JOIN dbo.[vwViewColumnInformation] vc
	ON cd.SERVERNAME = vc.SERVERNAME
		AND cd.DatabaseName = vc.DatabaseName
		AND cd.[TableSchemaName] = vc.[VIEW_SCHEMA]
		AND cd.[TableName] = vc.[VIEW_NAME]
		AND cd.column_id = vc.ORDINAL_POSITION
		AND cd.TypeCode = 'V'
LEFT JOIN dbo.vwAutoMapFK AS AFK
	ON cd.SERVERNAME = afk.SERVERNAME
		AND cd.DatabaseName = afk.DatabaseName
		AND cd.[TableSchemaName] = afk.TableSchemaName
		AND cd.TableName = afk.TableName
		AND cd.column_id = afk.column_id
		AND afk.matchid = 1
WHERE cd.[name] IS NOT NULL
	AND cd.SERVERNAME = @Server
	AND cd.DatabaseName = @DatabaseName
	AND (
		(
			cd.[TableSchemaName] = @Schema
			AND cd.[TableName] = @Object
			)
		OR (
			@Schema IS NULL
			AND @Object IS NULL
			)
		);