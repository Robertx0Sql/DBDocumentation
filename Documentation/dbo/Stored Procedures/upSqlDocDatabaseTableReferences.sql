
CREATE PROCEDURE [dbo].[upSqlDocDatabaseTableReferences] 
	@Server VARCHAR(255)
	,@DatabaseName VARCHAR(255)
	,@Schema VARCHAR(255)
	,@Object VARCHAR(255)
AS

 DECLARE @BoxSize INT;
 DECLARE @Stretch FLOAT;
 SET @BoxSize = 250;
 SET @Stretch = 1.4;


WITH BaseData  AS (
 

SELECT [ServerName]
	,[DatabaseName]
	,[referencing_schema_name]
	,[referencing_entity_name]
	,[TypeDescriptionUser]
	,[referenced_server_name]
	,[referenced_database_name]
	,[referenced_schema_name]
	,[referenced_entity_name]
	,referencing_schema_name + referencing_entity_name + TypeDescriptionUser AS Seq
	,[referencing_entity_name] AS DimensionCaption
	,[referenced_entity_name] AS MeasureGroupCaption
FROM dbo.vwObjectReference
WHERE DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND [referenced_schema_name] = @Schema
	AND [referenced_entity_name] = @Object
	AND NOT (
		[referencing_schema_name] = @Schema
		AND [referencing_entity_name] = @Object
		)
	AND typecode != 'C'


)
,TotCount AS
(
    SELECT COUNT(*) AS RecCount FROM BaseData 
)
, RecCount AS
(
    SELECT RANK() OVER (ORDER BY CAST(Seq AS VARCHAR(255))) AS RecID
        , RecCount
        , BaseData.* 
    FROM 
        BaseData CROSS JOIN TotCount 
)
, Angles AS
(
    SELECT 
        * 
        , SIN(RADIANS((CAST(RecID AS FLOAT)/CAST(RecCount AS FLOAT)) * 360)) * 1000 AS x
        , COS(RADIANS((CAST(RecID AS FLOAT)/CAST(RecCount AS FLOAT)) * 360)) * 1000 AS y
    FROM RecCount
)
,Results AS
(
    SELECT 
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
SELECT * FROM Results