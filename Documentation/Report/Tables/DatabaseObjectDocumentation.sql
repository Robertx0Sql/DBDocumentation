﻿CREATE TABLE [Report].[DatabaseObjectDocumentation](
	[DatabaseObjectDocumentationId] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
	[DatabaseName] [nvarchar](128) NOT NULL,
	[TypeGroup] [nvarchar](25) NULL,
	[TypeCode] [varchar](10) NULL,
	[TypeDescriptionUser] [nvarchar](50) NULL,
	[TypeDescriptionSQL] [nvarchar](50) NULL,
	[SchemaName] [nvarchar](128) NULL,
	[ObjectName] [nvarchar](255) NULL,
	[DocumentationDescription] [nvarchar](max) NULL,
	[TypeGroupOrder] [int] NULL,
	[TypeOrder] [bigint] NULL,
	[TypeCount] [int] NULL,
	[DocumentationLoadDate] [datetime2](7) NOT NULL,
	[QualifiedFullName] [nvarchar](517) NULL,
	[ParentObjectName] [nvarchar](255) NULL,
	[ParentSchemaName] [nvarchar](128) NULL,
	[ParentTypeCode] [varchar](10) NULL,
	[ParentObjectType] [varchar](10) NULL,
	[fields] [nvarchar](max) NULL,
	[Definition] [nvarchar](max) NULL,
	[UserModeFlag] [bit] NULL,
	[CodeFlag] [int] NULL,
	[StagingId] [int] NOT NULL,
	[parentStagingId] [int] NULL
	CONSTRAINT [PK_Report_DatabaseObjectDocumentation] PRIMARY KEY CLUSTERED ([DatabaseObjectDocumentationId] ASC)
);
