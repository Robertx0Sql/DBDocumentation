CREATE PROCEDURE [dbo].[upCubeDocDimensionsInCube]
    (@Catalog       VARCHAR(255)
    ,@Cube          VARCHAR(255)
    )
AS

SELECT * 
	FROM (SELECT *
        FROM dbo.MDSCHEMA_DIMENSIONS  
        WHERE [DIMENSION_IS_VISIBLE]=1) AS T 
        WHERE  CAST([CATALOG_NAME] AS VARCHAR(255))        = @Catalog
        AND CAST([CUBE_NAME] AS VARCHAR(255))           = @Cube

