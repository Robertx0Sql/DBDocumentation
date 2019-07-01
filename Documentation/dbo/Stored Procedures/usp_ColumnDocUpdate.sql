CREATE PROCEDURE [dbo].[usp_ColumnDocUpdate]
    @TVP [ColumnDocTableType]  READONLY  
AS  
BEGIN

	SET NOCOUNT ON ;

	 DELETE E 
	 FROM [Staging].[ColumnDoc] E
	 INNER JOIN @TVP X ON x.	[ServerName] =E.[ServerName] 
	 AND X.[DatabaseName] = E.[DatabaseName];
		   

	 INSERT INTO [Staging].[ColumnDoc]
           ([ServerName]
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
           ,[referenced_column],[objectTypeDescription] )
    
	 
	 SELECT [ServerName]
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
		   ,[objectTypeDescription] 
        FROM  @TVP;
END

