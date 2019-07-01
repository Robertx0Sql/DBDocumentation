CREATE TABLE [Staging].[ObjectDocumentation] (
    [ServerName]               VARCHAR (100)  NULL,
    [DatabaseName]             NVARCHAR (128) NULL,
    [ObjectType]               VARCHAR (10)   NOT NULL,
    [ParentSchemaName]         NVARCHAR (128) NULL,
    [ParentObjectName]         NVARCHAR (255) NULL,
    [SchemaName]               NVARCHAR (128) NULL,
    [ObjectName]               NVARCHAR (255) NULL,
    [DocumentationDescription] NVARCHAR (MAX) NULL,
    [StagingId]                INT            IDENTITY (1, 1) NOT NULL,
    [StagingDateTime]          DATETIME2 (7)  CONSTRAINT [DF_Staging_ObjectDocumentationc_StagingDateTime] DEFAULT (getutcdate()) NOT NULL,
    [Fields]                   NVARCHAR (MAX) NULL,
    [Definition]               NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ObjectDocumentation] PRIMARY KEY CLUSTERED ([StagingId] ASC)
);



