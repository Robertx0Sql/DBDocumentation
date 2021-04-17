CREATE PROCEDURE [report].[upGetSqlBusMatrix] (
    @Server VARCHAR(255)
    ,@DatabaseName VARCHAR(255)
    ,@SchemaName VARCHAR(255) = NULL
    ,@ReferencedSchemaName VARCHAR(255) = NULL
    )
AS
BEGIN

	DECLARE @lf AS VARCHAR(5) = CHAR(10); 

    SELECT --* 
		SERVERNAME
		,DatabaseName
		--,ParentName = QUOTENAME (	ParentSchemaName) + '.' + QUOTENAME(ParentObjectName)
        --,ReferenceName = QUOTENAME (	ReferencedSchemaName) + '.' + QUOTENAME(ReferencedObjectName) + @lf  + fields
		,ParentName = ParentObjectName
		,ReferenceName = ReferencedObjectName  + @lf  +' '+ QuoteName(fields,')')
		,ParentSchemaName
        ,ParentObjectName
        ,ParentTypeCode
        ,fields
        ,ReferencedSchemaName
        ,ReferencedObjectName
        ,ReferencedColumnName
		 ,1 AS Relationship
    FROM dbo.vwChildObjects
    WHERE TypeCode = 'F'
        AND DatabaseName = @DatabaseName
        AND SERVERNAME = @Server
        AND ParentSchemaName = @SchemaName
        AND ReferencedSchemaName = @ReferencedSchemaName
    ORDER BY ParentSchemaName
        ,ParentObjectName
        ,ReferencedSchemaName
        ,ReferencedObjectName
END