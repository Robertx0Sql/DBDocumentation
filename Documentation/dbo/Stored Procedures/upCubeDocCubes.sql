CREATE PROCEDURE [dbo].[upCubeDocCubes]
    (@Catalog       VARCHAR(255) = NULL
    )
AS

	SELECT * 
     FROM dbo.MDSCHEMA_CUBES 
     WHERE CUBE_SOURCE = 1
     AND CAST([CATALOG_NAME] AS VARCHAR(255)) = @Catalog
        OR @Catalog IS NULL

