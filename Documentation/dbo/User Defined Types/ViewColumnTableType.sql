CREATE TYPE [dbo].[SQLDocViewDefinitionColumnMapTableType] AS TABLE (
    [ServerName]		VARCHAR (100)  NULL,
    [DatabaseName]		NVARCHAR (128) NULL,
    [ViewSchema]		NVARCHAR (128) NULL,
    [ViewName]			NVARCHAR (128) NULL,
    [SourceTableSchema] NVARCHAR (128) NULL,
    [SourceTableName]   NVARCHAR (128) NULL,
    [ColumnName]		NVARCHAR (128) NULL,
    [ColumnId]			INT            NULL,
    [is_ambiguous]		INT            NULL,
    [Expression]		NVARCHAR (MAX) NULL);
