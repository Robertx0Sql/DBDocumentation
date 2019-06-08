CREATE PROCEDURE [dbo].[upSqlDocDatabases]
AS
SELECT DISTINCT ServerName
	,DatabaseName
	,cast(NULL as varchar(max))  as Description 
FROM dbo.vwObjectDoc
