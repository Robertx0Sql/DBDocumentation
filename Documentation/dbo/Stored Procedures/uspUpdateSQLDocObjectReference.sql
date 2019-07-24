CREATE PROCEDURE [dbo].[uspUpdateSQLDocObjectReference] 
(
	@TVPObjRef [SQLDocObjectReferenceTableType] READONLY
)
AS
BEGIN 

	DELETE E
	FROM [Staging].[SQLDocObjectReference] E
	INNER JOIN @TVPObjRef X
		ON x.[ServerName] = E.[ServerName]
			AND X.[DatabaseName] = E.[DatabaseName];

	INSERT INTO [Staging].[SQLDocObjectReference] (
		[ServerName]
		,[DatabaseName]
		,[referencing_schema_name]
		,[referencing_entity_name]
		,[referencing_TypeCode]
		,[referencing_TypeDescriptionSQL]
		,[referenced_server_name]
		,[referenced_database_name]
		,[referenced_schema_name]
		,[referenced_entity_name]
		)
	SELECT [ServerName]
		,[DatabaseName]
		,[referencing_schema_name]
		,[referencing_entity_name]
		,[referencing_TypeCode]
		,[referencing_TypeDescriptionSQL]
		,[referenced_server_name]
		,[referenced_database_name]
		,[referenced_schema_name]
		,[referenced_entity_name]
	FROM @TVPObjRef;
END