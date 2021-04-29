
CREATE PROCEDURE [report].[upGetSQLDatabases]
AS
SELECT DISTINCT ServerName
	,DatabaseName
	,CAST(d.DocumentationDescription AS VARCHAR(MAX))  as Description 
	,d.StagingDateTime as DocumentationLoadDate
FROM Staging.DatabaseInformation d
