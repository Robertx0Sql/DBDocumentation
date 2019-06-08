

CREATE PROCEDURE [dbo].[usp_ObjectReferenceUpdate] 
	@TVPObjRef ObjectReferenceTableType READONLY
AS
DELETE E
FROM [Staging].[ObjectReference] E
INNER JOIN @TVPObjRef X ON x.[ServerName] = E.[ServerName]
	AND X.[DatabaseName] = E.[DatabaseName]

INSERT INTO [Staging].[ObjectReference] (
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
FROM @TVPObjRef

--Alter table [Staging].[ObjectReference] add [referencing_TypeCode]varchar(10)