




CREATE VIEW [dbo].[vwObjectType] 
AS
SELECT T.TypeGroup
	,T.TypeGroupOrder
	,T.[TypeCode]
	,T.[TypeDescriptionSQL]
	,T.[TypeDescriptionUser]
	,TypeOrder 
	,TypeCount 
	, UserModeFlag 
FROM [dbo].[SQLDOCObjectType] T