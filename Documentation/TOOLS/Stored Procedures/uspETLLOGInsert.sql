
CREATE PROCEDURE [TOOLS].[uspETLLOGInsert] 
    @source NVARCHAR(1024),
    @starttime DATETIME,
    @endtime DATETIME = NULL,
    @message NVARCHAR(2048) = NULL,
    @DataCountInsert INT = NULL,
    @DataCountUpdate INT = NULL,
    @DataCountDelete INT = NULL,
	@LogDescription nvarchar(2000)=NULL
AS 
BEGIN
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;  
	DECLARE   @LOGID INT;

	BEGIN TRANSACTION;
	
	INSERT INTO [TOOLS].[ETLLOG] ([source], [starttime], [endtime], [message], [DataCountInsert], [DataCountUpdate], [DataCountDelete],LogDescription)
	SELECT @source, @starttime, @endtime, @message, @DataCountInsert, @DataCountUpdate, @DataCountDelete,@LogDescription;
	SET @LOGID = SCOPE_IDENTITY();
               
	COMMIT;
	
	RETURN @LOGID;
END