CREATE TYPE [dbo].[ObjectCodeTableType] AS TABLE (
    [ServerName]   VARCHAR (100)  NULL,
    [DatabaseName] NVARCHAR (128) NULL,
    [SchemaName]   NVARCHAR (128) NULL,
    [ObjectName]   NVARCHAR (255) NULL,
    [Code]         NVARCHAR (MAX) NULL);

