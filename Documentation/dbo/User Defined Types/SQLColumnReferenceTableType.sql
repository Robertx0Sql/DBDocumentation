CREATE TYPE [dbo].[SQLColumnReferenceTableType] AS TABLE (
    [ServerName]           VARCHAR (100)  NULL,
    [DatabaseName]         NVARCHAR (128) NULL,
    [SchemaName]           NVARCHAR (128) NULL,
    [ObjectName]           NVARCHAR (128) NULL,
	[ObjectType]           VARCHAR(10)    NULL,
    [ColumnName]           [sysname]      NULL,
    [ColumnId]             INT            NULL,
    [FK_NAME]              [sysname]      NULL,
    [ReferencedSchemaName] NVARCHAR (128) NULL,
    [ReferencedObjectName] NVARCHAR (128) NULL,
	[ReferencedObjectType] VARCHAR(10)    NULL,
    [ReferencedColumnName] [sysname]      NULL);

