CREATE PROCEDURE [report].[upGetSQLObjectColumns] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255) = NULL
	,@Object VARCHAR(255) = NULL
	,@ObjectType VARCHAR(10)
	)
AS
BEGIN 
	SELECT cd.[ServerName]
		,cd.[DatabaseName]
		,cd.[TypeCode]
		,cd.[TypeDescriptionUser]
		,cd.[ObjectSchemaName] as [TableSchemaName]
		,cd.[ObjectName] as [TableName]
		,cd.[ColumnName] as [name]
		,COALESCE(cd.[DocumentationDescription], vc.[DocumentationDescription]) AS [DocumentationDescription]
		,cd.[ColumnId] as [column_id]
		,cd.[datatype] + iif(cd.[is_identity] = 1,  ' ' + cd.[Column_Default] , '') + iif(cd.[datatype] LIKE '%char%', '(' + CASE 
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
		,iif(cd.[is_identity] = 1,NULL, cd.[Column_Default]) as [Column_Default]
		,CAST(iif([is_primary_key] = 1, iif(SUM(CAST([is_primary_key] AS INT)) OVER (
						PARTITION BY cd.[TypeDescriptionUser]
						,cd.[ServerName]
						,cd.[DatabaseName]
						,cd.[ObjectSchemaName]
						,cd.[ObjectName]
						) > 1, 'composite PK', 'yes'), NULL) AS VARCHAR(25)) AS [PK]
		,od.[ObjectName] AS [FK_NAME]
		,iif(cd.TypeCode = 'V', vc.[SourceTableSchema], od.[ReferencedSchemaName]) AS [ReferencedSchemaName]
		,iif(cd.TypeCode = 'V', vc.[SourceTableName], od.[ReferencedObjectName]) AS [ReferencedObjectName]
		,IIF(cd.TypeCode = 'V', vc.TypeCode, 'U') AS ReferencedTypeCode
		,iif(cd.TypeCode = 'V', vc.[ColumnName], od.[ReferencedColumnName]) AS [ReferencedColumn]
		,iif(cd.TypeCode = 'V', vc.TypeDescriptionUser, 'Table') AS ReferencedTypeDescriptionUser
		,iif(cd.TypeCode = 'V', vc.[SourceTableName] + '.' + vc.[ColumnName], od.ReferencedSchemaName + '.'+ od.[ReferencedObjectName] + '.' + od.[ReferencedColumnName]) AS FK
		,iif(od.[FK_NAME] IS NOT NULL, 'yes', NULL) AS isFK
		,iif(cd.TypeCode = 'V', 'Source', 'FK') AS fk_title
		,cd.DocumentationLoadDate
	FROM [Staging].[vwColumnDoc] cd
	left join [Staging].SQLColumnReference od
		ON cd.SERVERNAME = od.ServerName
			AND cd.DatabaseName = od.DatabaseName
			AND cd.[ObjectSchemaName] = od.[SchemaName]
			AND cd.[ObjectName] = od.[ObjectName]
	and cd.[ColumnName] = od.ColumnName 
	LEFT JOIN dbo.[vwSQLDocViewDefinitionColumnMap] vc
		ON cd.SERVERNAME = vc.SERVERNAME
			AND cd.DatabaseName = vc.DatabaseName
			AND cd.[ObjectSchemaName] = vc.[ViewSchema]
			AND cd.[ObjectName] = vc.[ViewName]
			AND cd.[ColumnId] = vc.[ColumnId]
			AND cd.TypeCode = 'V'
	
	WHERE cd.[ColumnName] IS NOT NULL
		AND cd.SERVERNAME = @Server
		AND cd.DatabaseName = @DatabaseName
		AND (
			(
				cd.[ObjectSchemaName] = @Schema
				AND cd.[ObjectName] = @Object
				and cd.TypeCode = @ObjectType
				)
			OR (
				@Schema IS NULL
				AND @Object IS NULL
				)
			);
END;