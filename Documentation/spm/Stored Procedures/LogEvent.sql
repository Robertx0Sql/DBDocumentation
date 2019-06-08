CREATE PROCEDURE spm.LogEvent
	@logTime datetime,
	@thread nvarchar(10),
	@logLevel nvarchar(10),
	@logger nvarchar(255),
	@logMessage nvarchar(4000)
AS
BEGIN
	/*
	 * Stored proc to write logging information from the SSAS Partition Manager.
	 * This stored proc is only called when the ADONetAppender_SqlServer appender is enabled in the .config file
     *
	 * Part of the SSAS Partition Manager sample code which can be downloaded from https://SsasPartitionManager.codeplex.com/
	 * 
	 * Written by Dr. John Tunnicliffe, independent business intelligence consultant
	 * Available for consultancy assignments and speaking engagements
     * 	
	 * eMail: john@decision-analytics.co.uk 
	 * http://www.decision-analytics.co.uk/
	 * http://www.sqlbits.com/Speakers/Dr_John_Tunnicliffe
	 * https://www.linkedin.com/in/drjohntunnicliffe
	 */
	 print''
--	INSERT INTO spm.EventLog (LogTime, Thread, LogLevel, Logger, LogMessage) VALUES (@logTime, @thread, @logLevel, @logger, @logMessage);
END

