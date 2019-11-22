[CmdletBinding()]
param(
    [string]$ServerSource = "(local)"
    , [string]$DatabaseSource = "AdventureWorks2017"
    , [string]$SqlServerDoc = "."
    , [string]$SqlDatabaseDoc = "Documentation"
    , [PSCredential]$Credential 
)

$extentedPropertyName = "MS_Description"
$SQLConnectionString = "Data Source={0};Initial Catalog={1};Integrated Security=SSPI;" -f $SqlServerDoc, $SqlDatabaseDoc

Write-Host "==================================================================================="
Write-Host "ServerSource $ServerSource"
Write-Host "DatabaseSource $DatabaseSource"
Write-Host "SqlServerDoc $SqlServerDoc"
Write-Host "SqlDatabaseDoc $SqlDatabaseDoc"
Write-Host "==================================================================================="

function Get-ServerInstance($ServerInstance , $Database ) {
    $query = "SELECT @@SERVERNAME AS ServerName ,DB_NAME() AS DatabaseName "
    if ($null -ne $Credential )
    { $QueryResult = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database  -Query $query -OutputAs DataTables -Credential $Credential }
    else
    { $QueryResult = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database  -Query $query -OutputAs DataTables }
	
    if ($null -eq $QueryResult) {
        Write-Error "QueryResult is null"
    }
    return $QueryResult[0].rows[0].ServerName
}



function Save-QueryResult ($ServerInstance , $Database  , $Query , $SQLConnectionString, $Procedure, $ProcedureParamName) {
    Write-Verbose "==================================================================================="
    Write-Verbose "ServerInstance $ServerInstance"
    Write-Verbose "Database $Database"
    Write-Verbose "SQLConnectionString $SQLConnectionString"
    Write-Verbose "Procedure $Procedure"
    Write-Verbose "ProcedureParamName $ProcedureParamName"
    Write-Verbose "==================================================================================="
	
    if ($null -ne $Credential )
    { $QueryResult = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database  -Query $query -OutputAs DataTables -Credential $Credential }
    else
    { $QueryResult = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database  -Query $query -OutputAs DataTables }
	
    #$QueryResult = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database  -Query $Query -OutputAs DataTables -Credential $Credential
    Save-DoctoDb $SQLConnectionString  -Procedure  $Procedure  -ProcedureParamName $ProcedureParamName  -ProcedureParamValue $QueryResult
}

function Save-DoctoDb($SQLConnectionString, $Procedure, $ProcedureParamName, $ProcedureParamValue) {
    #nvoke-SqlCmd does not support passing complex objects. need to use a System.Data.SQLClient.SQLCommand object
    # https://social.technet.microsoft.com/Forums/en-US/9ed5b002-962e-4e07-a57c-0be2b87abe3c/invokesqlcmd-custom-table-as-parameter?forum=winserverpowershell
    #$SQLConnectionString

    $SQLConn = new-object System.Data.SQLClient.SQLConnection
    $SQLConn.ConnectionString = $SQLConnectionString
    $SQLConn.Open()

    $SQLCmd = New-object System.Data.SQLClient.SQLCommand
    $SQLCmd.CommandText = $Procedure #"[dbo].[usp_ColumnDocUpdate]"
    $SQLCmd.CommandType = [System.Data.CommandType]::StoredProcedure
    $SQLCmd.Connection = $SQLConn
    $SQLCmd.Parameters.AddWithValue($ProcedureParamName, $ProcedureParamValue) | Out-Null
    $SQLCmd.ExecuteNonQuery() | Out-Null
	
    $SQLconn.Close()
    Write-Verbose  "$($ProcedureParamValue.Rows.Count) rows added /updated for $Procedure"
}  
function Save-AutoMapForeignKeys($ServerInstance , $Database, $SQLConnectionString)
{ 

    $SQLConn = new-object System.Data.SQLClient.SQLConnection
    $SQLConn.ConnectionString = $SQLConnectionString
    $SQLConn.Open()

    $SQLCmd = New-object System.Data.SQLClient.SQLCommand
	$SQLCmd.CommandText = "[dbo].[uspUpdateSQLDOCAutoMapFK]"
	$SQLCmd.CommandType = [System.Data.CommandType]::StoredProcedure
    $SQLCmd.Connection = $SQLConn
    $SQLCmd.Parameters.AddWithValue("@Server", $ServerInstance ) | Out-Null
    $SQLCmd.Parameters.AddWithValue("@Database", $Database ) | Out-Null
    $SQLCmd.ExecuteNonQuery() | Out-Null
	
    $SQLconn.Close()
	
}

function Get-SQLDOCReferencedObjectQuery($extentedPropertyName) {
    $query = @"
	WITH CTE AS (
		SELECT 
			OBJECT_schema_NAME(referencing_id) AS referencing_schema_name
			,OBJECT_NAME(referencing_id) AS referencing_entity_name
			,o.type AS referencingTypeCode
			,referenced_server_name
			,referenced_database_name
			,iif(tt.is_table_type=1, 'TT', ref.type )  AS referencedTypeCode
			,coalesce(referenced_schema_name, object_schema_name(referenced_id), schema_name(tt.schema_id)) AS referenced_schema_name
			,referenced_entity_name
	
		FROM sys.sql_expression_dependencies AS sed
		INNER JOIN sys.objects AS o
			ON sed.referencing_id = o.object_id
		left outer join  sys.objects ref on ref.object_id= sed.referenced_id
		left outer join sys.table_types tt on tt.user_type_id =sed.referenced_id and tt.is_table_type=1

		UNION ALL

		SELECT 
			coalesce(X.referencing_schema_name, OBJECT_SCHEMA_NAME(t.object_id)) as referencing_schema_name
			,X.referencing_entity_name
			,so.type AS referencingTypeCode
			,NULL AS referenced_server_name
			,NULL AS referenced_database_name
			,t.type AS referencedTypeCode
			,OBJECT_SCHEMA_NAME(t.object_id) AS referenced_schema_name
			,OBJECT_NAME(t.object_id) AS referenced_entity_name
		FROM sys.tables t
		CROSS APPLY sys.dm_sql_referencing_entities(quotename(OBJECT_SCHEMA_NAME(t.object_id)) + '.' + Quotename(OBJECT_NAME(t.object_id)), 'OBJECT') X
		LEFT JOIN sys.objects so
			ON so.name = X.referencing_entity_name
				AND schema_name(so.schema_id) = X.referencing_schema_name
	
	)
	SELECT DISTINCT 
		 @@SERVERNAME AS ServerName
		,DB_NAME() AS DatabaseName
		,X.referencing_schema_name
		,X.referencing_entity_name
		,referencingTypeCode
		,referenced_server_name
		,referenced_database_name
		,referencedTypeCode
		,referenced_schema_name
		,referenced_entity_name
	 FROM CTE X ;

"@
    return  $query
}
function  SQLDocColumnQuery ($extentedPropertyName) {
    $queryColumns = @"
	SELECT 
		@@SERVERNAME AS SERVERNAME
		,DB_NAME() AS DatabaseName
		,[ObjectType] = obj.TYPE
		,object_schema_name(C.OBJECT_ID) AS [SchemaName]
		,OBJECT_NAME(c.OBJECT_ID) AS [ObjectName]
		,c.name
		,c.column_id
		,t.name AS datatype
		,c.max_length
		,c.PRECISION
		,c.scale
		,c.collation_name
		,c.is_nullable
		,c.is_identity
		,c.is_computed
		,ic.is_primary_key
		,CAST(ident_col.seed_value AS INT) AS ident_col_seed_value
		,CAST(ident_col.increment_value AS INT) AS ident_col_increment_value
		,object_definition(c.default_object_id) AS Column_Default
		,CAST(p.value AS NVARCHAR(MAX)) AS DocumentationDescription
	FROM sys.columns AS c
	INNER JOIN sys.objects obj
		ON obj.OBJECT_ID = c.OBJECT_ID
	LEFT JOIN sys.types t
		ON t.user_type_id = c.user_type_id
	LEFT JOIN sys.identity_columns ident_col
		ON c.OBJECT_ID = ident_col.OBJECT_ID
			AND c.column_id = ident_col.column_id
	LEFT JOIN (
		SELECT ic.OBJECT_ID
			,ic.column_id
			,is_primary_key
		FROM sys.index_columns ic
		LEFT JOIN sys.indexes AS i
			ON i.OBJECT_ID = ic.OBJECT_ID
				AND i.index_id = ic.index_id
		WHERE is_primary_key = 1
		) ic
		ON ic.OBJECT_ID = c.OBJECT_ID
			AND ic.column_id = c.column_id
	LEFT JOIN sys.extended_properties AS p
		ON p.major_id = c.OBJECT_ID
			AND p.minor_id = c.column_id
			AND p.CLASS = 1
			AND p.name = 'MS_Description'
	WHERE obj.TYPE IN ('U','V')


	UNION ALL -- parameters

	SELECT  
		@@SERVERNAME AS SERVERNAME
		,DB_NAME() AS DatabaseName
		,[objectType] =sp.TYPE

		,object_schema_name(sp.OBJECT_ID) AS [TableSchemaName]
		,OBJECT_NAME(sp.OBJECT_ID) AS [TableName]
		,par.name
		,par.parameter_id
		,t.name AS datatype
		,par.max_length
		,par.PRECISION
		,par.scale
		,NULL AS collation_name
		,0 AS is_nullable
		,0 AS is_identity
		,0 AS is_computed
		,0 AS is_primary_key
		,0 AS ident_col_seed_value 
		,0 AS ident_col_increment_value 
		,NULL AS Column_Default 
		,CAST(p.value AS NVARCHAR(MAX) ) AS DocumentationDescription
	FROM
	sys.all_objects AS sp
	INNER JOIN sys.PARAMETERS par ON sp.OBJECT_ID = par.OBJECT_ID
	LEFT JOIN sys.types t ON t.user_type_id = par.user_type_id
	LEFT JOIN sys.extended_properties AS p ON p.major_id=sp.OBJECT_ID AND p.CLASS=2
			AND p.minor_id = par.parameter_id
			AND p.name =  'MS_Description'
	WHERE par.name!=''
	
	UNION ALL

	SELECT 
		@@SERVERNAME AS SERVERNAME
		,DB_NAME() AS DatabaseName
		,[ObjectType] = 'TT'
		,schema_name(tt.schema_id)  AS [SchemaName]
		,tt.name AS OBJECTName
		,c.name
		,c.column_id
		,t.name AS datatype
		,c.max_length
		,c.PRECISION
		,c.scale
		,c.collation_name
		,NULL AS is_nullable
		,NULL AS is_identity
		,NULL AS is_computed
		,NULL AS is_primary_key
		,NULL AS ident_col_seed_value
		,NULL AS ident_col_increment_value
		,NULL AS Column_Default
		,CAST(p.value AS NVARCHAR(MAX)) AS DocumentationDescription
	FROM sys.table_types tt
	INNER JOIN sys.columns c
		ON c.object_id = tt.type_table_object_id
	LEFT JOIN sys.types t
		ON t.user_type_id = c.user_type_id
	LEFT JOIN sys.extended_properties AS p
		ON p.major_id = c.OBJECT_ID
			AND p.minor_id = c.column_id
			AND p.CLASS = 1
			AND p.name = 'MS_Description'

	; 
"@
    return  $queryColumns

}
function Get-SQLDOCObjectQuery($extentedPropertyName) {
	$query = @"
SELECT 
	@@SERVERNAME AS ServerName
	,DB_NAME() AS DatabaseName
	,[objectType] = c.TYPE
	,object_schema_name(ISNULL(NULLIF(c.parent_object_id, 0), C.OBJECT_ID)) AS [ParentSchemaName]
	,OBJECT_NAME(ISNULL(NULLIF(c.parent_object_id, 0), C.OBJECT_ID)) AS [ParentObjectName]
	,object_schema_name(C.OBJECT_ID) AS [SchemaName]
	,OBJECT_NAME(c.OBJECT_ID) AS OBJECTNAME
	,iif(c.type = 'U', NULL, COALESCE(pk.fields, ic.fields, fk.fields, dcon.fields, ccon.fields)) AS fields
	,COALESCE(dcon.DEFINITION, ccon.DEFINITION) AS DEFINITION
	,CAST(p.value AS NVARCHAR(MAX)) AS DocumentationDescription
FROM sys.objects AS c
LEFT JOIN sys.extended_properties AS p
	ON p.major_id = c.OBJECT_ID
	AND p.CLASS = 1
	AND p.minor_id = 0
	AND p.name =  'MS_Description'
LEFT JOIN /*PK fields*/
	(
	SELECT ic.object_id --tab.object_id
		,pk.index_id
		,pk.[name] AS pk_name
		,fields = COALESCE(STUFF((
					SELECT ', ' + COL_NAME(t.OBJECT_ID, t.column_id)
					FROM sys.index_columns AS T
					WHERE T.OBJECT_ID = IC.OBJECT_ID
					FOR XML PATH('')
					), 1, 2, N''), N'')
	FROM sys.tables tab
	INNER JOIN sys.indexes pk
		ON tab.object_id = pk.object_id
			AND pk.is_primary_key = 1
	INNER JOIN sys.index_columns ic
		ON ic.object_id = pk.object_id
			AND ic.index_id = pk.index_id
	GROUP BY ic.object_id
		,pk.index_id
		,pk.[name]
	) pk
	ON pk.object_id = c.parent_object_id
		AND pk.pk_name = OBJECT_NAME(c.OBJECT_ID)
LEFT JOIN /*index_columns*/ (
	SELECT O.OBJECT_ID
		,fields = COALESCE(STUFF((
					SELECT ', ' + COL_NAME(t.OBJECT_ID, t.column_id)
					FROM sys.index_columns AS T
					WHERE T.OBJECT_ID = O.OBJECT_ID
					FOR XML PATH('')
					), 1, 2, N''), N'')
	FROM sys.index_columns O
	LEFT JOIN sys.indexes AS i
		ON i.OBJECT_ID = O.OBJECT_ID
		AND i.index_id = O.index_id
	GROUP BY O.OBJECT_ID
	) ic
	ON ic.OBJECT_ID = c.OBJECT_ID /*index_columns*/
LEFT JOIN /*foreign_key_columns*/(
	SELECT O.constraint_object_id
		,fields = COALESCE(STUFF((
					SELECT ', ' + COL_NAME(t.parent_object_id, t.parent_column_id)
					FROM sys.foreign_key_columns AS T
					WHERE T.constraint_object_id = O.constraint_object_id
					FOR XML PATH('')
					), 1, 2, N''), N'')
	FROM sys.foreign_key_columns O
	GROUP BY O.constraint_object_id
	) fk
	ON fk.constraint_object_id = c.OBJECT_ID /*foreign_key_columns*/
LEFT JOIN /*default_constraints*/ (
	SELECT O.OBJECT_ID
		,O.DEFINITION
		,fields = COALESCE(STUFF((
					SELECT ', ' + COL_NAME(t.parent_object_id, t.parent_column_id)
					FROM sys.default_constraints AS T
					WHERE T.OBJECT_ID = O.OBJECT_ID
						AND t.DEFINITION = O.DEFINITION
					FOR XML PATH('')
					), 1, 2, N''), N'')
	FROM sys.default_constraints O
	GROUP BY O.OBJECT_ID
		,O.DEFINITION
	) dcon
	ON dcon.OBJECT_ID = c.OBJECT_ID /*default_constraints*/
LEFT JOIN /*check_constraints*/ (
	SELECT O.OBJECT_ID
		,O.DEFINITION
		,fields = COALESCE(STUFF((
					SELECT ', ' + COL_NAME(t.parent_object_id, t.parent_column_id)
					FROM sys.check_constraints AS T
					WHERE T.OBJECT_ID = O.OBJECT_ID
						AND t.DEFINITION = O.DEFINITION
					FOR XML PATH('')
					), 1, 2, N''), N'')
	FROM sys.check_constraints O
	GROUP BY O.OBJECT_ID
		,O.DEFINITION
	) ccon
	ON ccon.OBJECT_ID = c.OBJECT_ID /*check_constraints*/
WHERE c.TYPE NOT IN ('S', 'IT', 'TT','SQ')


UNION ALL

SELECT 
	@@SERVERNAME AS ServerName
	,DB_NAME() AS DatabaseName
	,[objectType] = 'INDEX'
	,object_schema_name(ISNULL(NULLIF(so.parent_object_id, 0), so.OBJECT_ID)) AS [ParentSchemaName]
	,OBJECT_NAME(ISNULL(NULLIF(so.parent_object_id, 0), so.OBJECT_ID)) AS [ParentObjectName]
	,NULL--object_schema_name(so.OBJECT_ID) AS [SchemaName]
	,ix.name AS OBJECTNAME
	,fields
	,concat (lower(ix.type_desc) collate SQL_Latin1_General_CP1_CI_AS
		,iif(ix.is_unique =1, ', unique','')
		,iif(ix.is_unique_constraint =1, ', unique constraint','')
		,iif(ix.is_primary_key =1, ', primary key','')
		,' located on ', ds.name collate SQL_Latin1_General_CP1_CI_AS)  as Definition
	,CAST(ep.value AS NVARCHAR(MAX)) AS DocumentationDescription
FROM sys.tables so
INNER JOIN sys.indexes ix ON so.object_id = ix.object_id
LEFT JOIN sys.data_spaces ds 
	ON ds.data_space_id = ix.data_space_id
LEFT JOIN sys.extended_properties ep ON ep.major_id = ix.OBJECT_ID
	AND CLASS = 7
	AND ep.minor_id = ix.index_id
	AND Ep.name =  'MS_Description'
LEFT JOIN (
	SELECT O.OBJECT_ID, O.index_id
		,fields = COALESCE(STUFF((
					SELECT ', ' + COL_NAME(t.OBJECT_ID, t.column_id)
					FROM sys.index_columns AS T
					WHERE T.OBJECT_ID = O.OBJECT_ID
					FOR XML PATH('')
					), 1, 2, N''), N'')
	FROM sys.index_columns O
	GROUP BY O.OBJECT_ID, O.index_id

	) ic
	ON ic.object_id = ix.object_id
		AND ic.index_id = ix.index_id

	UNION ALL

	SELECT 
		@@SERVERNAME AS ServerName
		,DB_NAME() AS DatabaseName
		,[objectType] = 'TT'
		,schema_name(t.schema_id) AS [ParentSchemaName]
		,t.name AS [ParentObjectName]
		,schema_name(t.schema_id)  AS [SchemaName]
		,t.name AS OBJECTName
		,NULL AS fields
		,NULL AS DEFINITION
		,CAST(p.value AS NVARCHAR(MAX)) AS DocumentationDescription
	from sys.types t

	LEFT JOIN sys.extended_properties AS p ON p.major_id = t.user_type_id
		AND p.CLASS = 6
		AND p.minor_id = 0
		AND p.name =  'MS_Description'

	where is_table_type=1
		;
"@
	return $query
}
function Get-SQLDOCObjectQuery2017($extentedPropertyName) {
    $query = @"
	SELECT 
		@@SERVERNAME AS ServerName
		,DB_NAME() AS DatabaseName
		,[objectType] = c.TYPE
		,object_schema_name(ISNULL(NULLIF(c.parent_object_id, 0), C.OBJECT_ID)) AS [ParentSchemaName]
		,OBJECT_NAME(ISNULL(NULLIF(c.parent_object_id, 0), C.OBJECT_ID)) AS [ParentObjectName]
		,object_schema_name(C.OBJECT_ID) AS [SchemaName]
		,OBJECT_NAME(c.OBJECT_ID) AS OBJECTNAME
		,COALESCE(ic.fields, fk.fields, dcon.fields, ccon.fields) AS fields
		,COALESCE(dcon.DEFINITION, ccon.DEFINITION) AS DEFINITION
		,CAST(p.value AS NVARCHAR(MAX)) AS DocumentationDescription
	FROM sys.objects AS c
	LEFT JOIN sys.extended_properties AS p ON p.major_id = c.OBJECT_ID
		AND p.CLASS = 1
		AND p.minor_id = 0
		AND p.name =  'MS_Description'
	LEFT JOIN (
		SELECT ic.OBJECT_ID
			,STRING_AGG(COL_NAME(ic.OBJECT_ID, ic.column_id), ', ') AS fields
		FROM sys.index_columns ic
		LEFT JOIN sys.indexes AS i ON i.OBJECT_ID = ic.OBJECT_ID
			AND i.index_id = ic.index_id
		GROUP BY ic.OBJECT_ID
		) ic ON ic.OBJECT_ID = c.OBJECT_ID
	LEFT JOIN (
		SELECT constraint_object_id
			,STRING_AGG(COL_NAME(fkc.parent_object_id, fkc.parent_column_id), ', ') AS fields
		FROM sys.foreign_key_columns fkc
		GROUP BY constraint_object_id
		) fk ON fk.constraint_object_id = c.OBJECT_ID
	LEFT JOIN (
		SELECT con.OBJECT_ID
			,con.DEFINITION
			,STRING_AGG(COL_NAME(con.parent_object_id, con.parent_column_id), ', ') AS fields
		FROM sys.default_constraints con
		GROUP BY con.OBJECT_ID
			,con.DEFINITION
		) dcon ON dcon.OBJECT_ID = c.OBJECT_ID
	LEFT JOIN (
		SELECT con.OBJECT_ID
			,con.DEFINITION
			,STRING_AGG(COL_NAME(con.parent_object_id, con.parent_column_id), ', ') AS fields
		FROM sys.check_constraints con
		GROUP BY con.OBJECT_ID
			,con.DEFINITION
		) ccon ON ccon.OBJECT_ID = c.OBJECT_ID
	WHERE c.TYPE NOT IN ('S', 'IT', 'SQ')

	UNION ALL
	
	SELECT 
		@@SERVERNAME AS ServerName
		,DB_NAME() AS DatabaseName
		,[objectType] = 'INDEX'
		,object_schema_name(ISNULL(NULLIF(so.parent_object_id, 0), so.OBJECT_ID)) AS [ParentSchemaName]
		,OBJECT_NAME(ISNULL(NULLIF(so.parent_object_id, 0), so.OBJECT_ID)) AS [ParentObjectName]
		,NULL--object_schema_name(so.OBJECT_ID) AS [SchemaName]
		,ix.name AS OBJECTNAME
		,fields
		,concat (lower(ix.type_desc) collate SQL_Latin1_General_CP1_CI_AS
			,iif(ix.is_unique =1, ', unique','')
			,iif(ix.is_unique_constraint =1, ', unique constraint','')
			,iif(ix.is_primary_key =1, ', primary key','')
			,' located on ', ds.name collate SQL_Latin1_General_CP1_CI_AS)  as Definition
		,CAST(ep.value AS NVARCHAR(MAX)) AS DocumentationDescription
	FROM sys.tables so
	INNER JOIN sys.indexes ix ON so.object_id = ix.object_id
	LEFT JOIN sys.data_spaces ds 
		ON ds.data_space_id = ix.data_space_id
	LEFT JOIN sys.extended_properties ep ON ep.major_id = ix.OBJECT_ID
		AND CLASS = 7
		AND ep.minor_id = ix.index_id
		AND Ep.name =  'MS_Description'
	LEFT JOIN (
		SELECT ic.OBJECT_ID
			,index_id
			,STRING_AGG(COL_NAME(ic.OBJECT_ID, ic.column_id), ', ') AS fields
		FROM sys.index_columns AS ic
		GROUP BY ic.OBJECT_ID
			,index_id
		) ic
		ON ic.object_id = ix.object_id
			AND ic.index_id = ix.index_id
		
	; 
"@
    return  $query
}

function Get-ViewColumnMapQuery($extentedPropertyName)
{

    $query = @"
	WITH CTE
		AS (
			SELECT vcu.VIEW_SCHEMA
				,vcu.VIEW_NAME
				,vcu.TABLE_SCHEMA
				,vcu.TABLE_NAME
				,c.COLUMN_NAME
				,c.ORDINAL_POSITION
				,count(1) OVER (
					PARTITION BY vcu.VIEW_SCHEMA
						,vcu.VIEW_NAME
						,c.ORDINAL_POSITION
					) AS SourceColumnCount
				,ROW_NUMBER() OVER (
					PARTITION BY vcu.VIEW_SCHEMA
						,vcu.VIEW_NAME
						,c.ORDINAL_POSITION 
					ORDER BY vcu.TABLE_SCHEMA
						,vcu.TABLE_NAME
						,c.COLUMN_NAME
					) AS matchid
			FROM INFORMATION_SCHEMA.VIEW_COLUMN_USAGE as vcu
			INNER JOIN INFORMATION_SCHEMA.COLUMNS as c 
				ON vcu.VIEW_NAME = c.TABLE_NAME
					AND vcu.COLUMN_NAME = c.COLUMN_NAME
			)
			SELECT 
			 @@SERVERNAME AS ServerName
			,DB_NAME() AS DatabaseName
			,VIEW_SCHEMA
			,VIEW_NAME
			,TABLE_SCHEMA
			,TABLE_NAME
			,COLUMN_NAME
			,ORDINAL_POSITION
			,iif(SourceColumnCount > 1, 1, 0) AS is_ambiguous
			,cast(NULL as nvarchar(max)) AS Expression
		FROM CTE
		WHERE matchid = 1
"@
    return $query
}
function SQLDatabaseInformation($extentedPropertyName) {
    $query = @"
SELECT @@SERVERNAME AS ServerName
	,DB_NAME() AS DatabaseName
	,is_auto_close_on
	,is_auto_shrink_on
	,is_in_standby
	,is_ansi_null_default_on
	,is_ansi_nulls_on
	,is_ansi_padding_on
	,is_ansi_warnings_on
	,is_arithabort_on
	,is_auto_create_stats_on
	,is_auto_update_stats_on
	,is_cursor_close_on_commit_on
	,is_fulltext_enabled
	,is_local_cursor_default
	,is_concat_null_yields_null_on
	,is_numeric_roundabort_on
	,is_quoted_identifier_on
	,is_recursive_triggers_on
	,is_published
	,is_subscribed
	,is_sync_with_backup
	,recovery_model_desc
	,snapshot_isolation_state_desc
	,collation_name
	,compatibility_level
	,create_date
	,CAST(ep.value AS NVARCHAR(MAX)) AS DocumentationDescription
FROM sys.databases db
LEFT JOIN sys.extended_properties ep
	ON ep.class = 0
	AND ep.name =  'MS_Description'
WHERE db.name = db_name()
"@
    return $query
}

function SQLColumnReference {
$query=@"
SELECT 
	@@SERVERNAME AS ServerName
	,DB_NAME() AS DatabaseName
	,object_schema_name(C.OBJECT_ID) AS [SchemaName]
	,OBJECT_NAME(c.OBJECT_ID) AS [ObjectName]
		,obj.type as ObjectType
	,c.name
	,c.column_id
	,fk_obj.name AS FK_NAME
	,object_schema_name(fkc.referenced_object_id) AS [ReferencedTableSchemaName]
	,OBJECT_NAME(fkc.referenced_object_id) AS [ReferencedTableName]
		,fk_parent.type as [ReferencedObjectType]
	,col2.name AS [referenced_column]
FROM sys.columns AS c
INNER JOIN sys.objects obj
	ON obj.OBJECT_ID = c.OBJECT_ID
LEFT JOIN sys.foreign_key_columns fkc
	ON c.column_id = fkc.parent_column_id
		AND c.OBJECT_ID = fkc.parent_object_id
LEFT JOIN sys.objects fk_obj
	ON fk_obj.OBJECT_ID = fkc.constraint_object_id
LEFT JOIN sys.columns col2
	ON col2.column_id = referenced_column_id
		AND col2.OBJECT_ID = fkc.referenced_object_id
	LEFT JOIN sys.objects fk_parent
		ON fk_parent.OBJECT_ID = fkc.referenced_object_id
WHERE fk_obj.name IS NOT NULL
"@
	return $query
}

function Save-SQLObjectCode($ServerSource, $DatabaseSource , [PSCredential]$Credential) {
    $Procedure = "[dbo].[usp_ObjectCodeUpdate]"
    $ProcedureParamName = "@TVPObjectCode"

    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
    $serverInstance = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $ServerSource 
    
    # $serverInstance.SetDefaultInitFields($true)
    # $serverInstance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], "PageVerify")

	$serverInstance.SetDefaultInitFields($true)
	$serverInstance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile], $false)


	$IncludeTypes = @(
		"Defaults",
		"ExtendedStoredProcedures"
        #,"FileGroups"
		,"PartitionFunctions","PartitionSchemes",
		"Roles","Rules"
        , "Schemas"
		,"StoredProcedures"
		,"Synonyms"
		,"UserDefinedAggregates","UserDefinedDataTypes","UserDefinedFunctions","UserDefinedTableTypes","UserDefinedTypes"
		,"Views"
		,"Triggers"
        , "Tables"
 	 ) #object you want do backup. 
    $ExcludeSchemas = @("sys", "Information_Schema")
    $so = new-object ('Microsoft.SqlServer.Management.Smo.ScriptingOptions')
	
	$so.ClusteredIndexes = $True;
	$so.ConvertUserDefinedDataTypesToBaseType = $false;
	$so.NonClusteredIndexes = $false
	$so.WithDependencies = $False
	$so.Indexes = $True   
	$so.DriAllConstraints = $True
	$so.Triggers = $True
	$so.FullTextIndexes = $True
	$so.NoCollation = $True
	$so.Bindings = $False
	$so.IncludeIfNotExists = $false;
	$so.ScriptBatchTerminator = $True;
	$so.ExtendedProperties = $false
	$so.DriNonClustered = $True
	$so.DriUniqueKeys = $True
	$so.DriDefaults = $True
	$so.DriAllConstraints = $True

    if ($null -ne $Credential) {
        $UserName = $Credential.UserName
        $UserPassword = $Credential.GetNetworkCredential().Password
        Write-Verbose "Connect via username $($UserName)"
        #This sets the connection to mixed-mode authentication
        $serverInstance.ConnectionContext.LoginSecure = $false;
	
        #This sets the login name
        $serverInstance.ConnectionContext.set_Login($UserName);
	
        #This sets the password
        $serverInstance.ConnectionContext.set_Password($UserPassword)  
	}
	

    $db = $serverInstance.databases[$DatabaseSource]
    #get the "proper names for the server and Database"
    $ServerSource = Get-ServerInstance -ServerInstance $ServerSource -Database $DatabaseSource


    $dt = New-Object System.Data.Datatable 
    $col1 = New-Object system.Data.DataColumn SERVERNAME, ([string])
    $col2 = New-Object system.Data.DataColumn DatabaseName, ([string])
    $col3 = New-Object system.Data.DataColumn SmoType, ([string])
	
    $col4 = New-Object system.Data.DataColumn SchemaName, ([string])
    $col5 = New-Object system.Data.DataColumn ObjectName, ([string])
    $col6 = New-Object system.Data.DataColumn sql, ([string])
	
    $dt.columns.add($col1)
    $dt.columns.add($col2)
    $dt.columns.add($col3)
    $dt.columns.add($col4)
    $dt.columns.add($col5)
    $dt.columns.add($col6)

    #$result =
    foreach ($Type in $IncludeTypes) {
	#$dbtype=	$db.$Type 
	$TypeCounter=0
		Write-Verbose "... $Type $(get-date -format G)"
		foreach ($objs in $db.$Type  <#| Where-Object { !($_.IsSystemObject) }#>) { 
            If ($ExcludeSchemas -notcontains $objs.Schema ) {
				$TypeCounter++
				if($TypeCounter % 100 -eq 0) 
				{
					Write-Verbose "..... Processed $TypeCounter $(get-date -format G)"
				}       
                $schema = $objs.Schema
                $ObjName = $objs.Name 
                $ObjectType = $objs.GetType().Name 

				#Write-Verbose  "$ObjectType, $schema , $ObjName"

                $ofs = ""
                $sql = ( [string]$objs.Script($so) ).replace("SET ANSI_NULLS ONSET QUOTED_IDENTIFIER ON", "")

			    [void]$dt.Rows.Add($ServerSource, $DatabaseSource , $ObjectType , $schema , $ObjName , $sql )
				
                if ($ObjectType -eq "Table") {
					#Write-Verbose  " ... table sub objects"

				
                    $tableObjects = $objs.Indexes
                    $tableObjects += $objs.ForeignKeys
                    $tableObjects += $objs.Checks
                    $tableObjects += $objs.Triggers
#ignore check or IsSystemObject https://mitchwheat.com/2011/07/14/fixing-slow-sql-server-management-objects-smo-performance/
                    foreach ($tableSub in $tableObjects <#| Where-Object { !($_.IsSystemObject) }#>) {   
						$schema = $tableSub.Schema
                        $ObjName = $tableSub.Name 
						$tableSubType = $tableSub.GetType().Name 

						# check to see if index is PrimaryKey	
						if ($tableSubType -eq "Index") {
							if ( $tableSub.IndexKeyType -eq "DriPrimaryKey") { 
                                $tableSubType = "PrimaryKey" 
                            }
                        }
			
						#Write-Verbose  " ... $tableSubType, $schema , $ObjName"

                        $sql = ( [string]$tableSub.Script($so) ).replace("SET ANSI_NULLS ONSET QUOTED_IDENTIFIER ON", "")
                        [void]$dt.Rows.Add($ServerSource, $DatabaseSource , $tableSubType , $schema , $ObjName , $sql )
						#Write-Verbose " complete"
                    }
                }
            }
        }
    }     
	

    Save-DoctoDb $SQLConnectionString  -Procedure  $Procedure  -ProcedureParamName $ProcedureParamName  -ProcedureParamValue $dt
}



Write-Verbose "Start  SQLDocColumnQuery"
$query = SQLDocColumnQuery  -extentedPropertyName $extentedPropertyName 
Save-QueryResult -ServerInstance $ServerSource -Database $DatabaseSource  -SQLConnectionString $SQLConnectionString -Query $query -Procedure "[dbo].[usp_ColumnDocUpdate]" -ProcedureParamName  "@TVP"

Write-Verbose "Start  SQLColumnReference"
$query = SQLColumnReference
Save-QueryResult -ServerInstance $ServerSource -Database $DatabaseSource  -SQLConnectionString $SQLConnectionString -Query $query -Procedure "[dbo].[uspUpdateSQLColumnReference]" -ProcedureParamName  "@TVP"


Write-Verbose "Start Get-SQLDOCReferencedObjectQuery"
$query = Get-SQLDOCReferencedObjectQuery  -extentedPropertyName $extentedPropertyName 
Save-QueryResult -ServerInstance $ServerSource -Database $DatabaseSource  -SQLConnectionString $SQLConnectionString -Query $query -Procedure "[dbo].[uspUpdateSQLDocObjectReference]" -ProcedureParamName  "@TVPObjRef"

 
Write-Verbose "Start  SQLDOCObjects"
$query = Get-SQLDOCObjectQuery -extentedPropertyName $extentedPropertyName 
Save-QueryResult -ServerInstance $ServerSource -Database $DatabaseSource  -SQLConnectionString $SQLConnectionString -Query $query -Procedure "[dbo].[usp_ObjectDocumentationUpdate]" -ProcedureParamName  "@TVPObjDoc"

Write-Verbose "Start ViewColumnMap Query"
$query = Get-ViewColumnMapQuery -extentedPropertyName $extentedPropertyName 
Save-QueryResult -ServerInstance $ServerSource -Database $DatabaseSource  -SQLConnectionString $SQLConnectionString -Query $query -Procedure "[dbo].[uspUpdateSQLDocViewDefinitionColumnMap]" -ProcedureParamName  "@TVPViewCol"


Write-Verbose "Start Database Info"
$query = SQLDatabaseInformation -extentedPropertyName $extentedPropertyName 
Save-QueryResult -ServerInstance $ServerSource -Database $DatabaseSource  -SQLConnectionString $SQLConnectionString -Query $query -Procedure "[dbo].[usp_DatabaseInformationUpdate]" -ProcedureParamName  "@TVPDbInfo"


Write-Verbose "Start Get-SQLObjectCode" #this has to happen all within the function as cannot marshall the dataset out of the function 
Save-SQLObjectCode -ServerSource $ServerSource -DatabaseSource $DatabaseSource -Credential $Credential


Write-Verbose "Save-AutoMapForeignKeys"
$ServerSourceNoPort = Get-ServerInstance -ServerInstance $ServerSource -Database $DatabaseSource #Note this returns the Server & instance but not the port number.
Save-AutoMapForeignKeys -ServerInstance $ServerSourceNoPort -Database $DatabaseSource  -SQLConnectionString $SQLConnectionString 