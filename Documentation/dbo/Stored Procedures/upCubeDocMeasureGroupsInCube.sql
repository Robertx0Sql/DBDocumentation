CREATE PROCEDURE [dbo].[upCubeDocMeasureGroupsInCube]
    (@Catalog       VARCHAR(255)
    ,@Cube          VARCHAR(255)
    )
AS


SELECT * FROM (SELECT *
        FROM dbo.MDSCHEMA_MEASUREGROUPS ) AS T 
     WHERE  CAST([CATALOG_NAME] AS VARCHAR(255))        = @Catalog
        AND CAST([CUBE_NAME] AS VARCHAR(255))           = @Cube

