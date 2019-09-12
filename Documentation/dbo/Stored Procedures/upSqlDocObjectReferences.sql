CREATE PROCEDURE [dbo].[upSqlDocObjectReferences] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255)
	,@Object VARCHAR(255)
	,@UserMode BIT = 1
	)
AS
BEGIN
	SELECT [ServerName]
		,[DatabaseName]
		,[referencing_schema_name] as ReferencedSchemaName
		,[referencing_entity_name] as ReferencedObjectName
		,TypeCode  AS ReferencedTypeCode   
		,[TypeDescriptionUser]
		--,[referenced_server_name]
		--,[referenced_database_name]
		--,[referenced_schema_name]
		--,[referenced_entity_name]
		--,DocumentationLoadDate
		,DependencyTypeCode
	FROM dbo.[vwSQLDocObjectReference]
	WHERE DatabaseName = @DatabaseName
		AND SERVERNAME = @Server
		AND [referenced_schema_name] = @Schema
		AND [referenced_entity_name] = @Object
		AND NOT (
			[referencing_schema_name] = @Schema
			AND [referencing_entity_name] = @Object
			)
		AND typecode != 'C'
		AND (
			@UserMode = UserModeFlag
			OR @UserMode = 0
			)
	
	UNION ALL
	
	SELECT [ServerName]
		,[DatabaseName]
		,ParentSchemaName AS [ReferencedSchemaName]
		,ParentObjectName AS [ReferencedObjectName]
		,TypeCode  ='U' 
		,'Table' AS [TypeDescriptionUser]
		--,[ServerName] AS [referenced_server_name]
		--,[DatabaseName] AS [referenced_database_name]
		--,ReferencedSchemaName AS [referenced_schema_name]
		--,ReferencedObjectName AS [referenced_entity_name]
		--,DocumentationLoadDate
		,DependencyTypeCode = 'X'
	FROM [dbo].[vwChildObjects]
	WHERE DatabaseName = @DatabaseName
		AND SERVERNAME = @Server
		AND ReferencedSchemaName = @Schema
		AND ReferencedObjectName = @Object
		AND (@UserMode = UserModeFlag
	or @UserMode = 0 )
END