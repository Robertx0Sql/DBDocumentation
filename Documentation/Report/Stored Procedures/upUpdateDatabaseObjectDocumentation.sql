
CREATE PROCEDURE [report].[upUpdateDatabaseObjectDocumentation] (
	@Server VARCHAR(255) = NULL
	,@DatabaseName VARCHAR(255) = NULL
	,@PrintLog Bit =0)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        DECLARE @LogID INT; 
		DECLARE @LogDetailMessage VARCHAR(100)
			,@LogDetailTime DATETIME = GETUTCDATE();
		DECLARE @LogDetailRows BIGINT;

		DECLARE @LogDescription NVARCHAR(2000) = 	'@Server = ' + COALESCE(''''+@Server+ '''' , 'NULL') 
													+', @DatabaseName = '+ COALESCE(''''+@DatabaseName + '''' , 'NULL')         
		
		EXECUTE  @LogID = [TOOLS].[usp_ETLLOGInsertProc] @source_object_id= @@PROCID , @LogDescription=@LogDescription;

        DECLARE @RowCountStart AS BIGINT, @TotalRows BIGINT;
        DECLARE @MergeRowInsert INT, @MergeRowUpdate INT, @MergeRowDelete INT;

        SELECT @RowCountStart = COUNT(*)	FROM [Report].[DatabaseObjectDocumentation];


		SELECT [ServerName]
			,[DatabaseName]
			,[TypeGroup]
			,[TypeCode]
			,[TypeDescriptionUser]
			,[TypeDescriptionSQL]
			,[SchemaName]
			,[ObjectName]
			,[DocumentationDescription]
			,[TypeGroupOrder]
			,[TypeOrder]
			,[TypeCount]
			,[DocumentationLoadDate]
			,[QualifiedFullName]
			,[ParentObjectName]
			,[ParentSchemaName]
			,[ParentTypeCode]
			,[ParentObjectType]
			,[fields]
			,[Definition]
			,[UserModeFlag]
			,[CodeFlag]
			,[StagingId]
			,[parentStagingId]
			, CAST(NULL AS NVARCHAR(1000)) AS  BusinessKey
		INTO #temp
		FROM [Report].[DatabaseObjectDocumentation]
		WHERE 1 = 0;

		WITH CTE
		AS (
			SELECT d.[ServerName]
				,d.[DatabaseName]
				,t.TypeGroup
				,RTRIM(d.[objectType]) AS TypeCode
				,t.TypeDescriptionUser
				,t.TypeDescriptionSQL
				,d.[SchemaName]
				,d.[ObjectName]
				,d.[DocumentationDescription]
				,t.TypeGroupOrder
				,t.TypeOrder
				,t.TypeCount
				,d.StagingDateTime AS DocumentationLoadDate
				,QUOTENAME(d.[SchemaName]) + '.' + QUOTENAME(d.[ObjectName]) AS QualifiedFullName
				,d.ParentObjectName
				,d.ParentSchemaName
				,RTRIM(pd.[ObjectType]) AS ParentTypeCode
				,IIF(RTRIM(d.[objectType]) IN ('PK', 'D', 'UQ', 'C', 'F', 'INDEX'), 'U', RTRIM(d.[objectType])) AS ParentObjectType
				,d.fields
				,d.DEFINITION
				,t.UserModeFlag
				,t.CodeFlag
				/*Debug*/
				,d.StagingId
				,pd.Stagingid AS parentStagingId
			FROM [Staging].[ObjectDocumentation] d
			LEFT JOIN dbo.vwObjectType t
				ON t.TypeCode = RTRIM(d.[objectType])
			LEFT JOIN [Staging].[ObjectDocumentation] pd
				ON pd.SERVERNAME = d.SERVERNAME
					AND pd.DatabaseName = d.DatabaseName
					AND pd.ObjectName = d.ParentObjectName
					AND pd.SchemaName = d.ParentSchemaName
		WHERE d.SchemaName	IS NOT NULL	
			AND d.ObjectName IS NOT NULL
			AND t.TypeCode IS NOT NULL
			)

		INSERT INTO #temp (
			[ServerName]
			,[DatabaseName]
			,[TypeGroup]
			,[TypeCode]
			,[TypeDescriptionUser]
			,[TypeDescriptionSQL]
			,[SchemaName]
			,[ObjectName]
			,[DocumentationDescription]
			,[TypeGroupOrder]
			,[TypeOrder]
			,[TypeCount]
			,[DocumentationLoadDate]
			,[QualifiedFullName]
			,[ParentObjectName]
			,[ParentSchemaName]
			,[ParentTypeCode]
			,[ParentObjectType]
			,[fields]
			,[Definition]
			,[UserModeFlag]
			,[CodeFlag]
			,[StagingId]
			,[parentStagingId]
			,BusinessKey
			)
		SELECT [ServerName]
			,[DatabaseName]
			,[TypeGroup]
			,[TypeCode]
			,[TypeDescriptionUser]
			,[TypeDescriptionSQL]
			,[SchemaName]
			,[ObjectName]
			,[DocumentationDescription]
			,[TypeGroupOrder]
			,[TypeOrder]
			,[TypeCount]
			,[DocumentationLoadDate]
			,[QualifiedFullName]
			,[ParentObjectName]
			,[ParentSchemaName]
			,[ParentTypeCode]
			,[ParentObjectType]
			,[fields]
			,[Definition]
			,[UserModeFlag]
			,[CodeFlag]
			,[StagingId]
			,[parentStagingId]
			
			, CONCAT(			[ServerName]
				,':'	,[DatabaseName]
				,':'	,[SchemaName]
				,':'	,[ObjectName]
				,':'	,[TypeCode]
			) AS BusinessKey
		FROM CTE
		WHERE DatabaseName = @DatabaseName
			AND SERVERNAME = @Server;
		
	SET @LogDetailRows = @@ROWCOUNT;

	SET @LogDetailMessage = 'Get Data From Staging';

	EXECUTE [TOOLS].[usp_ETLLogDetailInsert] @LOGID = @LOGID
		,@message = @LogDetailMessage 
		,@Starttime = @LogDetailTime OUTPUT
		,@rows = @LogDetailrows
		,@verbose = @PrintLog;

	CREATE INDEX IX_Temp_DatabaseObjectDocumentation  ON #temp(
				[ServerName]
			,[DatabaseName]
			,[SchemaName]
			,[ObjectName]
			,[TypeCode]
			);

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

		MERGE INTO [Report].[DatabaseObjectDocumentation] AS DST 
		USING #Temp AS SRC 
			ON (
				DST.[ServerName] = SRC.[ServerName]
				AND DST.[DatabaseName] = SRC.[DatabaseName]
				AND DST.[SchemaName] = SRC.[SchemaName]
				AND DST.[ObjectName] = SRC.[ObjectName]
				AND DST.[TypeCode] = SRC.[TypeCode]
			)
		WHEN NOT MATCHED BY TARGET 
			THEN 
				INSERT ( [ServerName], [DatabaseName], [TypeGroup], [TypeCode], [TypeDescriptionUser], [TypeDescriptionSQL], [SchemaName], [ObjectName], [DocumentationDescription], [TypeGroupOrder], [TypeOrder], [TypeCount], [DocumentationLoadDate], [QualifiedFullName], [ParentObjectName], [ParentSchemaName], [ParentTypeCode], [ParentObjectType], [fields], [Definition], [UserModeFlag], [CodeFlag], [StagingId], [parentStagingId]) 
				VALUES ( SRC.[ServerName], SRC.[DatabaseName], SRC.[TypeGroup], SRC.[TypeCode], SRC.[TypeDescriptionUser], SRC.[TypeDescriptionSQL], SRC.[SchemaName], SRC.[ObjectName], SRC.[DocumentationDescription], SRC.[TypeGroupOrder], SRC.[TypeOrder], SRC.[TypeCount], SRC.[DocumentationLoadDate], SRC.[QualifiedFullName], SRC.[ParentObjectName], SRC.[ParentSchemaName], SRC.[ParentTypeCode], SRC.[ParentObjectType], SRC.[fields], SRC.[Definition], SRC.[UserModeFlag], SRC.[CodeFlag], SRC.[StagingId], SRC.[parentStagingId]) 
		WHEN MATCHED 
			AND  EXISTS(
				SELECT  SRC.[ServerName], SRC.[DatabaseName], SRC.[TypeGroup], SRC.[TypeCode], SRC.[TypeDescriptionUser], SRC.[TypeDescriptionSQL], SRC.[SchemaName], SRC.[ObjectName], SRC.[DocumentationDescription], SRC.[TypeGroupOrder], SRC.[TypeOrder], SRC.[TypeCount], SRC.[DocumentationLoadDate], SRC.[QualifiedFullName], SRC.[ParentObjectName], SRC.[ParentSchemaName], SRC.[ParentTypeCode], SRC.[ParentObjectType], SRC.[fields], SRC.[Definition], SRC.[UserModeFlag], SRC.[CodeFlag], SRC.[StagingId], SRC.[parentStagingId]
				EXCEPT
				SELECT  DST.[ServerName], DST.[DatabaseName], DST.[TypeGroup], DST.[TypeCode], DST.[TypeDescriptionUser], DST.[TypeDescriptionSQL], DST.[SchemaName], DST.[ObjectName], DST.[DocumentationDescription], DST.[TypeGroupOrder], DST.[TypeOrder], DST.[TypeCount], DST.[DocumentationLoadDate], DST.[QualifiedFullName], DST.[ParentObjectName], DST.[ParentSchemaName], DST.[ParentTypeCode], DST.[ParentObjectType], DST.[fields], DST.[Definition], DST.[UserModeFlag], DST.[CodeFlag], DST.[StagingId], DST.[parentStagingId]
			)
			THEN 
				UPDATE  
				SET
					 DST.[ServerName] = SRC.[ServerName]
					,DST.[DatabaseName] = SRC.[DatabaseName]
					,DST.[TypeGroup] = SRC.[TypeGroup]
					,DST.[TypeCode] = SRC.[TypeCode]
					,DST.[TypeDescriptionUser] = SRC.[TypeDescriptionUser]
					,DST.[TypeDescriptionSQL] = SRC.[TypeDescriptionSQL]
					,DST.[SchemaName] = SRC.[SchemaName]
					,DST.[ObjectName] = SRC.[ObjectName]
					,DST.[DocumentationDescription] = SRC.[DocumentationDescription]
					,DST.[TypeGroupOrder] = SRC.[TypeGroupOrder]
					,DST.[TypeOrder] = SRC.[TypeOrder]
					,DST.[TypeCount] = SRC.[TypeCount]
					,DST.[DocumentationLoadDate] = SRC.[DocumentationLoadDate]
					,DST.[QualifiedFullName] = SRC.[QualifiedFullName]
					,DST.[ParentObjectName] = SRC.[ParentObjectName]
					,DST.[ParentSchemaName] = SRC.[ParentSchemaName]
					,DST.[ParentTypeCode] = SRC.[ParentTypeCode]
					,DST.[ParentObjectType] = SRC.[ParentObjectType]
					,DST.[fields] = SRC.[fields]
					,DST.[Definition] = SRC.[Definition]
					,DST.[UserModeFlag] = SRC.[UserModeFlag]
					,DST.[CodeFlag] = SRC.[CodeFlag]
					,DST.[StagingId] = SRC.[StagingId]
					,DST.[parentStagingId] = SRC.[parentStagingId]
					
		WHEN NOT MATCHED BY SOURCE
				AND DST.DatabaseName = @DatabaseName
				AND DST.SERVERNAME = @Server
			THEN
				DELETE		;
	    SELECT @MergeRowUpdate = @@RowCount;
		
	SET @LogDetailRows = @MergeRowUpdate ;

	SET @LogDetailMessage = 'Merge Data';

	EXECUTE [TOOLS].[usp_ETLLogDetailInsert] @LOGID = @LOGID
		,@message = @LogDetailMessage 
		,@Starttime = @LogDetailTime OUTPUT
		,@rows = @LogDetailrows
		,@verbose = @PrintLog;

		SELECT @TotalRows = COUNT(*)	FROM [Report].[DatabaseObjectDocumentation];

        SET @MergeRowInsert = @TotalRows - @RowCountStart - @MergeRowUpdate;

        EXECUTE [TOOLS].[usp_ETLLOGUpdate] @LogID = @LogID, @DataCountInsert = @MergeRowInsert, @DataCountUpdate = @MergeRowUpdate, @DataCountDelete = @MergeRowDelete, @DataCountTotalRows = @TotalRows;

    END TRY  
    BEGIN CATCH       -- Execute error retrieval routine.  
        EXECUTE [TOOLS].[csp_RethrowError] @logID = @LogID ;
    END CATCH; 
END;