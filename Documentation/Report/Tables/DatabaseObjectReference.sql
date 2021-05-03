CREATE TABLE [report].[DatabaseObjectReference] (
    [DatabaseObjectReferenceId] INT            IDENTITY (1, 1) NOT NULL,
    [ServerName]                VARCHAR (100)  NOT NULL,
    [DatabaseName]              NVARCHAR (128) NOT NULL,
    [referencingSchemaName]     NVARCHAR (128) NOT NULL,
    [referencingEntityName]     NVARCHAR (128) NOT NULL,
    [referencingTypeCode]       VARCHAR (10)   NULL,
    [referencedServerName]      NVARCHAR (128) NULL,
    [referencedDatabaseName]    NVARCHAR (128) NULL,
    [referencedSchemaName]      NVARCHAR (128) NULL,
    [referencedEntityName]      NVARCHAR (128) NOT NULL,
    [referencedTypeCode]        VARCHAR (10)   NULL,
    [DocumentationDateTime]     DATETIME2 (7)  NOT NULL,
    CONSTRAINT [PK_report_DatabaseObjectReference] PRIMARY KEY CLUSTERED ([DatabaseObjectReferenceId] ASC)
);



