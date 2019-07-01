CREATE TYPE [dbo].[ViewColumnTableType] AS TABLE (
    [ServerName]       VARCHAR (100)  NULL,
    [DatabaseName]     NVARCHAR (128) NULL,
    [VIEW_SCHEMA]      NVARCHAR (128) NULL,
    [VIEW_NAME]        NVARCHAR (128) NULL,
    [TABLE_SCHEMA]     NVARCHAR (128) NULL,
    [TABLE_NAME]       NVARCHAR (128) NULL,
    [COLUMN_NAME]      NVARCHAR (128) NULL,
    [ORDINAL_POSITION] INT            NULL,
    [is_ambiguous]     INT            NULL,
    [Expression]       NVARCHAR (MAX) NULL);

