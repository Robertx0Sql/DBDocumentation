
CREATE PROCEDURE [TOOLS].[uspRethrowError]
(@pStepName VARCHAR (100)=NULL
, @LogID INT = NULL)
AS
BEGIN
	IF NULLIF(@pStepName, '') IS NULL
		SET @pStepName = '(Unspecified)';

	-- Return if there is no error information to retrieve.
	IF ERROR_NUMBER() IS NULL
		RETURN;

	DECLARE	@vErrorMessage    NVARCHAR(4000),
		@vErrorNumber     INT,
		@vErrorSeverity   INT,
		@vErrorState      INT,
		@vErrorLine       INT,
		@vErrorProcedure  NVARCHAR(126);

	-- Assign variables to error-handling functions that 
	-- capture information for RAISERROR.
	SELECT	@vErrorNumber = ERROR_NUMBER(),
		@vErrorSeverity = ERROR_SEVERITY(),
		@vErrorState = ERROR_STATE(),
		@vErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-'),
		@vErrorLine = ERROR_LINE(),
		@vErrorMessage = ERROR_MESSAGE();

	
		IF (@LogID IS NOT NULL) 
		BEGIN 
		   UPDATE [TOOLS].[ETLLOG]
		   SET [message] = @vErrorMessage , endtime= GETUTCDATE()
		   WHERE LogID  = @LogID; 
		END;
	-- Building the message string that will contain original
	-- error information.
	SELECT @vErrorMessage = 
	N'Error %d, Level %d, State %d, Procedure %s, Step ''%s'', Line %d, ' + 
		'Message: '+ @vErrorMessage;

	-- Raise an error: msg_str parameter of RAISERROR will contain
	-- the original error information.
	RAISERROR
	(
	@vErrorMessage, 
	@vErrorSeverity, 
	1,               
	@vErrorNumber,    -- parameter: original error number.
	@vErrorSeverity,  -- parameter: original error severity.
	@vErrorState,     -- parameter: original error state.
	@vErrorProcedure, -- parameter: original error procedure name.
	@pStepName,
	@vErrorLine       -- parameter: original error line number.
	);
END