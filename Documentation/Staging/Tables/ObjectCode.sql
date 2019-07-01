CREATE TABLE [Staging].[ObjectCode] (
    [ServerName]      VARCHAR (100)  NULL,
    [DatabaseName]    NVARCHAR (128) NULL,
    [SchemaName]      NVARCHAR (128) NULL,
    [ObjectName]      NVARCHAR (255) NULL,
    [Code]            NVARCHAR (MAX) NULL,
    [StagingId]       INT            IDENTITY (1, 1) NOT NULL,
    [StagingDateTime] DATETIME2 (7)  CONSTRAINT [DF_Staging_ObjectCode_StagingDateTime] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_ObjectCode] PRIMARY KEY CLUSTERED ([StagingId] ASC)
);

