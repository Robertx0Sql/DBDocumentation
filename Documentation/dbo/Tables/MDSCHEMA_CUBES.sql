CREATE TABLE [dbo].[MDSCHEMA_CUBES] (
    [CATALOG_NAME]            VARCHAR (255)    NULL,
    [SCHEMA_NAME]             VARCHAR (255)    NULL,
    [CUBE_NAME]               VARCHAR (255)    NULL,
    [CUBE_TYPE]               VARCHAR (255)    NULL,
    [CUBE_GUID]               UNIQUEIDENTIFIER NULL,
    [CREATED_ON]              DATETIME         NULL,
    [LAST_SCHEMA_UPDATE]      DATETIME         NULL,
    [SCHEMA_UPDATED_BY]       VARCHAR (255)    NULL,
    [LAST_DATA_UPDATE]        DATETIME         NULL,
    [DATA_UPDATED_BY]         VARCHAR (255)    NULL,
    [DESCRIPTION]             VARCHAR (255)    NULL,
    [IS_DRILLTHROUGH_ENABLED] BIT              NULL,
    [IS_LINKABLE]             BIT              NULL,
    [IS_WRITE_ENABLED]        BIT              NULL,
    [IS_SQL_ENABLED]          BIT              NULL,
    [CUBE_CAPTION]            VARCHAR (255)    NULL,
    [BASE_CUBE_NAME]          VARCHAR (255)    NULL,
    [ANNOTATIONS]             VARCHAR (255)    NULL,
    [CUBE_Source]             INT              NULL
);

