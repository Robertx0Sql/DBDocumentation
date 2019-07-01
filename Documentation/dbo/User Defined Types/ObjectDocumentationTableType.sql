CREATE TYPE [dbo].[ObjectDocumentationTableType] AS TABLE (
    [ServerName]               VARCHAR (100)  NULL,
    [DatabaseName]             NVARCHAR (128) NULL,
    [ObjectType]               VARCHAR (10)   NULL,
    [ParentSchemaName]         NVARCHAR (128) NULL,
    [ParentObjectName]         NVARCHAR (255) NULL,
    [SchemaName]               NVARCHAR (128) NULL,
    [ObjectName]               NVARCHAR (255) NULL,
    [Fields]                   NVARCHAR (MAX) NULL,
    [Definition]               NVARCHAR (MAX) NULL,
    [DocumentationDescription] NVARCHAR (MAX) NULL);



