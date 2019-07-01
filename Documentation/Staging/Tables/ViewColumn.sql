CREATE TABLE [Staging].[ViewColumn] (
    [ServerName]       VARCHAR (100)  NOT NULL,
    [DatabaseName]     NVARCHAR (128) NOT NULL,
    [VIEW_SCHEMA]      NVARCHAR (128) NOT NULL,
    [VIEW_NAME]        NVARCHAR (128) NOT NULL,
    [TABLE_SCHEMA]     NVARCHAR (128) NULL,
    [TABLE_NAME]       NVARCHAR (128) NULL,
    [COLUMN_NAME]      NVARCHAR (128) NULL,
    [ORDINAL_POSITION] INT            NOT NULL,
    [is_ambiguous]     INT            NOT NULL,
    [Expression]       NVARCHAR (MAX) NULL,
    [StagingId]        INT            IDENTITY (1, 1) NOT NULL,
    [StagingDateTime]  DATETIME2 (7)  CONSTRAINT [DF_Staging_ViewColumn_StagingDateTime] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_ViewColumn] PRIMARY KEY CLUSTERED ([StagingId] ASC)
);

