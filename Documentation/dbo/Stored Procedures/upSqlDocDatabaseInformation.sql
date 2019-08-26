CREATE PROCEDURE upSqlDocDatabaseInformation (
	@Server VARCHAR(255) = NULL
	,@DatabaseName VARCHAR(255) = NULL
	)
AS
BEGIN
	SELECT ServerName
		,DatabaseName
		,T.name
		,t.value
	FROM staging.DatabaseInformation db
	CROSS APPLY (
		VALUES
			--[noformat]
(stagingId,recovery_model_desc, 'recovery model')
,(stagingId,snapshot_isolation_state_desc ,'snapshot isolation state')
,(stagingId,convert(varchar(100),collation_name), 'collation name')
,(stagingId,convert(varchar(100),compatibility_level) , 'compatibility level')
,(stagingId,convert(varchar(100), create_date  ,120) , 'create date')
,(stagingId,IIF(is_auto_close_on=1,'yes', 'no'),'auto close')
,(stagingId,IIF(is_auto_shrink_on=1,'yes', 'no'),'auto shrink')
,(stagingId,IIF(is_in_standby=1,'yes', 'no') ,'in standby')
,(stagingId,IIF(is_ansi_null_default_on=1,'yes', 'no') ,'ansi null default on')
,(stagingId,IIF(is_ansi_nulls_on=1,'yes', 'no') ,'ansi nulls on')
,(stagingId,IIF(is_ansi_padding_on=1,'yes', 'no') ,'ansi padding on')
,(stagingId,IIF(is_ansi_warnings_on=1,'yes', 'no') ,'ansi warnings on')
,(stagingId,IIF(is_arithabort_on=1,'yes', 'no'),'arithmetic abort')
,(stagingId,IIF(is_auto_create_stats_on=1,'yes', 'no'),'auto create statistics')
,(stagingId,IIF(is_auto_update_stats_on=1,'yes', 'no'),'auto update statistics')
,(stagingId,IIF(is_cursor_close_on_commit_on=1,'yes', 'no'),'close cursors on commit')
,(stagingId,IIF(is_fulltext_enabled =1,'yes', 'no'),'full text')
,(stagingId,IIF(is_local_cursor_default=1,'yes', 'no') ,'local cursors default')
,(stagingId,IIF(is_concat_null_yields_null_on=1,'yes', 'no') ,'null concat')
,(stagingId,IIF(is_numeric_roundabort_on=1,'yes', 'no') ,'numeric round abort')
,(stagingId,IIF(is_quoted_identifier_on=1,'yes', 'no') ,'quoted identifiers')
,(stagingId,IIF(is_recursive_triggers_on =1,'yes', 'no'),'recursive triggers')
--,IIF(is_published=1,'yes', 'no')  ,'published')
--,IIF(is_subscribed=1,'yes', 'no')  ,'subscribed
--,IIF(is_sync_with_backup=1,'yes', 'no')  ,'sync_with_backup

			--[/noformat]
		) AS t(stagingId, value, [name])
	WHERE db.stagingId = T.stagingId
		AND DatabaseName = @DatabaseName
		AND ServerName = @Server
END
