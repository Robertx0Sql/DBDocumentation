
CREATE PROCEDURE [uspUpdateSQLDOCObjectType]
AS
BEGIN
	SET NOCOUNT ON


	MERGE INTO [SQLDOCObjectType] AS [Target]
	USING dbo.[vwObjectTypeList]  AS [Source] 

	ON ([Target].[TypeCode] = [Source].[TypeCode])
	WHEN MATCHED AND (
		NULLIF([Source].[TypeGroup], [Target].[TypeGroup]) IS NOT NULL OR NULLIF([Target].[TypeGroup], [Source].[TypeGroup]) IS NOT NULL OR 
		NULLIF([Source].[TypeGroupOrder], [Target].[TypeGroupOrder]) IS NOT NULL OR NULLIF([Target].[TypeGroupOrder], [Source].[TypeGroupOrder]) IS NOT NULL OR 
		NULLIF([Source].[TypeDescriptionSQL], [Target].[TypeDescriptionSQL]) IS NOT NULL OR NULLIF([Target].[TypeDescriptionSQL], [Source].[TypeDescriptionSQL]) IS NOT NULL OR 
		NULLIF([Source].[TypeDescriptionUser], [Target].[TypeDescriptionUser]) IS NOT NULL OR NULLIF([Target].[TypeDescriptionUser], [Source].[TypeDescriptionUser]) IS NOT NULL OR 
		NULLIF([Source].[TypeOrder], [Target].[TypeOrder]) IS NOT NULL OR NULLIF([Target].[TypeOrder], [Source].[TypeOrder]) IS NOT NULL OR 
		NULLIF([Source].[TypeCount], [Target].[TypeCount]) IS NOT NULL OR NULLIF([Target].[TypeCount], [Source].[TypeCount]) IS NOT NULL) THEN
	 UPDATE SET
	  [Target].[TypeGroup] = [Source].[TypeGroup], 
	  [Target].[TypeGroupOrder] = [Source].[TypeGroupOrder], 
	  [Target].[TypeDescriptionSQL] = [Source].[TypeDescriptionSQL], 
	  [Target].[TypeDescriptionUser] = [Source].[TypeDescriptionUser], 
	  [Target].[TypeOrder] = [Source].[TypeOrder], 
	  [Target].[TypeCount] = [Source].[TypeCount]
	WHEN NOT MATCHED BY TARGET THEN
	 INSERT([TypeGroup],[TypeGroupOrder],[TypeCode],[TypeDescriptionSQL],[TypeDescriptionUser],[TypeOrder],[TypeCount])
	 VALUES([Source].[TypeGroup],[Source].[TypeGroupOrder],[Source].[TypeCode],[Source].[TypeDescriptionSQL],[Source].[TypeDescriptionUser],[Source].[TypeOrder],[Source].[TypeCount])
	WHEN NOT MATCHED BY SOURCE THEN 
	 DELETE;

	DECLARE @mergeError INT
	,@mergeCount INT

	SELECT @mergeError = @@ERROR
		,@mergeCount = @@ROWCOUNT

	IF @mergeError != 0
	BEGIN
		PRINT 'ERROR OCCURRED IN MERGE FOR [SQLDOCObjectType]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100));-- SQL should always return zero rows affected
	END
	ELSE
	BEGIN
		PRINT '[SQLDOCObjectType] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
	END

END