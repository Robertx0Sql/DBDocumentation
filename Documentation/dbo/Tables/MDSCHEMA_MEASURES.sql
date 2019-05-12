CREATE TABLE [dbo].[MDSCHEMA_MEASURES] (
    [CATALOG_NAME]                 VARCHAR (255)    NULL,
    [SCHEMA_NAME]                  VARCHAR (255)    NULL,
    [CUBE_NAME]                    VARCHAR (255)    NULL,
    [MEASURE_NAME]                 VARCHAR (255)    NULL,
    [MEASURE_UNIQUE_NAME]          VARCHAR (255)    NULL,
    [MEASURE_CAPTION]              VARCHAR (255)    NULL,
    [MEASURE_GUID]                 UNIQUEIDENTIFIER NULL,
    [MEASURE_AGGREGATOR]           INT              NULL,
    [DATA_TYPE]                    INT              NULL,
    [NUMERIC_PRECISION]            INT              NULL,
    [NUMERIC_SCALE]                INT              NULL,
    [MEASURE_UNITS]                VARCHAR (255)    NULL,
    [DESCRIPTION]                  VARCHAR (MAX)    NULL,
    [EXPRESSION]                   VARCHAR (MAX)    NULL,
    [MEASURE_IS_VISIBLE]           BIT              NULL,
    [LEVELS_LIST]                  VARCHAR (255)    NULL,
    [MEASURE_NAME_SQL_COLUMN_NAME] VARCHAR (MAX)    NULL,
    [MEASURE_UNQUALIFIED_CAPTION]  VARCHAR (MAX)    NULL,
    [MEASUREGROUP_NAME]            VARCHAR (255)    NULL,
    [MEASURE_DISPLAY_FOLDER]       VARCHAR (255)    NULL,
    [DEFAULT_FORMAT_STRING]        VARCHAR (255)    NULL
);

