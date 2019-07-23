


CREATE PROCEDURE [dbo].[upSqlDocObjectChildFK] (
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255) = NULL
	,@Object VARCHAR(255) = NULL
	)
AS
BEGIN
	DECLARE @BoxSize INT;
	DECLARE @Stretch FLOAT;

	SET @BoxSize = 250;
	SET @Stretch = 1.4;

WITH BaseData
	AS (
	SELECT [ServerName]
			,[DatabaseName]
			,ReferencedTableSchemaName AS [referencing_schema_name]
			,ReferencedTableName AS [referencing_entity_name]
			,[ServerName] AS [referenced_server_name]
			,ObjectName AS [referenced_database_name]
			, ParentSchemaName  AS [referenced_schema_name]
			, ParentObjectName  AS [referenced_entity_name]
			,CONCAT (
				ReferencedTableSchemaName
				,ReferencedTableName
				,ObjectName
				,referenced_column
				) AS Seq
			,ReferencedTableName AS DimensionCaption
			,ParentObjectName AS MeasureGroupCaption
			,referenced_column
			,ReferencedTableName
			,ReferencedTableSchemaName
			,ReferencedObjectType = 'Table'
			,'Table' as [TypeDescriptionUser]
			,TypeGroup
			,TypeCode
			,DocumentationLoadDate
		FROM dbo.vwChildObjects
		WHERE TypeCode = 'F'
			AND DatabaseName = @DatabaseName
			AND SERVERNAME = @Server
			AND (
				ParentSchemaName = @Schema
				AND ParentObjectName = @Object
				)
)
		,TotCount
	AS (
		SELECT COUNT(*) AS RecCount
		FROM BaseData
		)
		,RecCount
	AS (
		SELECT RANK() OVER (
				ORDER BY CAST(Seq AS VARCHAR(255))
				) AS RecID
			,RecCount
			,BaseData.*
		FROM BaseData 
		CROSS JOIN TotCount
		)	
		,Angles
	AS (
		--[noformat]
(    SELECT 
        * 
        , SIN(RADIANS((CAST(RecID AS FLOAT)/CAST(RecCount AS FLOAT)) * 360)) * 1000 AS x
        , COS(RADIANS((CAST(RecID AS FLOAT)/CAST(RecCount AS FLOAT)) * 360)) * 1000 AS y
    FROM RecCount
)
			--[/noformat]
		)
		,Results
	AS (
		--[noformat]
(    SELECT 
        *
        , geometry::STGeomFromText('POINT(' + CAST(y AS VARCHAR(20)) + ' ' + CAST(x AS VARCHAR(20))  + ')',4326) AS Posn
        , geometry::STPolyFromText('POLYGON ((' + 
            CAST((y*@Stretch)+@BoxSize AS VARCHAR(20)) + ' ' + CAST(x+(@BoxSize/2) AS VARCHAR(20)) + ', ' +
            CAST((y*@Stretch)-@BoxSize AS VARCHAR(20)) + ' ' + CAST(x+(@BoxSize/2) AS VARCHAR(20)) + ', ' +
            CAST((y*@Stretch)-@BoxSize AS VARCHAR(20)) + ' ' + CAST(x-(@BoxSize/2) AS VARCHAR(20)) + ', ' +
            CAST((y*@Stretch)+@BoxSize AS VARCHAR(20)) + ' ' + CAST(x-(@BoxSize/2) AS VARCHAR(20)) + ', ' +
            CAST((y*@Stretch)+@BoxSize AS VARCHAR(20)) + ' ' + CAST(x+(@BoxSize/2) AS VARCHAR(20)) + '            
            ))',0) AS Box
         , geometry::STLineFromText('LINESTRING (0 0, ' + CAST((y*@Stretch) AS VARCHAR(20)) + ' ' + CAST(x AS VARCHAR(20))  + ')', 0) AS Line
         , geometry::STPolyFromText('POLYGON ((' + 
            CAST(0+@BoxSize AS VARCHAR(20)) + ' ' + CAST(0+(@BoxSize/2) AS VARCHAR(20)) + ', ' +
            CAST(0-@BoxSize AS VARCHAR(20)) + ' ' + CAST(0+(@BoxSize/2) AS VARCHAR(20)) + ', ' +
            CAST(0-@BoxSize AS VARCHAR(20)) + ' ' + CAST(0-(@BoxSize/2) AS VARCHAR(20)) + ', ' +
            CAST(0+@BoxSize AS VARCHAR(20)) + ' ' + CAST(0-(@BoxSize/2) AS VARCHAR(20)) + ', ' +
            CAST(0+@BoxSize AS VARCHAR(20)) + ' ' + CAST(0+(@BoxSize/2) AS VARCHAR(20)) + '            
            ))',0) AS CenterBox
         
         
    FROM Angles
)
			--[/noformat]
		)
	SELECT *
	FROM Results;

END