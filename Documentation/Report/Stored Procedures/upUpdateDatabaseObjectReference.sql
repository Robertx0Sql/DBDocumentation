CREATE PROCEDURE [report].[upUpdateDatabaseObjectReference] (
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

        SELECT @RowCountStart = COUNT(*)	FROM [report].[DatabaseObjectReference] 

	SELECT [ServerName]
			,[DatabaseName]
			,[referencingSchemaName]
			,[referencingEntityName]
			,[referencingTypeCode]
			,[referencedServerName]
			,[referencedDatabaseName]
			,[referencedSchemaName]
			,[referencedEntityName]
			,[referencedTypeCode]
			,[DocumentationDateTime]
		INTO #Temp
		FROM [report].[DatabaseObjectReference]
		WHERE 1 = 0;

		WITH CTE_BASE  AS ( /*need to do ISNULL here to set referenced_server_name / referenced_database_name as sometimes its filled and sometimes NULL */

			SELECT [ServerName],[DatabaseName]
					,ISNULL(referencing_schema_name, '') AS referencing_schema_name
					,ISNULL(referencing_entity_name, '') AS referencing_entity_name
					,ISNULL(referencing_TypeCode, '') AS referencing_TypeCode
					,ISNULL(referenced_server_name, ServerName) AS referenced_server_name
					,ISNULL(referenced_database_name, DatabaseName) AS referenced_database_name
					,ISNULL(referenced_schema_name, '') AS referenced_schema_name
					,ISNULL(referenced_entity_name, '') AS referenced_entity_name
					,ISNULL(referenced_TypeCode, '') AS referenced_TypeCode
					,s.StagingDateTime 
				FROM [Staging].[SQLDocObjectReference] s
				WHERE DatabaseName = @DatabaseName
					AND SERVERNAME = @Server
			)

			, cte_rnk as (
				SELECT 	
					[ServerName],[DatabaseName]
					,referencing_schema_name
					,referencing_entity_name
					,referencing_TypeCode
					,referenced_server_name
					,referenced_database_name
					,referenced_schema_name
					,referenced_entity_name
					,referenced_TypeCode

					,s.StagingDateTime 
					, rnk = ROW_NUMBER() over (PARTITION BY [ServerName],[DatabaseName]
												,referencing_schema_name
												,referencing_entity_name
												,referencing_TypeCode
												,referenced_server_name
												,referenced_database_name
												,referenced_schema_name
												,referenced_entity_name
												,referenced_TypeCode
					ORDER by s.StagingDateTime )
			FROM CTE_BASE as s
		)

		INSERT INTO #Temp (
			[ServerName]
			,[DatabaseName]
			,[referencingSchemaName]
			,[referencingEntityName]
			,[referencingTypeCode]
			,[referencedServerName]
			,[referencedDatabaseName]
			,[referencedSchemaName]
			,[referencedEntityName]
			,[referencedTypeCode]
			,[DocumentationDateTime]
			)
		SELECT ServerName
			,DatabaseName
			,ISNULL(referencing_schema_name, '')
			,ISNULL(referencing_entity_name, '')
			,ISNULL(referencing_TypeCode, '')
			,ISNULL(referenced_server_name, ServerName)
			,ISNULL(referenced_database_name, DatabaseName)
			,ISNULL(referenced_schema_name, '')
			,ISNULL(referenced_entity_name, '')
			,ISNULL(referenced_TypeCode, '')
			,s.StagingDateTime 
		FROM cte_rnk s
		WHERE rnk=1;

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
					SELECT [ServerName],[DatabaseName],[referencingSchemaName],[referencingEntityName],[referencingTypeCode],[referencedServerName],[referencedDatabaseName],[referencedSchemaName],[referencedEntityName],[referencedTypeCode]
					FROM #temp AS SRC
					GROUP BY [ServerName],[DatabaseName],[referencingSchemaName],[referencingEntityName],[referencingTypeCode],[referencedServerName],[referencedDatabaseName],[referencedSchemaName],[referencedEntityName],[referencedTypeCode]
					HAVING COUNT(1) != 1 
				)
			SELECT @duplicates = SUBSTRING((
						SELECT ', "' + [ServerName] + '"' + ', "' + [DatabaseName] + '"' + ', "' + [referencingSchemaName] + '"' + ', "' + [referencingEntityName] + '"' + ', "' + [referencingTypeCode] + '"' + ', "' + [referencedServerName] + '"' + ', "' + [referencedDatabaseName] + '"' + ', "' + [referencedSchemaName] + '"' + ', "' + [referencedEntityName] + '"' + ', "' + [referencedTypeCode] + '"'
						FROM cte s
						
						ORDER BY [ServerName],[DatabaseName],[referencingSchemaName],[referencingEntityName],[referencingTypeCode],[referencedServerName],[referencedDatabaseName],[referencedSchemaName],[referencedEntityName],[referencedTypeCode]
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
dbo.[sp_generateMerge] @DestinationTable = '[report].[DatabaseObjectReference]'
	,@sourcetable = '#temp'
	,@JoinFieldList = 'ServerName,DatabaseName,referencingSchemaName,referencingEntityName,referencingTypeCode,referencedServerName,referencedDatabaseName,referencedSchemaName,referencedEntityName,referencedTypeCode'
	,@SCD_Type = 1
	,@delete_if_not_matched = 1
	,@include_LoadDateClause = 0
	,@ErrorLogProc = NULL
*/
	


		MERGE INTO [report].[DatabaseObjectReference] AS DST 
		USING #temp AS SRC 
			ON (
				[DST].[ServerName] = [SRC].[ServerName]
			AND [DST].[DatabaseName] = [SRC].[DatabaseName]
			AND [DST].[referencingSchemaName] = [SRC].[referencingSchemaName]
			AND [DST].[referencingEntityName] = [SRC].[referencingEntityName]
			AND [DST].[referencingTypeCode] = [SRC].[referencingTypeCode]
			AND [DST].[referencedServerName] = [SRC].[referencedServerName]
			AND [DST].[referencedDatabaseName] = [SRC].[referencedDatabaseName]
			AND [DST].[referencedSchemaName] = [SRC].[referencedSchemaName]
			AND [DST].[referencedEntityName] = [SRC].[referencedEntityName]
			AND [DST].[referencedTypeCode] = [SRC].[referencedTypeCode]
			)
		WHEN NOT MATCHED BY TARGET 
			THEN 
				INSERT ( [ServerName], [DatabaseName], [referencingSchemaName], [referencingEntityName], [referencingTypeCode], [referencedServerName], [referencedDatabaseName], [referencedSchemaName], [referencedEntityName], [referencedTypeCode], [DocumentationDateTime]) 
				VALUES ( [SRC].[ServerName], [SRC].[DatabaseName], [SRC].[referencingSchemaName], [SRC].[referencingEntityName], [SRC].[referencingTypeCode], [SRC].[referencedServerName], [SRC].[referencedDatabaseName], [SRC].[referencedSchemaName], [SRC].[referencedEntityName], [SRC].[referencedTypeCode], [SRC].[DocumentationDateTime]) 
		WHEN MATCHED 
			AND  EXISTS(
				SELECT  [SRC].[ServerName], [SRC].[DatabaseName], [SRC].[referencingSchemaName], [SRC].[referencingEntityName], [SRC].[referencingTypeCode], [SRC].[referencedServerName], [SRC].[referencedDatabaseName], [SRC].[referencedSchemaName], [SRC].[referencedEntityName], [SRC].[referencedTypeCode], [SRC].[DocumentationDateTime]
				EXCEPT
				SELECT  [DST].[ServerName], [DST].[DatabaseName], [DST].[referencingSchemaName], [DST].[referencingEntityName], [DST].[referencingTypeCode], [DST].[referencedServerName], [DST].[referencedDatabaseName], [DST].[referencedSchemaName], [DST].[referencedEntityName], [DST].[referencedTypeCode], [DST].[DocumentationDateTime]
			)
			THEN 
				UPDATE  
				SET
					 [DST].[DocumentationDateTime] = [SRC].[DocumentationDateTime]
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

		SELECT @TotalRows = COUNT(*)	FROM [report].[DatabaseObjectReference];

        SET @MergeRowInsert = @TotalRows - @RowCountStart - @MergeRowUpdate;

        EXECUTE [TOOLS].[uspETLLOGUpdate] @LogID = @LogID, @DataCountInsert = @MergeRowInsert, @DataCountUpdate = @MergeRowUpdate, @DataCountDelete = @MergeRowDelete, @DataCountTotalRows = @TotalRows;

    END TRY  
    BEGIN CATCH       -- Execute error retrieval routine.  
        EXECUTE [TOOLS].[uspRethrowError] @logID = @LogID ;
    END CATCH; 
END;