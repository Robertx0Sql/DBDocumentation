CREATE TABLE [dbo].[SQLDOCAutoMapFK] (
    [ServerName]                VARCHAR (100)  NULL,
    [DatabaseName]              NVARCHAR (128) NULL,
    [column_id]                 INT            NULL,
    [TableSchemaName]           NVARCHAR (128) NOT NULL,
    [TableName]                 NVARCHAR (128) NOT NULL,
    [name]                      [sysname]      NULL,
    [ReferencedTableSchemaName] NVARCHAR (128) NOT NULL,
    [ReferencedTableName]       NVARCHAR (128) NOT NULL,
    [referenced_column]         [sysname]      NULL,
    [FK_NAME]                   NVARCHAR (404) NOT NULL,
    [matchid]                   BIGINT         NULL,
    [DocumentationLoadDate]     DATETIME2 (7)  NOT NULL,
    [TypeDescriptionUser]       NVARCHAR (22)  NULL,
    [TypeGroup]                 NVARCHAR (11)  NULL,
    [TypeCode]                  VARCHAR (10)   NULL
);

