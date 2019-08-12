CREATE VIEW dbo.vwAutoMapFK
AS
SELECT [ServerName]
	,[DatabaseName]
	,[column_id]
	,[TableSchemaName]
	,[TableName]
	,[name]
	,[ReferencedTableSchemaName]
	,[ReferencedTableName]
	,[referenced_column]
	,[FK_NAME]
	,[matchid]
	,[DocumentationLoadDate]
	,[TypeDescriptionUser]
	,[TypeGroup]
	,[TypeCode]
FROM dbo.SQLDOCAutoMapFK
WHERE [matchid] = 1