

CREATE VIEW [dbo].[vwObjectTypeList] 
AS
SELECT TG.TypeGroup
	,TG.TypeGroupOrder
	,T.[TypeCode]
	,T.[TypeDescriptionSQL]
	,T.[TypeDescriptionUser]
	,T.SMOObjectType
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
		 ('AF', 'AGGREGATE_FUNCTION', 'Aggregatefunction(CLR)', 'Aggregatefunction(CLR)', 'Other')
		,('C', 'CHECK_CONSTRAINT', 'CheckConstraint', 'Check', 'Constraints')
		,('D', 'DEFAULT_CONSTRAINT', 'DefaultConstraint', 'Default', 'Constraints')
		,('F', 'FOREIGN_KEY_CONSTRAINT', 'ForeignKeyConstraint', 'ForeignKey', 'Constraints')
		,('FN', 'SQL_SCALAR_FUNCTION', 'SQLScalarFunction', 'UserDefinedFunction', 'Functions')
		,('FS', 'CLR_SCALAR_FUNCTION', 'Assembly(CLR)scalar-function', 'Assembly(CLR)scalar-function', 'Functions')
		,('FT', 'CLR_TABLE_VALUED_FUNCTION', 'Assembly(CLR)table-valuedfunction', 'Assembly(CLR)table-valuedfunction', 'Functions')
		,('IF', 'SQL_INLINE_TABLE_VALUED_FUNCTION', 'SQLInlinetable-valuedfunction', 'UserDefinedFunction', 'Functions')
		,('IT', 'INTERNAL_TABLE', 'Internaltable', 'Table', 'Other')
		,('P', 'SQL_STORED_PROCEDURE', 'StoredProcedure', 'StoredProcedure', 'Procedures')
		,('PC', 'CLR_STORED_PROCEDURE', 'Assembly(CLR)stored-procedure', 'Assembly(CLR)stored-procedure', 'Procedures')
		,('PG', 'PLAN_GUIDE', 'Planguide', 'PlanGuide', 'Other')
		,('PK', 'PRIMARY_KEY_CONSTRAINT', 'PrimaryKeyConstraint', 'PrimaryKey', 'Indexes')
		,('R', 'RULE', 'Rule(old-style,stand-alone)', 'Rule', 'Other')
		,('RF', 'REPLICATION_FILTER_PROCEDURE', 'Replication-filter-procedure',NULL, 'Other')
		,('S', 'SYSTEM_TABLE', 'Systembasetable', 'SystemTable', 'Other')
		,('SN', 'SYNONYM', 'Synonym', 'Synonym', 'Other')
		,('SO', 'SEQUENCE_OBJECT', 'Sequenceobject', 'Sequenceobject', 'Other')
		,('SQ', 'SERVICE_QUEUE', 'ServiceQueue', 'ServiceQueue', 'Other')
		,('TA', 'CLR_TRIGGER', 'Assembly(CLR)DMLtrigger', 'Assembly(CLR)DMLtrigger', 'Other')
		,('TF', 'SQL_TABLE_VALUED_FUNCTION', 'SQLtable-valued-function', 'UserDefinedFunction', 'Functions')
		,('TR', 'SQL_TRIGGER', 'Trigger', 'Trigger', 'Triggers')
		,('TT', 'TABLE_TYPE', 'Table Type', 'UserDefinedTableType', 'Other')
		,('U', 'USER_TABLE', 'Table', 'Table', 'Tables')
		,('UQ', 'UNIQUE_CONSTRAINT', 'UniqueConstraint', 'UniqueConstraint', 'Constraints')
		,('V', 'VIEW', 'View', 'View', 'Views')
		,('X', 'EXTENDED_STORED_PROCEDURE', 'Extendedstoredprocedure', 'Extendedstoredprocedure', 'Procedures')
--non SQL Object types  
		,('UDDT','User_Defined_DataType','User Defined Data Type' ,'UserDefinedDataType' ,'Other')
		,('INDEX' , N'INDEX' , N'Index'  , N'Index'  , 'Indexes')
		,('SCHEMA' , N'Schema' , N'Schema'  , N'Schema'  , 'Other')
		,('ROLE' , N'ROLE' , N'Role'  , N'DatabaseRole'  , 'Other')

	)	AS T ([TypeCode], [TypeDescriptionSQL], [TypeDescriptionUser],SMOObjectType, TypeGroup)
ON tg.TypeGroup= T.TypeGroup;

