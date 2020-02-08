CREATE TABLE [TOOLS].[ETLLOG] (
    [LOGID]           INT             IDENTITY (1, 1) NOT NULL,
    [source]          NVARCHAR (1024) NOT NULL,
    [starttime]       DATETIME        NOT NULL,
    [endtime]         DATETIME        NULL,
    [message]         NVARCHAR (2048) NULL,
    [DataCountInsert] INT             NULL,
    [DataCountUpdate] INT             NULL,
    [DataCountDelete] INT             NULL,
    [TotalRows]       BIGINT          NULL,
    [LogDescription]  VARCHAR (2048)  NULL,
    PRIMARY KEY CLUSTERED ([LOGID] ASC) WITH (FILLFACTOR = 80)
);

