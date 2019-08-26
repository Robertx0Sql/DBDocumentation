CREATE TABLE [dbo].[SQLDOCObjectType] (
    [TypeGroup]           NVARCHAR (11) NOT NULL,
    [TypeGroupOrder]      INT           NOT NULL,
    [TypeCode]            VARCHAR (10)  NOT NULL,
    [TypeDescriptionSQL]  NVARCHAR (25) NULL,
    [TypeDescriptionUser] NVARCHAR (22) NULL,
    [TypeOrder]           BIGINT        NULL,
    [TypeCount]           INT           NULL,
    [UserModeFlag]        BIT           NULL,
    CONSTRAINT [PK_ObjectDocumentation] PRIMARY KEY CLUSTERED ([TypeCode] ASC)
);



