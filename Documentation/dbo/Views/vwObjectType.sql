CREATE VIEW [dbo].[vwObjectType] 
AS
SELECT T.TypeGroup
	,T.TypeGroupOrder
	,T.[TypeCode]
	,T.[TypeDescriptionSQL]
	,T.[TypeDescriptionUser]
	,TypeOrder
	,TypeCount
	,UserModeFlag
	,CASE 
		WHEN T.TypeGroup IN (
				'Functions'
				,'Procedures'
				,'Triggers'
				,'Views'
				)
			THEN 1
		ELSE 0
		END AS CodeFlag
FROM [dbo].[SQLDOCObjectType] T