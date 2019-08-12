CREATE PROCEDURE [dbo].[uspUpdateSQLDOCAutoMapFK] (
	@Server VARCHAR(128)
	,@Database VARCHAR(128)
	)
AS
BEGIN
	WITH cte
	AS (
		SELECT u.[ServerName]
			,u.[DatabaseName]
			,u.[column_id]
			,u.[TableSchemaName]
			,u.[TableName]
			,u.[name]
			,u.[ReferencedTableSchemaName]
			,u.[ReferencedTableName]
			,u.[referenced_column]
			,u.[FK_NAME]
			,u.[matchid]
			,u.[DocumentationLoadDate]
			,u.[TypeDescriptionUser]
			,u.[TypeGroup]
			,u.[TypeCode]
			,[UpdatedDateTime] = Getdate()
		FROM [dbo].[vwAutoMapFKList] U
		WHERE FKCount = 1
			AND ServerName= @Server 
			AND DatabaseName =@Database

		)
	--[noformat]
	MERGE INTO [SQLDOCAutoMapFK] AS [Target]
	USING cte AS [Source] 
	ON ([Target].[ServerName] = [Source].[ServerName] AND [Target].[DatabaseName] = [Source].[DatabaseName] AND [Target].[TableSchemaName] = [Source].[TableSchemaName] AND [Target].[TableName] = [Source].[TableName] AND [Target].[name] = [Source].[name] AND [Target].[ReferencedTableSchemaName] = [Source].[ReferencedTableSchemaName] AND [Target].[ReferencedTableName] = [Source].[ReferencedTableName])
	WHEN NOT MATCHED BY TARGET THEN
	 INSERT([ServerName],[DatabaseName],[column_id],[TableSchemaName],[TableName],[name],[ReferencedTableSchemaName],[ReferencedTableName],[referenced_column],[FK_NAME],[matchid],[DocumentationLoadDate],[TypeDescriptionUser],[TypeGroup],[TypeCode],[UpdatedDateTime])
	 VALUES([Source].[ServerName],[Source].[DatabaseName],[Source].[column_id],[Source].[TableSchemaName],[Source].[TableName],[Source].[name],[Source].[ReferencedTableSchemaName],[Source].[ReferencedTableName],[Source].[referenced_column],[Source].[FK_NAME],[Source].[matchid],[Source].[DocumentationLoadDate],[Source].[TypeDescriptionUser],[Source].[TypeGroup],[Source].[TypeCode],[Source].[UpdatedDateTime])

	WHEN MATCHED AND (
		NULLIF([Source].[ServerName], [Target].[ServerName]) IS NOT NULL
		OR NULLIF([Target].[ServerName], [Source].[ServerName]) IS NOT NULL
		OR NULLIF([Source].[DatabaseName], [Target].[DatabaseName]) IS NOT NULL
		OR NULLIF([Target].[DatabaseName], [Source].[DatabaseName]) IS NOT NULL
		OR NULLIF([Source].[column_id], [Target].[column_id]) IS NOT NULL
		OR NULLIF([Target].[column_id], [Source].[column_id]) IS NOT NULL
		OR NULLIF([Source].[TableSchemaName], [Target].[TableSchemaName]) IS NOT NULL
		OR NULLIF([Target].[TableSchemaName], [Source].[TableSchemaName]) IS NOT NULL
		OR NULLIF([Source].[TableName], [Target].[TableName]) IS NOT NULL
		OR NULLIF([Target].[TableName], [Source].[TableName]) IS NOT NULL
		OR NULLIF([Source].[name], [Target].[name]) IS NOT NULL
		OR NULLIF([Target].[name], [Source].[name]) IS NOT NULL
		OR NULLIF([Source].[ReferencedTableSchemaName], [Target].[ReferencedTableSchemaName]) IS NOT NULL
		OR NULLIF([Target].[ReferencedTableSchemaName], [Source].[ReferencedTableSchemaName]) IS NOT NULL
		OR NULLIF([Source].[ReferencedTableName], [Target].[ReferencedTableName]) IS NOT NULL
		OR NULLIF([Target].[ReferencedTableName], [Source].[ReferencedTableName]) IS NOT NULL
		OR NULLIF([Source].[referenced_column], [Target].[referenced_column]) IS NOT NULL
		OR NULLIF([Target].[referenced_column], [Source].[referenced_column]) IS NOT NULL
		OR NULLIF([Source].[FK_NAME], [Target].[FK_NAME]) IS NOT NULL
		OR NULLIF([Target].[FK_NAME], [Source].[FK_NAME]) IS NOT NULL
		OR NULLIF([Source].[matchid], [Target].[matchid]) IS NOT NULL
		OR NULLIF([Target].[matchid], [Source].[matchid]) IS NOT NULL
		OR NULLIF([Source].[DocumentationLoadDate], [Target].[DocumentationLoadDate]) IS NOT NULL
		OR NULLIF([Target].[DocumentationLoadDate], [Source].[DocumentationLoadDate]) IS NOT NULL
		OR NULLIF([Source].[TypeDescriptionUser], [Target].[TypeDescriptionUser]) IS NOT NULL
		OR NULLIF([Target].[TypeDescriptionUser], [Source].[TypeDescriptionUser]) IS NOT NULL
		OR NULLIF([Source].[TypeGroup], [Target].[TypeGroup]) IS NOT NULL
		OR NULLIF([Target].[TypeGroup], [Source].[TypeGroup]) IS NOT NULL
		OR NULLIF([Source].[TypeCode], [Target].[TypeCode]) IS NOT NULL
		OR NULLIF([Target].[TypeCode], [Source].[TypeCode]) IS NOT NULL
	
		) 
	THEN
	 UPDATE SET
	  [Target].[ServerName] = [Source].[ServerName], 
	  [Target].[DatabaseName] = [Source].[DatabaseName], 
	  [Target].[column_id] = [Source].[column_id], 
	  [Target].[TableSchemaName] = [Source].[TableSchemaName], 
	  [Target].[TableName] = [Source].[TableName], 
	  [Target].[name] = [Source].[name], 
	  [Target].[ReferencedTableSchemaName] = [Source].[ReferencedTableSchemaName], 
	  [Target].[ReferencedTableName] = [Source].[ReferencedTableName], 
	  [Target].[referenced_column] = [Source].[referenced_column], 
	  [Target].[FK_NAME] = [Source].[FK_NAME], 
	  [Target].[matchid] = [Source].[matchid], 
	  [Target].[DocumentationLoadDate] = [Source].[DocumentationLoadDate], 
	  [Target].[TypeDescriptionUser] = [Source].[TypeDescriptionUser], 
	  [Target].[TypeGroup] = [Source].[TypeGroup], 
	  [Target].[TypeCode] = [Source].[TypeCode], 
	  [Target].[UpdatedDateTime] = [Source].[UpdatedDateTime]
	WHEN NOT MATCHED BY SOURCE 
		AND Target.ServerName= @Server 
		AND Target.DatabaseName =@Database
	THEN 
	 DELETE;
--[/noformat]
END