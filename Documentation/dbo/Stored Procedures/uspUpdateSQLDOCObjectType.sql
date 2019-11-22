CREATE PROCEDURE [dbo].[uspUpdateSQLDOCObjectType]
AS
BEGIN
	SET NOCOUNT ON

	MERGE INTO [dbo].[SQLDOCObjectType] AS DST
	USING [dbo].[vwObjectTypeList] AS SRC
		ON SRC.[TypeCode] = DST.[TypeCode]
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				[TypeGroup]
				,[TypeGroupOrder]
				,[TypeCode]
				,[TypeDescriptionSQL]
				,[TypeDescriptionUser]
				,[SMOObjectType]
				,[TypeOrder]
				,[TypeCount]
				,[UserModeFlag]
				)
			VALUES (
				SRC.[TypeGroup]
				,SRC.[TypeGroupOrder]
				,SRC.[TypeCode]
				,SRC.[TypeDescriptionSQL]
				,SRC.[TypeDescriptionUser]
				,SRC.[SMOObjectType]
				,SRC.[TypeOrder]
				,SRC.[TypeCount]
				,SRC.[UserModeFlag]
				)
	WHEN MATCHED
		AND EXISTS (
			SELECT SRC.[TypeGroup]
				,SRC.[TypeGroupOrder]
				,SRC.[TypeCode]
				,SRC.[TypeDescriptionSQL]
				,SRC.[TypeDescriptionUser]
				,SRC.[SMOObjectType]
				,SRC.[TypeOrder]
				,SRC.[TypeCount]
				,SRC.[UserModeFlag]
			
			EXCEPT
			
			SELECT DST.[TypeGroup]
				,DST.[TypeGroupOrder]
				,DST.[TypeCode]
				,DST.[TypeDescriptionSQL]
				,DST.[TypeDescriptionUser]
				,DST.[SMOObjectType]
				,DST.[TypeOrder]
				,DST.[TypeCount]
				,DST.[UserModeFlag]
			)
		THEN
			UPDATE
			SET DST.[TypeGroup] = SRC.TypeGroup
				,DST.[TypeGroupOrder] = SRC.TypeGroupOrder
				,DST.[TypeCode] = SRC.TypeCode
				,DST.[TypeDescriptionSQL] = SRC.TypeDescriptionSQL
				,DST.[TypeDescriptionUser] = SRC.TypeDescriptionUser
				,DST.[SMOObjectType] = SRC.[SMOObjectType]
				,DST.[TypeOrder] = SRC.TypeOrder
				,DST.[TypeCount] = SRC.TypeCount
				,DST.[UserModeFlag] = SRC.UserModeFlag
	WHEN NOT MATCHED BY SOURCE
		THEN
			DELETE;

	DECLARE @mergeError INT
		,@mergeCount INT;

	SELECT @mergeError = @@ERROR
		,@mergeCount = @@ROWCOUNT;

	IF @mergeError != 0
	BEGIN
		PRINT 'ERROR OCCURRED IN MERGE FOR [SQLDOCObjectType]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100));-- SQL should always return zero rows affected
	END;
	ELSE
	BEGIN
		PRINT '[SQLDOCObjectType] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
	END;
END