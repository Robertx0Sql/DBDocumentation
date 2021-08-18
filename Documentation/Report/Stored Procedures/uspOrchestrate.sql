CREATE PROCEDURE [report].[uspOrchestrate] (
	@Server VARCHAR(255) 
	,@DatabaseName VARCHAR(255) 
	,@PrintLog BIT =0
)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON 
		DECLARE @LogID INT; 
		DECLARE @LogDescription NVARCHAR(2000) = 	'@Server = ' + COALESCE(''''+@Server+ '''' , 'NULL') 
													+', @DatabaseName = '+ COALESCE(''''+@DatabaseName + '''' , 'NULL');         
		
		EXECUTE  @LogID = [TOOLS].[uspETLLOGInsertProc] @source_object_id= @@PROCID , @LogDescription=@LogDescription;
		
		BEGIN -- Update Report tables
			--MUST BE DONE First :
			EXECUTE [dbo].[uspUpdateSQLDocAutoMapFK] @Server =@Server,@Database =@DatabaseName--,@PrintLog =@PrintLog;

			--now reports

			EXEC [report].[upUpdateDatabaseObjectDocumentation] @Server =@Server,@DatabaseName =@DatabaseName,@PrintLog =@PrintLog;
			
			EXEC [report].[upUpdateDatabaseObjectColumns] @Server =@Server,@DatabaseName =@DatabaseName,@PrintLog =@PrintLog;

			EXEC [report].[upUpdateDatabaseColumnReference] @Server =@Server,@DatabaseName =@DatabaseName,@PrintLog =@PrintLog;

			EXEC [report].[upUpdateDatabaseObjectReference] @Server =@Server,@DatabaseName =@DatabaseName,@PrintLog =@PrintLog;
			
			EXEC [report].[upUpdateDatabaseObjectCode] @Server =@Server,@DatabaseName =@DatabaseName,@PrintLog =@PrintLog;
		 END 

		 EXECUTE [TOOLS].[uspETLLOGUpdate] @LogID = @LogID

	--COMMIT; 
    END TRY  
    BEGIN CATCH       -- Execute error retrieval routine.  
        IF @@TRANCOUNT >0 
		ROLLBACK;
		EXECUTE [TOOLS].[uspRethrowError] @LogID = @LogID;
    END CATCH; 
END;