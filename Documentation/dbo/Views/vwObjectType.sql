
CREATE VIEW [dbo].[vwObjectType] 
AS
SELECT [TypeCode]
	,[TypeDescriptionSQL]
	,[TypeDescriptionUser]
	,TypeGroup
FROM (
VALUES 
	( N'C' , N'CHECK_CONSTRAINT' , N'Check Constraint'  , 'Constraints')
	,( N'D' , N'DEFAULT_CONSTRAINT' , N'Default Constraint'  , 'Constraints')
	,( N'F' , N'FOREIGN_KEY_CONSTRAINT' , N'Foreign Key Constraint'  , 'Constraints')
	,( N'FN' , N'SQL_SCALAR_FUNCTION' , N'SQL Scalar Function' ,'Functions' )
	,( N'P' , N'SQL_STORED_PROCEDURE' , N'Stored Procedure' ,'Procedures' )
	,( N'PK' , N'PRIMARY_KEY_CONSTRAINT' , N'Primary Key Constraint'  , 'Constraints')
	,( N'SQ' , N'SERVICE_QUEUE' , N'Service Queue'  , 'Other')
	,( N'TF' , N'SQL_TABLE_VALUED_FUNCTION' , N'Table Valued Function'  ,'Functions' )
	,( N'TR' , N'SQL_TRIGGER' , N'Trigger'  ,'Triggers' )
	,( N'U' , N'USER_TABLE' , N'Table'  ,N'Tables'  )
	,( N'UQ' , N'UNIQUE_CONSTRAINT' , N'Unique Constraint'  , 'Constraints')
	,( N'V' , N'VIEW' , N'View'  , N'Views'  ) 
)
AS T ([TypeCode], [TypeDescriptionSQL], [TypeDescriptionUser], TypeGroup);