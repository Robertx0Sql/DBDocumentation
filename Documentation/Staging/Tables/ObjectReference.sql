CREATE TABLE [Staging].[ObjectReference] (
    [ServerName]                     VARCHAR (100)  NOT NULL,
    [DatabaseName]                   NVARCHAR (128) NOT NULL,
    [referencing_schema_name]        NVARCHAR (128) NOT NULL,
    [referencing_entity_name]        NVARCHAR (128) NOT NULL,
    [referencing_TypeCode]           VARCHAR (10)   NULL,
    [referencing_TypeDescriptionSQL] NVARCHAR (60)  NULL,
    [referenced_server_name]         NVARCHAR (128) NULL,
    [referenced_database_name]       NVARCHAR (128) NULL,
    [referenced_schema_name]         NVARCHAR (128) NULL,
    [referenced_entity_name]         NVARCHAR (128) NOT NULL,
    [StagingId]                      INT            IDENTITY (1, 1) NOT NULL,
    [StagingDateTime]                DATETIME2 (7)  CONSTRAINT [DF_Staging_ObjectReference_StagingDateTime] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_ObjectReference] PRIMARY KEY CLUSTERED ([StagingId] ASC)
);





