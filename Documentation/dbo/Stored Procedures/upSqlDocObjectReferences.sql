
CREATE PROCEDURE [dbo].[upSqlDocObjectReferences] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255)
	,@Object VARCHAR(255)
	)
AS
BEGIN
	SELECT [ServerName]
		,[DatabaseName]
		,[referencing_schema_name]
		,[referencing_entity_name]
		,[TypeDescriptionUser]
		,[referenced_server_name]
		,[referenced_database_name]
		,[referenced_schema_name]
		,[referenced_entity_name]
	--	,referencing_schema_name + referencing_entity_name + TypeDescriptionUser AS Seq
	--	,[referencing_entity_name] AS DimensionCaption
	--	,[referenced_entity_name] AS MeasureGroupCaption
		,DocumentationLoadDate
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
END