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
		
		EXECUTE  @LogID = [TOOLS].[usp_ETLLOGInsertProc] @source_object_id= @@PROCID , @LogDescription=@LogDescription;
		
		BEGIN -- Update Report tables
			--MUST BE DONE First :
			EXECUTE [dbo].[uspUpdateSQLDocAutoMapFK] @Server =@Server,@Database =@DatabaseName--,@PrintLog =@PrintLog;

			
			EXEC [report].[upUpdateDatabaseObjectDocumentation] @Server =@Server,@DatabaseName =@DatabaseName,@PrintLog =@PrintLog;

		 END 

		 EXECUTE [TOOLS].[usp_ETLLOGUpdate] @LogID = @LogID

	--COMMIT; 
    END TRY  
    BEGIN CATCH       -- Execute error retrieval routine.  
        IF @@TRANCOUNT >0 
		ROLLBACK;
		EXECUTE [TOOLS].[csp_RethrowError] ;
    END CATCH; 
END;