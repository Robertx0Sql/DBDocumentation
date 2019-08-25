CREATE TABLE [dbo].[AutoMapFKBuildFilter] (
    [AutoMapFKBuildFilterId]    INT            IDENTITY (1, 1) NOT NULL,
    [DatabaseName]              NVARCHAR (128) NULL,
    [TableSchemaName]           NVARCHAR (128) NULL,
    [TableName]                 NVARCHAR (128) NULL,
    [ColumnName]                [sysname]      NULL,
    [ReferencedTableSchemaName] NVARCHAR (128) NULL,
    [ReferencedTableName]       NVARCHAR (128) NULL,
    CONSTRAINT [PK_AutoMapFKBuildFilter] PRIMARY KEY CLUSTERED ([AutoMapFKBuildFilterId] ASC)
);



