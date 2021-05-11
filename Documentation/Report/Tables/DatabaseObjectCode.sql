CREATE TABLE [report].[DatabaseObjectCode] (
    [DatabaseObjectCodeId]  INT            IDENTITY (1, 1) NOT NULL,
    [ServerName]            VARCHAR (100)  NULL,
    [DatabaseName]          NVARCHAR (128) NULL,
    [ObjectSchemaName]      NVARCHAR (128) NULL,
    [ObjectName]            NVARCHAR (255) NULL,
    [TypeCode]              VARCHAR (10)   NULL,
    [ObjectCode]            NVARCHAR (MAX) NULL,
    [DocumentationDateTime] DATETIME2 (7)  NOT NULL,
    CONSTRAINT [PK_report_DatabaseObjectCode] PRIMARY KEY CLUSTERED ([DatabaseObjectCodeId] ASC)
);



