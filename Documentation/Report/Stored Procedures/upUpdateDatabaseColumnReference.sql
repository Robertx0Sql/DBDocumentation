CREATE PROCEDURE [report].[upUpdateDatabaseColumnReference] (
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

        SELECT @RowCountStart = COUNT(*)	FROM [report].[DatabaseColumnReference] 

		SELECT *
		INTO #Temp
		FROM [report].[DatabaseColumnReference]
		WHERE 1 = 0;

		INSERT INTO #Temp (
			[ServerName]
			,[DatabaseName]
			,[SchemaName]
			,[ObjectName]
			,[TypeCode]
			,[ColumnName]
			,[ColumnId]
			,[FK_NAME]
			,[ReferencedSchemaName]
			,[ReferencedObjectName]
			,[ReferencedObjectType]
			,[ReferencedColumnName]
			,[LoadDateTime]
			)
		SELECT ServerName
			,DatabaseName
			,SchemaName
			,ObjectName
			,ObjectType AS TypeCode
			,ColumnName
			,ColumnId
			,FK_NAME
			,ReferencedSchemaName
			,ReferencedObjectName
			,ReferencedObjectType
			,ReferencedColumnName
			,LoadDateTime
		FROM [Staging].vwSQLColumnReference
			WHERE DatabaseName = @DatabaseName
			AND SERVERNAME = @Server
		
	SET @LogDetailRows = @@ROWCOUNT;

	SET @LogDetailMessage = 'Get Data From Staging';

	EXECUTE [TOOLS].[uspETLLogDetailInsert] @LOGID = @LOGID
		,@message = @LogDetailMessage 
		,@Starttime = @LogDetailTime OUTPUT
		,@rows = @LogDetailrows
		,@verbose = @PrintLog;

	CREATE INDEX IX_Temp_DatabaseColumnReference ON #temp(
			[ServerName]
			,[DatabaseName]
			,[SchemaName]
			,[ObjectName]
			,[TypeCode]
			,ColumnName
			);

		BEGIN /*Duplicate check*/
			DECLARE @duplicates VARCHAR(MAX);

			WITH CTE
			AS (
				SELECT [ServerName]
					,[DatabaseName]
					,[SchemaName]
					,[ObjectName]
					,[TypeCode]
					,[ColumnName]
				FROM #temp
				GROUP BY [ServerName]
					,[DatabaseName]
					,[SchemaName]
					,[ObjectName]
					,[TypeCode]
					,[ColumnName]
				HAVING COUNT(1) > 1
				)
			SELECT @duplicates = SUBSTRING((
						SELECT ', "' + [ServerName] + '"' + ', "' + [DatabaseName] + '"' + ', "' + [SchemaName] + '"' + ', "' + [ObjectName] + '"' + ', "' + [TypeCode] + '"' + ', "' + [ColumnName] + '"'
						FROM cte s
						ORDER BY [ServerName]
							,[DatabaseName]
							,[SchemaName]
							,[ObjectName]
							,[TypeCode]
							,[ColumnName]
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


/*
dbo.[sp_generateMerge] @DestinationTable = '[report].[DatabaseColumnReference]'
	,@sourcetable = '#temp'
	,@JoinFieldList = 'ServerName,DatabaseName,SchemaName,ObjectName,TypeCode,ColumnName'
	,@SCD_Type = 1
	,@delete_if_not_matched = 1
	,@include_LoadDateClause = 0
	,@ErrorLogProc = NULL
*/
	
		MERGE INTO [report].[DatabaseColumnReference] AS DST 
		USING #temp AS SRC 
			ON (
				[DST].[ServerName] = [SRC].[ServerName]
			AND [DST].[DatabaseName] = [SRC].[DatabaseName]
			AND [DST].[SchemaName] = [SRC].[SchemaName]
			AND [DST].[ObjectName] = [SRC].[ObjectName]
			AND [DST].[TypeCode] = [SRC].[TypeCode]
			AND [DST].[ColumnName] = [SRC].[ColumnName]
			)
		WHEN NOT MATCHED BY TARGET 
			THEN 
				INSERT ( [ServerName], [DatabaseName], [SchemaName], [ObjectName], [TypeCode], [ColumnName], [ColumnId], [FK_NAME], [ReferencedSchemaName], [ReferencedObjectName], [ReferencedObjectType], [ReferencedColumnName], [LoadDateTime]) 
				VALUES ( [SRC].[ServerName], [SRC].[DatabaseName], [SRC].[SchemaName], [SRC].[ObjectName], [SRC].[TypeCode], [SRC].[ColumnName], [SRC].[ColumnId], [SRC].[FK_NAME], [SRC].[ReferencedSchemaName], [SRC].[ReferencedObjectName], [SRC].[ReferencedObjectType], [SRC].[ReferencedColumnName], [SRC].[LoadDateTime]) 
		WHEN MATCHED 
			AND  EXISTS(
				SELECT  [SRC].[ServerName], [SRC].[DatabaseName], [SRC].[SchemaName], [SRC].[ObjectName], [SRC].[TypeCode], [SRC].[ColumnName], [SRC].[ColumnId], [SRC].[FK_NAME], [SRC].[ReferencedSchemaName], [SRC].[ReferencedObjectName], [SRC].[ReferencedObjectType], [SRC].[ReferencedColumnName], [SRC].[LoadDateTime]
				EXCEPT
				SELECT  [DST].[ServerName], [DST].[DatabaseName], [DST].[SchemaName], [DST].[ObjectName], [DST].[TypeCode], [DST].[ColumnName], [DST].[ColumnId], [DST].[FK_NAME], [DST].[ReferencedSchemaName], [DST].[ReferencedObjectName], [DST].[ReferencedObjectType], [DST].[ReferencedColumnName], [DST].[LoadDateTime]
			)
			THEN 
				UPDATE  
				SET
					 [DST].[ColumnId] = [SRC].[ColumnId]
					,[DST].[FK_NAME] = [SRC].[FK_NAME]
					,[DST].[ReferencedSchemaName] = [SRC].[ReferencedSchemaName]
					,[DST].[ReferencedObjectName] = [SRC].[ReferencedObjectName]
					,[DST].[ReferencedObjectType] = [SRC].[ReferencedObjectType]
					,[DST].[ReferencedColumnName] = [SRC].[ReferencedColumnName]
					,[DST].[LoadDateTime] = [SRC].[LoadDateTime]
		WHEN NOT MATCHED BY SOURCE
				AND DST.DatabaseName = @DatabaseName
				AND DST.SERVERNAME = @Server
			THEN
				DELETE		;
    
	SELECT @MergeRowUpdate = @@RowCount;
		
	SET @LogDetailRows = @MergeRowUpdate ;

	SET @LogDetailMessage = 'Merge Data';

	EXECUTE [TOOLS].[uspETLLogDetailInsert] @LOGID = @LOGID
		,@message = @LogDetailMessage 
		,@Starttime = @LogDetailTime OUTPUT
		,@rows = @LogDetailrows
		,@verbose = @PrintLog;

		SELECT @TotalRows = COUNT(*)	FROM [report].[DatabaseColumnReference];

        SET @MergeRowInsert = @TotalRows - @RowCountStart - @MergeRowUpdate;

        EXECUTE [TOOLS].[uspETLLOGUpdate] @LogID = @LogID, @DataCountInsert = @MergeRowInsert, @DataCountUpdate = @MergeRowUpdate, @DataCountDelete = @MergeRowDelete, @DataCountTotalRows = @TotalRows;

    END TRY  
    BEGIN CATCH       -- Execute error retrieval routine.  
        EXECUTE [TOOLS].[uspRethrowError] @logID = @LogID ;
    END CATCH; 
END;