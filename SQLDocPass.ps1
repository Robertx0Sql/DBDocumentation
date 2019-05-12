param(
[string]$ServerSource="(local)"
,[string]$DatabaseSource="AdventureWorks2017"
,[string]$SqlServerDoc = "."
,[string]$SqlDatabaseDoc = "Documentation"
)

$extentedPropertyName="MS_Description"
$SQLConnectionString = "Data Source={0};Initial Catalog={1};Integrated Security=SSPI;" -f $SqlServerDoc, $SqlDatabaseDoc

function SaveDoctoDb($SQLConnectionString, $Procedure, $ProcedureParamName, $ProcedureParamValue)
{
	#nvoke-SqlCmd does not support passing complex objects. need to use a System.Data.SQLClient.SQLCommand object
	# https://social.technet.microsoft.com/Forums/en-US/9ed5b002-962e-4e07-a57c-0be2b87abe3c/invokesqlcmd-custom-table-as-parameter?forum=winserverpowershell
	$SQLConnectionString

	$SQLConn = new-object System.Data.SQLClient.SQLConnection
	$SQLConn.ConnectionString = $SQLConnectionString
	$SQLConn.Open()

	$SQLCmd = New-object System.Data.SQLClient.SQLCommand
	$SQLCmd.CommandText = $Procedure #"[dbo].[usp_ColumnDocUpdate]"
	$SQLCmd.CommandType = [System.Data.CommandType]::StoredProcedure
	$SQLCmd.Connection = $SQLConn
	$SQLCmd.Parameters.AddWithValue($ProcedureParamName,$ProcedureParamValue) #("@TVP", $dtX)
	$SQLCmd.ExecuteNonQuery()

	$SQLconn.Close()
}  
function  SQLDocColumnQuery ($extentedPropertyName)
{
$queryColumns = @"
SELECT 
SERVERNAME = `'$ServerSource`'
,DatabaseName = `'$DatabaseSource`'
,[objectType] =obj.TYPE
,c.OBJECT_ID

,object_schema_name(C.OBJECT_ID) AS [TableSchemaName]
,OBJECT_NAME(c.OBJECT_ID) AS [TableName]
,c.name
,CAST(p.value AS NVARCHAR(MAX) ) AS DocumentationDescription
,c.column_id
,t.name AS datatype
,c.max_length
,c.PRECISION
,c.scale
,c.collation_name
,c.is_nullable
,c.is_identity
,CAST(ident_col.seed_value AS INT) AS ident_col_seed_value 
,CAST(ident_col.increment_value AS INT) AS ident_col_increment_value 
,c.is_computed
,object_definition(c.default_object_id) AS Column_Default
,ic.is_primary_key AS PK

,fk_obj.name AS FK_NAME
,fkc.referenced_object_id AS ReferencedTableObject_id
,object_schema_name(fkc.referenced_object_id) AS [ReferencedTableSchemaName]
,OBJECT_NAME(fkc.referenced_object_id) AS [ReferencedTableName]
,col2.name AS [referenced_column]
FROM 
sys.columns AS c
INNER JOIN sys.objects obj ON obj.OBJECT_ID=c.OBJECT_ID
LEFT JOIN sys.types t ON t.user_type_id = c.user_type_id
LEFT JOIN sys.extended_properties AS p ON p.major_id = c.OBJECT_ID
AND p.minor_id = c.column_id
AND p.CLASS = 1
AND p.name = `'$extentedPropertyName`'
LEFT JOIN sys.identity_columns ident_col ON c.OBJECT_ID = ident_col.OBJECT_ID
AND c.column_id = ident_col.column_id
LEFT JOIN (
SELECT ic.OBJECT_ID , ic.column_id  
, is_primary_key
FROM sys.index_columns  ic
LEFT JOIN sys.indexes AS i ON i.OBJECT_ID = ic.OBJECT_ID
AND i.index_id = ic.index_id
WHERE is_primary_key=1
)ic ON ic.OBJECT_ID = c.OBJECT_ID
AND ic.column_id = c.column_id
LEFT JOIN sys.foreign_key_columns fkc ON c.column_id = fkc.parent_column_id
AND c.OBJECT_ID = fkc.parent_object_id
LEFT JOIN sys.objects fk_obj ON fk_obj.OBJECT_ID = fkc.constraint_object_id
LEFT JOIN sys.columns col2 ON col2.column_id = referenced_column_id 
AND col2.OBJECT_ID = fkc.referenced_object_id
WHERE OBJECTPROPERTY(c.OBJECT_ID, 'IsMsShipped') = 0 
AND obj.TYPE IN ('U', 'V')
UNION ALL

SELECT 
SERVERNAME = `'$ServerSource`'
,DatabaseName = `'$DatabaseSource`'
,[objectType] = c.TYPE
,c.OBJECT_ID
,object_schema_name(C.OBJECT_ID) AS [TableSchemaName]
,OBJECT_NAME(c.OBJECT_ID) AS [TableName]
, NULL AS name 
,CAST(p.value AS NVARCHAR(MAX) ) AS DocumentationDescription
,NULL AS column_id
,NULL AS datatype
,NULL AS max_length
,NULL AS PRECISION
,NULL AS scale
,NULL AS collation_name
,NULL AS is_nullable
,NULL AS is_identity
,NULL AS ident_col_seed_value 
,NULL AS ident_col_increment_value 
,NULL AS is_computed
,NULL AS Column_Default 
,NULL AS PK 
,NULL AS FK_NAME
,NULL AS ReferencedTableObject_id
,NULL AS [ReferencedTableSchemaName]
,NULL AS [ReferencedTableName]
,NULL AS [referenced_column]
FROM 
sys.objects AS c
LEFT JOIN sys.extended_properties AS p ON p.major_id = c.OBJECT_ID
AND p.CLASS = 1
AND p.	minor_id=0
AND p.name =  `'$extentedPropertyName`'
WHERE c.TYPE IN ('U', 'V');



"@
return  $queryColumns
}
$query =SQLDocColumnQuery($extentedPropertyName)

$QueryResult = Invoke-Sqlcmd -ServerInstance $ServerSource -Database $DatabaseSource -Query $query -OutputAs DataTables
#$QueryResult.Rows[0]
#$SQLConnectionString
SaveDoctoDb $SQLConnectionString "[dbo].[usp_ColumnDocUpdate]"   "@TVP"  $QueryResult 

