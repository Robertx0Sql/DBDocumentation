CREATE PROCEDURE [dbo].[upCubeDocMeasuresInMeasureGroup]
    (@Catalog       VARCHAR(255)
    ,@Cube          VARCHAR(255)
    ,@MeasureGroup  VARCHAR(255)
    )
AS

SELECT * FROM (SELECT *
        FROM dbo.MDSCHEMA_MEASURES 
        WHERE [MEASURE_IS_VISIBLE]=1) AS T 
     WHERE  CAST([CATALOG_NAME] AS VARCHAR(255))        = @Catalog
        AND CAST([CUBE_NAME] AS VARCHAR(255))           = @Cube
        AND CAST([MEASUREGROUP_NAME] AS VARCHAR(255))   = @MeasureGroup

