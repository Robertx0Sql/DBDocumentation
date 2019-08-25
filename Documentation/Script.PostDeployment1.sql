/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/


GO
SELECT * INTO #tmp_GridResults_1
FROM (
SELECT N'1' AS [AutoMapFKBuildFilterId], N'EDW' AS [DatabaseName], NULL AS [TableSchemaName], NULL AS [TableName], NULL AS [ColumnName], N'%' AS [ReferencedTableSchemaName], N'SsP_%' AS [ReferencedTableName] UNION ALL
SELECT N'3' AS [AutoMapFKBuildFilterId], N'ods' AS [DatabaseName], N'%' AS [TableSchemaName], N'%' AS [TableName], N'%' AS [ColumnName], N'%' AS [ReferencedTableSchemaName], N'%' AS [ReferencedTableName] UNION ALL
SELECT N'5' AS [AutoMapFKBuildFilterId], N'EDW' AS [DatabaseName], NULL AS [TableSchemaName], NULL AS [TableName], NULL AS [ColumnName], N'Staging' AS [ReferencedTableSchemaName], N'%' AS [ReferencedTableName] ) t;

INSERT INTO [dbo].[AutoMapFKBuildFilter] (
	[DatabaseName]
	,[TableSchemaName]
	,[TableName]
	,[ColumnName]
	,[ReferencedTableSchemaName]
	,[ReferencedTableName]
	)
SELECT T.[DatabaseName]
	,T.[TableSchemaName]
	,T.[TableName]
	,T.[ColumnName]
	,T.[ReferencedTableSchemaName]
	,T.[ReferencedTableName]
FROM #tmp_GridResults_1 T
LEFT JOIN [dbo].[AutoMapFKBuildFilter] E
	ON E.[DatabaseName] = T.[DatabaseName]
		AND ISNULL(E.[TableSchemaName], '') = ISNULL(T.[TableSchemaName], '')
		AND ISNULL(E.[TableName], '') = ISNULL(T.[TableName], '')
		AND ISNULL(E.[ColumnName], '') = ISNULL(T.[ColumnName], '')
		AND ISNULL(E.[ReferencedTableSchemaName], '') = ISNULL(T.[ReferencedTableSchemaName], '')
		AND ISNULL(E.[ReferencedTableName], '') = ISNULL(T.[ReferencedTableName], '')
WHERE e.[AutoMapFKBuildFilterId] IS NULL;

drop table #tmp_GridResults_1
go