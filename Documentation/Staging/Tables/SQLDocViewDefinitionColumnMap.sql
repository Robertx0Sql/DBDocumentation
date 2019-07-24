CREATE TABLE [Staging].[SQLDocViewDefinitionColumnMap] (
    [ServerName]		VARCHAR (100)  NOT NULL,
    [DatabaseName]		NVARCHAR (128) NOT NULL,
    [ViewSchema]		NVARCHAR (128) NOT NULL,
    [ViewName]			NVARCHAR (128) NOT NULL,
    [SourceTableSchema] NVARCHAR (128) NULL,
    [SourceTableName]   NVARCHAR (128) NULL,
    [ColumnName]		NVARCHAR (128) NULL,
    [ColumnId]			INT            NOT NULL,
    [is_ambiguous]		INT            NOT NULL,
    [Expression]		NVARCHAR (MAX) NULL,
    [StagingId]			INT            IDENTITY (1, 1) NOT NULL,
    [StagingDateTime]	DATETIME2 (7)  CONSTRAINT [DF_SQLDocViewDefinitionColumnMap_StagingDateTime] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_SQLDocViewDefinitionColumnMap] PRIMARY KEY CLUSTERED ([StagingId] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_ViewColumn_Server_Database_Schema_Object]
    ON [Staging].[SQLDocViewDefinitionColumnMap]([ServerName] ASC, [DatabaseName] ASC, [ViewSchema] ASC, [ViewName] ASC);

