CREATE PROCEDURE [report].[upUpdateDatabaseObjectCode] (
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

        SELECT @RowCountStart = COUNT(*)	FROM [report].[DatabaseObjectCode] 

		SELECT *
		INTO #Temp
		FROM [report].[DatabaseObjectCode]
		WHERE 1 = 0

		INSERT INTO #Temp (
			ServerName
			,DatabaseName
			,ObjectSchemaName
			,ObjectName
			,TypeCode
			,ObjectCode
			,DocumentationDateTime
			)
			SELECT oc.ServerName
				,oc.DatabaseName
				,oc.[SchemaName]
				,oc.[ObjectName]
				,ot.TypeCode
				,oc.Code
				,oc.StagingDateTime
			FROM [Staging].[ObjectCode] oc
			INNER JOIN [dbo].[vwObjectType] ot 
				ON ot.SMOObjectType = oc.SMOObjectType
			WHERE oc.SERVERNAME = @Server
				AND oc.DatabaseName = @DatabaseName
				and oc.[SchemaName] is not null
				and oc.[ObjectName] is not null;
		
	SET @LogDetailRows = @@ROWCOUNT;

	SET @LogDetailMessage = 'Get Data From Staging';

	EXECUTE [TOOLS].[uspETLLogDetailInsert] @LOGID = @LOGID
		,@message = @LogDetailMessage 
		,@Starttime = @LogDetailTime OUTPUT
		,@rows = @LogDetailrows
		,@verbose = @PrintLog;

	CREATE INDEX IX_Temp_DatabaseObjectCode ON #temp(
			[ServerName]
			,[DatabaseName]
			,[ObjectSchemaName]
			,[ObjectName]
			,[TypeCode]
			);

		BEGIN /*Duplicate check*/
			DECLARE @duplicates VARCHAR(MAX);

			WITH CTE
			AS (
				SELECT [ServerName]
					,[DatabaseName]
					,[ObjectSchemaName]
					,[ObjectName]
					,[TypeCode]
				FROM #temp
				GROUP BY [ServerName]
					,[DatabaseName]
					,[ObjectSchemaName]
					,[ObjectName]
					,[TypeCode]
				HAVING COUNT(1) > 1
				)
			SELECT @duplicates = SUBSTRING((
						SELECT ', "' + [ServerName] + '"' + ', "' + [DatabaseName] + '"' + ', "' + [ObjectSchemaName] + '"' + ', "' + [ObjectName] + '"' + ', "' + [TypeCode] + '"' 
						FROM cte s
						ORDER BY [ServerName]
							,[DatabaseName]
							,[ObjectSchemaName]
							,[ObjectName]
							,[TypeCode]
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
dbo.[sp_generateMerge] @DestinationTable = '[report].[DatabaseObjectCode]'
	,@sourcetable = '#temp'
	,@JoinFieldList = 'ServerName,DatabaseName,ObjectSchemaName,ObjectName,TypeCode'
	,@SCD_Type = 1
	,@delete_if_not_matched = 1
	,@include_LoadDateClause = 0
	,@ErrorLogProc = NULL
*/
	
		MERGE INTO [report].[DatabaseObjectCode] AS DST 
		USING #temp AS SRC 
			ON (
				[DST].[ServerName] = [SRC].[ServerName]
			AND [DST].[DatabaseName] = [SRC].[DatabaseName]
			AND [DST].[ObjectSchemaName] = [SRC].[ObjectSchemaName]
			AND [DST].[ObjectName] = [SRC].[ObjectName]
			AND [DST].[TypeCode] = [SRC].[TypeCode]
			)
		WHEN NOT MATCHED BY TARGET 
			THEN 
				INSERT ( [ServerName], [DatabaseName], [ObjectSchemaName], [ObjectName], [TypeCode], [ObjectCode], [DocumentationDateTime]) 
				VALUES ( [SRC].[ServerName], [SRC].[DatabaseName], [SRC].[ObjectSchemaName], [SRC].[ObjectName], [SRC].[TypeCode], [SRC].[ObjectCode], [SRC].[DocumentationDateTime]) 
		WHEN MATCHED 
			AND  EXISTS(
				SELECT  [SRC].[ServerName], [SRC].[DatabaseName], [SRC].[ObjectSchemaName], [SRC].[ObjectName], [SRC].[TypeCode], [SRC].[ObjectCode], [SRC].[DocumentationDateTime]
				EXCEPT
				SELECT  [DST].[ServerName], [DST].[DatabaseName], [DST].[ObjectSchemaName], [DST].[ObjectName], [DST].[TypeCode], [DST].[ObjectCode], [DST].[DocumentationDateTime]
			)
			THEN 
				UPDATE  
				SET
					 [DST].[ObjectCode] = [SRC].[ObjectCode]
					,[DST].[DocumentationDateTime] = [SRC].[DocumentationDateTime]
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

		SELECT @TotalRows = COUNT(*)	FROM [report].[DatabaseObjectCode];

        SET @MergeRowInsert = @TotalRows - @RowCountStart - @MergeRowUpdate;

        EXECUTE [TOOLS].[uspETLLOGUpdate] @LogID = @LogID, @DataCountInsert = @MergeRowInsert, @DataCountUpdate = @MergeRowUpdate, @DataCountDelete = @MergeRowDelete, @DataCountTotalRows = @TotalRows;

    END TRY  
    BEGIN CATCH       -- Execute error retrieval routine.  
        EXECUTE [TOOLS].[uspRethrowError] @logID = @LogID ;
    END CATCH; 
END;