CREATE TABLE [dbo].[SQLColumnReference] (
    [SQLColumnReferenceId] INT            IDENTITY (1, 1) NOT NULL,
    [ServerName]           VARCHAR (100)  NULL,
    [DatabaseName]         NVARCHAR (128) NULL,
    [SchemaName]     NVARCHAR (128) NOT NULL,
    [ObjectName]           NVARCHAR (128) NOT NULL,
	[ObjectType]           VARCHAR(10)    NULL,
    [ColumnName]           [sysname]      NULL,
    [ColumnId]             INT            NULL,
    [FK_NAME]              [sysname]      NULL,
    [ReferencedSchemaName] NVARCHAR (128) NULL,
    [ReferencedObjectName] NVARCHAR (128) NULL,
	[ReferencedObjectType] VARCHAR(10)    NULL,
    [ReferencedColumnName] [sysname]      NULL,
    [LoadDateTime]         DATETIME2 (7)  CONSTRAINT [DF_SQLColumnReference_LoadDateTime] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_SQLColumnReference] PRIMARY KEY CLUSTERED ([SQLColumnReferenceId] ASC)
);

