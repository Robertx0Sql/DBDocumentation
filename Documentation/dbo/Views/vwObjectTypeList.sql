



CREATE VIEW [dbo].[vwObjectTypeList] 
AS
SELECT TG.TypeGroup
	,TG.TypeGroupOrder
	,T.[TypeCode]
	,T.[TypeDescriptionSQL]
	,T.[TypeDescriptionUser]
	,TypeOrder =ROW_NUMBER() OVER (PARTITION BY TG.TypeGroup ORDER BY T.typeCode DESC)
	,TypeCount = Count(1) OVER (PARTITION BY TG.TypeGroup )
	 FROM 
(VALUES 
	( N'Tables' ,1)
	,( N'Views' ,2)  
	,( N'Procedures',3 )
	,( N'Triggers' ,4)
	,( N'Functions' ,5)
	,( N'Constraints', 6)
	,( N'Indexes', 10)
	,( N'Other' ,99)
) AS TG (TypeGroup,TypeGroupOrder) 
LEFT JOIN 
	(VALUES 
		( N'U' , N'USER_TABLE' , N'Table'  ,N'Tables'  )
		,( N'V' , N'VIEW' , N'View'  , N'Views'  ) 
		,( N'P' , N'SQL_STORED_PROCEDURE' , N'Stored Procedure' ,'Procedures' )
		,( N'TR' , N'SQL_TRIGGER' , N'Trigger'  ,'Triggers' )
		,( N'FN' , N'SQL_SCALAR_FUNCTION' , N'SQL Scalar Function' ,'Functions' )
		,( N'TF' , N'SQL_TABLE_VALUED_FUNCTION' , N'Table Valued Function'  ,'Functions' )
		,( N'PK' , N'PRIMARY_KEY_CONSTRAINT' , N'Primary Key Constraint'  , 'Constraints')
		,( N'C' , N'CHECK_CONSTRAINT' , N'Check Constraint'  , 'Constraints')
		,( N'D' , N'DEFAULT_CONSTRAINT' , N'Default Constraint'  , 'Constraints')
		,( N'F' , N'FOREIGN_KEY_CONSTRAINT' , N'Foreign Key Constraint'  , 'Constraints')
		,( N'UQ' , N'UNIQUE_CONSTRAINT' , N'Unique Constraint'  , 'Constraints')
		,( N'INDEX' , N'INDEX' , N'Index'  , 'Indexes')
		,( N'SQ' , N'SERVICE_QUEUE' , N'Service Queue'  , 'Other')
	)	AS T ([TypeCode], [TypeDescriptionSQL], [TypeDescriptionUser], TypeGroup)
ON tg.TypeGroup= T.TypeGroup;