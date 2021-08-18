CREATE PROCEDURE [report].[upUpdateDatabaseObjectColumns] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@PrintLog BIT =0)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        DECLARE @LogID INT; 
		DECLARE @LogDetailMessage VARCHAR(100)
			,@LogDetailTime DATETIME = GETUTCDATE();
		DECLARE @LogDetailRows BIGINT;

		DECLARE @LogDescription NVARCHAR(2000) = 	'@Server = ' + COALESCE(''''+@Server+ '''' , 'NULL') 
													+', @DatabaseName = '+ COALESCE(''''+@DatabaseName + '''' , 'NULL');         
		
		EXECUTE  @LogID = [TOOLS].[uspETLLOGInsertProc] @source_object_id= @@PROCID , @LogDescription=@LogDescription;

        DECLARE @RowCountStart AS BIGINT, @TotalRows BIGINT;
        DECLARE @MergeRowInsert INT, @MergeRowUpdate INT, @MergeRowDelete INT;

        SELECT @RowCountStart = COUNT(*)	FROM [Report].[DatabaseObjectColumn];

	SELECT cd.[ServerName]
		,cd.[DatabaseName]
		,cd.[TypeCode]
		,cd.[TypeDescriptionUser]
		,cd.[ObjectSchemaName] AS [TableSchemaName]
		,cd.[ObjectName] AS [TableName]
		,cd.[ColumnName] 
		,COALESCE(cd.[DocumentationDescription], vc.[DocumentationDescription]) AS [DocumentationDescription]
		,cd.[ColumnId] AS [column_id]
		,cd.[datatype] 
		,CASE 
			WHEN cd.[is_identity] = 1 
				THEN ' ' + cd.[Column_Default]
			WHEN cd.[datatype] IN ('numeric' ,'decimal' ) THEN 
			'(' + CAST( cd.[precision] AS VARCHAR(10) )  + ',' + CAST(cd.scale AS VARCHAR(10) ) + ')'
			WHEN cd.[datatype] LIKE '%char%' THEN 
			'(' + CASE 
				WHEN cd.[max_length] = - 1
					THEN 'max'
				WHEN LEFT(cd.[datatype], 1) = 'n'
					THEN CAST(CAST(cd.[max_length] / 2.0 AS INT) AS VARCHAR(10))
				ELSE CAST(cd.[max_length] AS VARCHAR(10))
				END + ')'
			ELSE  '' 
			END 
			AS [DataTypeExtension]
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
		,cd.[is_nullable] 
		,cd.[is_computed] 
		,cd.[is_identity]
		,cd.[is_primary_key]
		,cd.[Column_Default]
		--,CAST(iif(cd.[is_nullable] = 1, 'yes', 'no') AS VARCHAR(3)) AS nulls
		--,CAST(iif(cd.[is_computed] = 1, 'yes', 'no') AS VARCHAR(3)) AS computed
		--,iif(cd.[is_identity] = 1,NULL, cd.[Column_Default]) AS [Column_Default]
		,CAST(iif([is_primary_key] = 1, iif(SUM(CAST([is_primary_key] AS INT)) OVER (
						PARTITION BY cd.[TypeDescriptionUser]
						,cd.[ServerName]
						,cd.[DatabaseName]
						,cd.[ObjectSchemaName]
						,cd.[ObjectName]
						) > 1, 'composite PK', 'yes'), NULL) AS VARCHAR(25)) AS [PKType]
		,od.[ObjectName] AS [FK_NAME]
		,iif(cd.TypeCode = 'V', vc.[SourceTableSchema], od.[ReferencedSchemaName]) AS [ReferencedSchemaName]
		,iif(cd.TypeCode = 'V', vc.[SourceTableName], od.[ReferencedObjectName]) AS [ReferencedObjectName]
		,IIF(cd.TypeCode = 'V', vc.TypeCode, 'U') AS ReferencedTypeCode
		,iif(cd.TypeCode = 'V', vc.[ColumnName], od.[ReferencedColumnName]) AS [ReferencedColumn]
		,iif(cd.TypeCode = 'V', vc.TypeDescriptionUser, 'Table') AS ReferencedTypeDescriptionUser
		,iif(cd.TypeCode = 'V', vc.[SourceTableName] + '.' + vc.[ColumnName], od.ReferencedSchemaName + '.'+ od.[ReferencedObjectName] + '.' + od.[ReferencedColumnName]) AS FKGeneratedName
		--,iif(od.[FK_NAME] IS NOT NULL, 'yes', NULL) AS isFK
		--,iif(cd.TypeCode = 'V', 'Source', 'FK') AS fk_title
		,cd.DocumentationLoadDate
		, CONCAT(		
				 cd.[ServerName]
			,':'	,cd.[DatabaseName]
			,':'	,cd.[TypeCode]
			,':'	,cd.[ObjectSchemaName] 
			,':'	,cd.[ObjectName] 
			,':'	,cd.[ColumnName] 
		
		) AS BusinessKey

	INTO #temp
	FROM [Staging].[vwColumnDoc] cd
	LEFT JOIN [Staging].vwSQLColumnReference od
		ON cd.SERVERNAME = od.SERVERNAME
			AND cd.DatabaseName = od.DatabaseName
			AND cd.[ObjectSchemaName] = od.[SchemaName]
			AND cd.[ObjectName] = od.[ObjectName]
	AND cd.[ColumnName] = od.ColumnName 
	LEFT JOIN [staging].[vwSQLDocViewDefinitionColumnMap] vc
		ON cd.SERVERNAME = vc.SERVERNAME
			AND cd.DatabaseName = vc.DatabaseName
			AND cd.[ObjectSchemaName] = vc.[ViewSchema]
			AND cd.[ObjectName] = vc.[ViewName]
			AND cd.[ColumnId] = vc.[ColumnId]
			AND cd.TypeCode = 'V'
	WHERE cd.[ColumnName] IS NOT NULL
		AND cd.SERVERNAME = @Server
		AND cd.DatabaseName = @DatabaseName;

	SET @LogDetailRows = @@ROWCOUNT;

	SET @LogDetailMessage = 'Get Data From Staging';

	EXECUTE [TOOLS].[uspETLLogDetailInsert] @LOGID = @LOGID
		,@message = @LogDetailMessage 
		,@Starttime = @LogDetailTime OUTPUT
		,@rows = @LogDetailrows
		,@verbose = @PrintLog;
				BEGIN /*Duplicate check*/
			DECLARE @duplicates VARCHAR(MAX);
			WITH CTE
			AS (
				SELECT 			BusinessKey
				FROM #temp 
				GROUP BY 			BusinessKey
				HAVING COUNT(1) > 1
				)
			SELECT @duplicates = SUBSTRING((
						SELECT ', "' + BusinessKey + '"'
						FROM cte s
						ORDER BY s.BusinessKey
						FOR XML PATH('')
						), 3, 200000);

			IF @duplicates IS NOT NULL
			BEGIN
				RAISERROR (
						'Aborting ETL due to duplicate Rows in source :  %s' -- Message text.  
						,16 -- Severity.  
						,1 -- State.  
						,@duplicates
						);
			END;
		END;


	
	/* Merge Statement
	dbo.[sp_generateMerge] @DestinationTable ='[Report].[DatabaseObjectColumn]', @sourcetable = '#temp', @JoinFieldList='BusinessKey'
	,@SCD_Type =1, @delete_if_not_matched =1
	*/
	
		MERGE INTO [report].[DatabaseObjectColumn] AS DST 
		USING #temp AS SRC 
			ON (
				[DST].[BusinessKey] = [SRC].[BusinessKey]
			)
		WHEN NOT MATCHED BY TARGET 
			THEN 
				INSERT ( [ServerName], [DatabaseName], [TableSchemaName], [TableName], [ColumnName], [column_id], [TypeCode], [TypeDescriptionUser], [DocumentationDescription], [datatype], [DataTypeExtension], [length], [collation_name], [is_nullable], [is_identity], [is_computed], [is_primary_key], [Column_Default], [PKType], [FK_NAME], [ReferencedSchemaName], [ReferencedObjectName], [ReferencedTypeCode], [ReferencedColumn], [ReferencedTypeDescriptionUser], [FKGeneratedName], [DocumentationLoadDate], [BusinessKey]) 
				VALUES ( [SRC].[ServerName], [SRC].[DatabaseName], [SRC].[TableSchemaName], [SRC].[TableName], [SRC].[ColumnName], [SRC].[column_id], [SRC].[TypeCode], [SRC].[TypeDescriptionUser], [SRC].[DocumentationDescription], [SRC].[datatype], [SRC].[DataTypeExtension], [SRC].[length], [SRC].[collation_name], [SRC].[is_nullable], [SRC].[is_identity], [SRC].[is_computed], [SRC].[is_primary_key], [SRC].[Column_Default], [SRC].[PKType], [SRC].[FK_NAME], [SRC].[ReferencedSchemaName], [SRC].[ReferencedObjectName], [SRC].[ReferencedTypeCode], [SRC].[ReferencedColumn], [SRC].[ReferencedTypeDescriptionUser], [SRC].[FKGeneratedName], [SRC].[DocumentationLoadDate], [SRC].[BusinessKey]) 
		WHEN MATCHED 
			AND  EXISTS(
				SELECT  [SRC].[ServerName], [SRC].[DatabaseName], [SRC].[TableSchemaName], [SRC].[TableName], [SRC].[ColumnName], [SRC].[column_id], [SRC].[TypeCode], [SRC].[TypeDescriptionUser], [SRC].[DocumentationDescription], [SRC].[datatype], [SRC].[DataTypeExtension], [SRC].[length], [SRC].[collation_name], [SRC].[is_nullable], [SRC].[is_identity], [SRC].[is_computed], [SRC].[is_primary_key], [SRC].[Column_Default], [SRC].[PKType], [SRC].[FK_NAME], [SRC].[ReferencedSchemaName], [SRC].[ReferencedObjectName], [SRC].[ReferencedTypeCode], [SRC].[ReferencedColumn], [SRC].[ReferencedTypeDescriptionUser], [SRC].[FKGeneratedName], [SRC].[DocumentationLoadDate], [SRC].[BusinessKey]
				EXCEPT
				SELECT  [DST].[ServerName], [DST].[DatabaseName], [DST].[TableSchemaName], [DST].[TableName], [DST].[ColumnName], [DST].[column_id], [DST].[TypeCode], [DST].[TypeDescriptionUser], [DST].[DocumentationDescription], [DST].[datatype], [DST].[DataTypeExtension], [DST].[length], [DST].[collation_name], [DST].[is_nullable], [DST].[is_identity], [DST].[is_computed], [DST].[is_primary_key], [DST].[Column_Default], [DST].[PKType], [DST].[FK_NAME], [DST].[ReferencedSchemaName], [DST].[ReferencedObjectName], [DST].[ReferencedTypeCode], [DST].[ReferencedColumn], [DST].[ReferencedTypeDescriptionUser], [DST].[FKGeneratedName], [DST].[DocumentationLoadDate], [DST].[BusinessKey]
			)
			THEN 
				UPDATE  
				SET
					 [DST].[ServerName] = [SRC].[ServerName]
					,[DST].[DatabaseName] = [SRC].[DatabaseName]
					,[DST].[TableSchemaName] = [SRC].[TableSchemaName]
					,[DST].[TableName] = [SRC].[TableName]
					,[DST].[ColumnName] = [SRC].[ColumnName]
					,[DST].[column_id] = [SRC].[column_id]
					,[DST].[TypeCode] = [SRC].[TypeCode]
					,[DST].[TypeDescriptionUser] = [SRC].[TypeDescriptionUser]
					,[DST].[DocumentationDescription] = [SRC].[DocumentationDescription]
					,[DST].[datatype] = [SRC].[datatype]
					,[DST].[DataTypeExtension] = [SRC].[DataTypeExtension]
					,[DST].[length] = [SRC].[length]
					,[DST].[collation_name] = [SRC].[collation_name]
					,[DST].[is_nullable] = [SRC].[is_nullable]
					,[DST].[is_identity] = [SRC].[is_identity]
					,[DST].[is_computed] = [SRC].[is_computed]
					,[DST].[is_primary_key] = [SRC].[is_primary_key]
					,[DST].[Column_Default] = [SRC].[Column_Default]
					,[DST].[PKType] = [SRC].[PKType]
					,[DST].[FK_NAME] = [SRC].[FK_NAME]
					,[DST].[ReferencedSchemaName] = [SRC].[ReferencedSchemaName]
					,[DST].[ReferencedObjectName] = [SRC].[ReferencedObjectName]
					,[DST].[ReferencedTypeCode] = [SRC].[ReferencedTypeCode]
					,[DST].[ReferencedColumn] = [SRC].[ReferencedColumn]
					,[DST].[ReferencedTypeDescriptionUser] = [SRC].[ReferencedTypeDescriptionUser]
					,[DST].[FKGeneratedName] = [SRC].[FKGeneratedName]
					,[DST].[DocumentationLoadDate] = [SRC].[DocumentationLoadDate]
		WHEN NOT MATCHED BY SOURCE
				AND [DST].[ServerName] = @Server
				AND [DST].[DatabaseName] = @DatabaseName
			THEN
				DELETE;

	SELECT @MergeRowUpdate = @@RowCount;
		
	SET @LogDetailRows = @MergeRowUpdate ;

	SET @LogDetailMessage = 'Merge Data';

	EXECUTE [TOOLS].[uspETLLogDetailInsert] @LOGID = @LOGID
		,@message = @LogDetailMessage 
		,@Starttime = @LogDetailTime OUTPUT
		,@rows = @LogDetailrows
		,@verbose = @PrintLog;

		SELECT @TotalRows = COUNT(*)	FROM [Report].[DatabaseObjectColumn];

        SET @MergeRowInsert = @TotalRows - @RowCountStart - @MergeRowUpdate;

        EXECUTE [TOOLS].[uspETLLOGUpdate] @LogID = @LogID, @DataCountInsert = @MergeRowInsert, @DataCountUpdate = @MergeRowUpdate, @DataCountDelete = @MergeRowDelete, @DataCountTotalRows = @TotalRows;

    END TRY  
    BEGIN CATCH       -- Execute error retrieval routine.  
        EXECUTE [TOOLS].[uspRethrowError] @logID = @LogID ;
    END CATCH; 
END;