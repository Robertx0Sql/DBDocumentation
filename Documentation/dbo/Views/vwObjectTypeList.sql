﻿CREATE VIEW [dbo].[vwObjectTypeList] 
AS
SELECT TG.TypeGroup
	,TG.TypeGroupOrder
	,T.[TypeCode]
	,T.[TypeDescriptionSQL]
	,T.[TypeDescriptionUser]
	,TypeOrder =ROW_NUMBER() OVER (PARTITION BY TG.TypeGroup ORDER BY T.typeCode DESC)
	,TypeCount = COUNT(1) OVER (PARTITION BY TG.TypeGroup )
	,UserModeFlag
	 FROM 
(VALUES 
	( N'Tables' ,1,1)
	,( N'Views' ,2,1)  
	,( N'Procedures',3 ,0)
	,( N'Triggers' ,4,0)
	,( N'Functions' ,5,0)
	,( N'Constraints', 6,0)
	,( N'Indexes', 10,0)
	,( N'Other' ,99,0)
) AS TG (TypeGroup,TypeGroupOrder, UserModeFlag) 
LEFT JOIN 
	(VALUES 
		( N'U' , N'USER_TABLE' , N'Table'  ,N'Tables'  )
		,( N'V' , N'VIEW' , N'View'  , N'Views'  ) 
		,( N'P' , N'SQL_STORED_PROCEDURE' , N'Stored Procedure' ,'Procedures' )
		,( N'TR' , N'SQL_TRIGGER' , N'Trigger'  ,'Triggers' )
		,( N'FN' , N'SQL_SCALAR_FUNCTION' , N'SQL Scalar Function' ,'Functions' )
		,( N'TF' , N'SQL_TABLE_VALUED_FUNCTION' , N'SQL table-valued-function'  ,'Functions' )
		,( N'PK' , N'PRIMARY_KEY_CONSTRAINT' , N'Primary Key Constraint'  , 'Constraints')
		,( N'C' , N'CHECK_CONSTRAINT' , N'Check Constraint'  , 'Constraints')
		,( N'D' , N'DEFAULT_CONSTRAINT' , N'Default Constraint'  , 'Constraints')
		,( N'F' , N'FOREIGN_KEY_CONSTRAINT' , N'Foreign Key Constraint'  , 'Constraints')
		,( N'UQ' , N'UNIQUE_CONSTRAINT' , N'Unique Constraint'  , 'Constraints')
		,( N'INDEX' , N'INDEX' , N'Index'  , 'Indexes')
		,( N'SQ' , N'SERVICE_QUEUE' , N'Service Queue'  , 'Other')

		,( N'FS','CLR_SCALAR_FUNCTION','Assembly (CLR) scalar-function' , 'Functions')
		,( N'FT','CLR_TABLE_VALUED_FUNCTION','Assembly (CLR) table-valued function' , 'Functions')
		,( N'IF','SQL_INLINE_TABLE_VALUED_FUNCTION','SQL Inline table-valued function' , 'Functions')
		,( N'IT','INTERNAL_TABLE','Internal table' , 'Other')
	
		,( N'SN','SYNONYM','Synonym' , 'Other')
		,(	'TT'	,'TABLE_TYPE'	,'Table type',  'Other')
		,( N'PC','CLR_STORED_PROCEDURE','Assembly (CLR) stored-procedure' , 'Procedures')
		,(	'X'	,'EXTENDED_STORED_PROCEDURE'	,'Extended stored procedure'	, 'Procedures')

		,(	'S'	,'SYSTEM_TABLE'	,'System base table'	, 'Other')
		,(	'SO'	,'SEQUENCE_OBJECT'	,'Sequence object'	, 'Other')
		,(	'TA'	,'CLR_TRIGGER'	,'Assembly (CLR) DML trigger'	, 'Other')
		,(	'AF'	,'AGGREGATE_FUNCTION'	,'Aggregate function (CLR)'	, 'Other')

		,(	'R'	,'RULE'	,'Rule (old-style, stand-alone)'	, 'Other')
		,(	'RF'	,'REPLICATION_FILTER_PROCEDURE'	,'Replication-filter-procedure'	, 'Other')
		,(	'PG'	,'PLAN_GUIDE'	,'Plan guide'	, 'Other')

	)	AS T ([TypeCode], [TypeDescriptionSQL], [TypeDescriptionUser], TypeGroup)
ON tg.TypeGroup= T.TypeGroup;

