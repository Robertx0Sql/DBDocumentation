﻿
CREATE PROCEDURE [dbo].[upSqlDocDatabases]
AS
SELECT DISTINCT ServerName
	,DatabaseName
	,CAST(d.DocumentationDescription AS VARCHAR(MAX))  as Description 
FROM Staging.DatabaseInformation d
