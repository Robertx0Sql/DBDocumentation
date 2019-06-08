
CREATE PROCEDURE [dbo].[upSqlDocDatabaseColumns] 
	@Server VARCHAR(255) 
	,@DatabaseName VARCHAR(255) 
	,@Schema  VARCHAR(255) =NULL
	,@Object VARCHAR(255) =NULL
	
AS
SELECT 
	[ServerName]
	,[DatabaseName]
	,[TypeCode]
	,[TypeDescriptionUser] 
	,[TableSchemaName]
	,[TableName]
	,[name]
	,[DocumentationDescription]
	,[column_id]
	
	, [datatype]  
	+ iif([is_identity]=1, 
		' identity(' + CAST(ISNULL([ident_col_seed_value], 1)  AS VARCHAR(10)) 
		+','
		+ CAST(ISNULL([ident_col_increment_value], 1) AS VARCHAR(10))
		+ ')'
	,'' ) 
	+ iif([datatype]   LIKE '%char%' ,'('+ 
	
		CASE 
			WHEN [max_length]  =-1 THEN 'max' 
		WHEN LEFT([datatype] ,1)='n' THEN CAST( CAST([max_length] /2.0 AS INT )  AS VARCHAR(10))
		ELSE 
			CAST( [max_length] AS VARCHAR(10))
		END 	
		+')' , '')  	AS [datatype]  
	 , 	
	 	CASE 
		WHEN [datatype]  ='uniqueidentifier' then '36'
		WHEN [max_length]  =-1 THEN 'max' 
		WHEN LEFT([datatype] ,1)='n' and [datatype]  LIKE '%char%'  THEN CAST( CAST([max_length] /2.0 AS INT )  AS VARCHAR(10))
			WHEN [datatype]  LIKE '%char%'   then CAST( [max_length] AS VARCHAR(10))
		ELSE 
			CAST( iif([precision] > [max_length] , [precision], [max_length] ) AS VARCHAR(10))
		END 	
		  AS [length]
	,[collation_name]
	,CAST(iif([is_nullable]=1 , 'yes', 'no') AS VARCHAR(3)) AS nulls
	,CAST(iif([is_computed]=1 , 'yes', 'no') AS VARCHAR(3)) AS computed
	,[Column_Default]
	,CAST(iif(PK =1, iif(SUM(CAST(PK AS INT))  OVER (PARTITION BY 
												[TypeDescriptionUser]
												,[ServerName]
												,[DatabaseName]
												,[TableSchemaName]
												,[TableName]) > 1 , 'composite PK' , 'yes' ), NULL) AS VARCHAR(25) ) AS [PK]
	,[FK_NAME]
	,[ReferencedTableObject_id]
	,[ReferencedTableSchemaName]
	,[ReferencedTableName]
	,[referenced_column]

	,[ReferencedTableName] + '.' + [referenced_column] AS FK 
	,'Table' as ReferencedObjectType 
	, iif([FK_NAME] is NOT null, 'yes', NULL)  as isFK
FROM [dbo].[vwColumnDoc]
WHERE [name] IS NOT NULL
	AND DatabaseName = @DatabaseName
	AND SERVERNAME = @Server
	AND (
		(
			[TableSchemaName] = @Schema
			AND [TableName] = @Object
			)
		OR (
			@Schema IS NULL
			AND @Object IS NULL
			)
		);