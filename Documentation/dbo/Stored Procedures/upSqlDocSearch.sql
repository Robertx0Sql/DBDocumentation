
CREATE PROCEDURE dbo.upSqlDocSearch (
	@Search VARCHAR(255)
	,@server VARCHAR(255) = NULL
	,@database VARCHAR(255) = NULL
	)
AS
--DECLARE @server VARCHAR(255); 
--DECLARE @database VARCHAR(255); 
--DECLARE @separator    CHAR(1) = ':';
--DECLARE @pos INT = CHARINDEX (@separator,@catalog,0);
--IF ( @pos >0 )
--BEGIN
--	SELECT @server = LEFT (@Catalog, @pos -1) , @database= SUBSTRING(@Catalog,@pos+1, 255);	
--END;
WITH dbo
AS (
	SELECT CAST('column ' AS VARCHAR(50)) AS [Type]
		,CAST(name AS VARCHAR(255)) AS [Name]
		,CAST([DocumentationDescription] AS VARCHAR(4000)) AS [Description]
		,CAST(SERVERNAME AS VARCHAR(255)) AS ServerName
		,CAST(DatabaseName AS VARCHAR(255)) AS DatabaseName
		,CAST(TableSchemaName AS VARCHAR(255)) AS SchemaName
		,CAST(TableName AS VARCHAR(255)) AS ObjectName
		,CAST(ot.TypeDescriptionUser AS VARCHAR(255)) AS TypeDescriptionUser
	FROM [dbo].[vwColumnDoc] t
	LEFT JOIN dbo.vwObjectType ot
		ON ot.TypeCode = t.TypeCode
	WHERE (
			@server = SERVERNAME
			OR @server IS NULL
			)
		AND @database = DatabaseName
		AND (
			[Name] LIKE '%' + @Search + '%'
			OR [DocumentationDescription] LIKE '%' + @Search + '%'
			)
		AND ot.TypeDescriptionUser != 'Stored Procedure'
	
	UNION ALL
	
	SELECT CAST(t.TypeDescriptionUser AS VARCHAR(50)) AS [Type]
		,CAST(t.ObjectName AS VARCHAR(255)) AS [Name]
		,CAST(t.[DocumentationDescription] AS VARCHAR(4000)) AS [Description]
		,CAST(t.SERVERNAME AS VARCHAR(255)) AS ServerName
		,CAST(t.DatabaseName AS VARCHAR(255)) AS DatabaseName
		,CAST(t.parentSchemaName AS VARCHAR(255)) AS SchemaName
		,CAST(t.parentObjectName AS VARCHAR(255)) AS ObjectName
		,CAST(p.TypeDescriptionUser AS VARCHAR(255)) AS TypeDescriptionUser
	FROM [dbo].vwObjectDoc t
	LEFT JOIN [dbo].vwObjectDoc p
		ON t.ParentObjectName = p.ObjectName
			AND t.ParentSchemaName = p.SchemaName
	WHERE (
			@server = t.SERVERNAME
			OR @server IS NULL
			)
		AND @database = t.DatabaseName
		AND (
			t.[ObjectName] LIKE '%' + @Search + '%'
			OR t.[DocumentationDescription] LIKE '%' + @Search + '%'
			)
	)
SELECT DISTINCT 
	 dbo.[Type]
	,dbo.[Name]					
	,dbo.[Description]			
	,dbo.ServerName				
	,dbo.DatabaseName			
	,dbo.SchemaName				
	,dbo.ObjectName				
	,dbo.TypeDescriptionUser	
FROM dbo
ORDER BY TypeDescriptionUser
	,SchemaName
	,objectName
	,[Type];