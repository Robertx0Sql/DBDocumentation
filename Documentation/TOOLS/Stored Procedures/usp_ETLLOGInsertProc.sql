

CREATE PROCEDURE [TOOLS].[usp_ETLLOGInsertProc] 
    @source_object_id INT,
    @starttime DATETIME=NULL,
    @endtime DATETIME = NULL,
    @message NVARCHAR(2048) = NULL,
    @DataCountInsert INT = NULL,
    @DataCountUpdate INT = NULL,
    @DataCountDelete INT = NULL,
	@LogDescription nvarchar(2000)=NULL
AS 
IF @starttime IS NULL SET @starttime  = GETUTCDATE();


DECLARE @printmessage VARCHAR(100), @printtime varchar(25) 
--set @printtime = convert(varchar(25), @starttime,   113 ) 
SET @printmessage = 'EXECUTING ' + OBJECT_schema_NAME(@source_object_id) + '.' + OBJECT_NAME(@source_object_id);
RAISERROR ('%s', 0, 1, @printmessage ) WITH NOWAIT

DECLARE @source NVARCHAR(1024);
SELECT @source = QUOTENAME(object_SCHEMA_NAME(OBJECT_ID)) + '.' + QUOTENAME(OBJECT_NAME(OBJECT_ID))
FROM sys.objects WHERE OBJECT_ID =@source_object_id;

-- TODO: Set parameter values here.
DECLARE   @RC INT;
EXECUTE @RC = [TOOLS].[usp_ETLLOGInsert] 
   @source
  ,@starttime
  ,@endtime
  ,@message
  ,@DataCountInsert
  ,@DataCountUpdate
  ,@DataCountDelete
  ,@LogDescription ;

RETURN @rc;