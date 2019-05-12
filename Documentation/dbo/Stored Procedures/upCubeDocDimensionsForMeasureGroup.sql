CREATE PROCEDURE [dbo].[upCubeDocDimensionsForMeasureGroup]
    (@Catalog       VARCHAR(255)
    ,@Cube          VARCHAR(255)
    ,@MeasureGroup  VARCHAR(255)
    )
AS

 DECLARE @BoxSize INT
 DECLARE @Stretch FLOAT
 SET @BoxSize = 250
 SET @Stretch = 1.4

;WITH BaseData AS
(
    SELECT 
          mgd.*
        , d.[DESCRIPTION] 
        , REPLACE(REPLACE(CAST(mgd.[DIMENSION_UNIQUE_NAME] AS VARCHAR(255)),'[',''),']','') AS DimensionCaption
        , REPLACE(REPLACE(CAST(mgd.[MEASUREGROUP_NAME] AS VARCHAR(255)),'[',''),']','') AS MeasureGroupCaption
    FROM (SELECT 
                [CATALOG_NAME]+[CUBE_NAME]+[MEASUREGROUP_NAME]+[DIMENSION_UNIQUE_NAME] AS Seq
                , [CATALOG_NAME]
                , [CUBE_NAME]
                , [MEASUREGROUP_NAME]
                , [MEASUREGROUP_CARDINALITY]
                , [DIMENSION_UNIQUE_NAME]
                , [DIMENSION_CARDINALITY]
                , [DIMENSION_IS_VISIBLE]
                , [DIMENSION_IS_FACT_DIMENSION]
                , [DIMENSION_GRANULARITY] 
            FROM dbo.MDSCHEMA_MEASUREGROUP_DIMENSIONS
            WHERE [DIMENSION_IS_VISIBLE]=1) mgd
        INNER JOIN (SELECT 
                [CATALOG_NAME]
                ,[CUBE_NAME]
                ,[DIMENSION_UNIQUE_NAME]
                ,[DESCRIPTION]
            FROM dbo.MDSCHEMA_DIMENSIONS  
            WHERE [DIMENSION_IS_VISIBLE]=1) d 
                ON  CAST(mgd.[CATALOG_NAME] AS VARCHAR(255))          = CAST(d.[CATALOG_NAME] AS VARCHAR(255))
                AND CAST(mgd.[CUBE_NAME] AS VARCHAR(255))             = CAST(d.[CUBE_NAME] AS VARCHAR(255))
                AND CAST(mgd.[DIMENSION_UNIQUE_NAME] AS VARCHAR(255)) = CAST(d.[DIMENSION_UNIQUE_NAME] AS VARCHAR(255))
     WHERE  CAST(mgd.[CATALOG_NAME] AS VARCHAR(255))        = @Catalog
        AND CAST(mgd.[CUBE_NAME] AS VARCHAR(255))           = @Cube
        AND CAST(mgd.[MEASUREGROUP_NAME] AS VARCHAR(255))   = @MeasureGroup
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

