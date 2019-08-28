CREATE TABLE [dbo].[SQLDOCObjectType] (
    [TypeCode]            VARCHAR (10)  NOT NULL,
    [TypeGroup]           NVARCHAR (25) NOT NULL,
    [TypeGroupOrder]      INT           NOT NULL,
    [TypeDescriptionSQL]  NVARCHAR (50) NULL,
    [TypeDescriptionUser] NVARCHAR (50) NULL,
    [TypeOrder]           BIGINT        NULL,
    [TypeCount]           INT           NULL,
    [UserModeFlag]        BIT           NULL,
    CONSTRAINT [PK_ObjectDocumentation] PRIMARY KEY CLUSTERED ([TypeCode] ASC)
);



