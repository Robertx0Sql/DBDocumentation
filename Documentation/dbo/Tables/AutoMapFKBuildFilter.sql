CREATE TABLE [dbo].[AutoMapFKBuildFilter] (
    [DatabaseName]              NVARCHAR (128) NULL,
    [TableSchemaName]           NVARCHAR (128) NULL,
    [TableName]                 NVARCHAR (128) NULL,
    [ColumnName]                [sysname]      NULL,
    [ReferencedTableSchemaName] NVARCHAR (128) NULL,
    [ReferencedTableName]       NVARCHAR (128) NULL
);

