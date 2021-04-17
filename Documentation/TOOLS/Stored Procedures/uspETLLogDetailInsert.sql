
CREATE PROCEDURE [TOOLS].[uspETLLogDetailInsert] (
	@LOGID INT
	,@message NVARCHAR(2048)
	,@Starttime DATETIME OUTPUT 
	,@rows BIGINT =0
	,@verbose BIT =0)
AS
BEGIN
	DECLARE @endtime DATETIME = GETUTCDATE();
	DECLARE @printmessage VARCHAR(100);
	
	INSERT INTO [TOOLS].[ETLLogDetail] ([LogId], [Starttime], [endtime], [message], [rows])
	SELECT @LOGID, @Starttime, @endtime, @message, @rows;

	IF @verbose =1
	BEGIN
		SET @printmessage = @message + ' ' + CONVERT(VARCHAR(25), @endtime, 126) + ' took ' + CAST(DATEDIFF(SECOND, @Starttime, @endtime) AS VARCHAR(10)) + ' seconds';
		RAISERROR ('%s', 0, 1, @printmessage ) WITH NOWAIT;
	END;

	SET @Starttime = @endtime;
END;