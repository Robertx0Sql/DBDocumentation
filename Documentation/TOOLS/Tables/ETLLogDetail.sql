CREATE TABLE [TOOLS].[ETLLogDetail] (
    [ETLLogDetailId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [LogId]          BIGINT          NOT NULL,
    [Starttime]      DATETIME        NOT NULL,
    [endtime]        DATETIME        NOT NULL,
    [message]        NVARCHAR (2048) NOT NULL,
    [rows]           BIGINT          NOT NULL,
    CONSTRAINT [PK_TOOLS_LogDetail] PRIMARY KEY CLUSTERED ([ETLLogDetailId] ASC)
);

