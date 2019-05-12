CREATE TABLE [dbo].[MDSCHEMA_DIMENSIONS] (
    [CATALOG_NAME]              VARCHAR (255)    NULL,
    [SCHEMA_NAME]               VARCHAR (255)    NULL,
    [CUBE_NAME]                 VARCHAR (255)    NULL,
    [DIMENSION_NAME]            VARCHAR (255)    NULL,
    [DIMENSION_UNIQUE_NAME]     VARCHAR (255)    NULL,
    [DIMENSION_GUID]            UNIQUEIDENTIFIER NULL,
    [DIMENSION_CAPTION]         VARCHAR (255)    NULL,
    [DIMENSION_ORDINAL]         INT              NULL,
    [DIMENSION_TYPE]            INT              NULL,
    [DIMENSION_CARDINALITY]     INT              NULL,
    [DEFAULT_HIERARCHY]         VARCHAR (255)    NULL,
    [DESCRIPTION]               VARCHAR (255)    NULL,
    [IS_VIRTUAL]                BIT              NULL,
    [IS_READWRITE]              BIT              NULL,
    [DIMENSION_UNIQUE_SETTINGS] INT              NULL,
    [DIMENSION_MASTER_NAME]     VARCHAR (255)    NULL,
    [DIMENSION_IS_VISIBLE]      BIT              NULL
);

