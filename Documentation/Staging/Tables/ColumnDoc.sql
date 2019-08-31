CREATE TABLE [Staging].[ColumnDoc] (
    [StagingId]                 INT            IDENTITY (1, 1) NOT NULL,
    [ServerName]                VARCHAR (100)  NOT NULL,
    [DatabaseName]              NVARCHAR (128) NOT NULL,
    [objectType]                VARCHAR (10)   NOT NULL,
    [ObjectSchemaName]           NVARCHAR (128) NOT NULL,
    [ObjectName]                 NVARCHAR (128) NOT NULL,
    [ColumnName]                      [sysname]      NOT NULL,
    [ColumnId]                 INT            NOT NULL,
    [datatype]                  [sysname]      NULL,
    [max_length]                SMALLINT       NULL,
    [precision]                 TINYINT        NULL,
    [scale]                     TINYINT        NULL,
    [collation_name]            [sysname]      NULL,
    [is_nullable]               BIT            NOT NULL,
    [is_identity]               BIT            NOT NULL,
    [is_computed]               BIT            NOT NULL,
    [is_primary_key]            BIT            NOT NULL,
    [Column_Default]            NVARCHAR (MAX) NULL,
    [DocumentationDescription]  NVARCHAR (MAX) NULL,
    [StagingDateTime]           DATETIME2 (7)  CONSTRAINT [DF_Staging_ColumnDoc_StagingDateTime] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_ColumnDoc] PRIMARY KEY CLUSTERED ([StagingId] ASC)
);

GO
CREATE NONCLUSTERED INDEX [IX_ColumnDoc_Server_Database_Schema_Object]
    ON [Staging].[ColumnDoc]([ServerName] ASC, [DatabaseName] ASC, [ObjectSchemaName] ASC, [ObjectName] ASC);

