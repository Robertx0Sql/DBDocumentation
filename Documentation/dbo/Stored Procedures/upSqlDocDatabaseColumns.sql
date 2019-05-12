CREATE  PROCEDURE [dbo].[upSqlDocDatabaseColumns] (
	@Server VARCHAR(255) 
	,@DatabaseName VARCHAR(255) 
	,@QualifiedTableName VARCHAR(255) 
	)
AS
SELECT [object_type]
	,[ServerName]
	,[DatabaseName]
	,[objectType]
	,[object_id]
	,[TableSchemaName]
	,[TableName]
	,[name]
	,[DocumentationDescription]
	,[column_id]
	,[datatype]
	,[max_length]
	,[precision]
	,[scale]
	,[collation_name]
	,[is_nullable]
	,[is_identity]
	,[ident_col_seed_value]
	,[ident_col_increment_value]
	,[is_computed]
	,[Column_Default]
	,[PK]
	,[FK_NAME]
	,[ReferencedTableObject_id]
	,[ReferencedTableSchemaName]
	,[ReferencedTableName]
	,[referenced_column]
FROM [dbo].[vwColumnDoc]
WHERE DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND QualifiedTableName = @QualifiedTableName;