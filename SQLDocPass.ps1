[CmdletBinding()]
param(
[string]$ServerSource="(local)"
,[string]$DatabaseSource="AdventureWorks2017"
,[string]$SqlServerDoc = "."
,[string]$SqlDatabaseDoc = "Documentation"
,[string]$Description 
)

$extentedPropertyName="MS_Description"
$SQLConnectionString = "Data Source={0};Initial Catalog={1};Integrated Security=SSPI;" -f $SqlServerDoc, $SqlDatabaseDoc

function Save-DoctoDb($SQLConnectionString, $Procedure, $ProcedureParamName, $ProcedureParamValue)
{
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
	$SQLCmd.Parameters.AddWithValue($ProcedureParamName,$ProcedureParamValue) | Out-Null
	$SQLCmd.ExecuteNonQuery()  | Out-Null
	
	$SQLconn.Close()
	Write-Verbose  "$($ProcedureParamValue.Rows.Count) rows added /updated for $Procedure"
}  

function SQLDOCReferencedObjects($ServerSource, $DatabaseSource, $extentedPropertyName)
{
	$query = @"
	WITH CTE AS (
		SELECT OBJECT_schema_NAME(referencing_id) AS referencing_schema_name
			,OBJECT_NAME(referencing_id) AS referencing_entity_name
			,o.type AS referencingTypeCode
			,o.type_desc AS referencingTypeDescription
			,referenced_server_name
			,referenced_database_name
			,coalesce(referenced_schema_name, object_schema_name(referenced_id)) AS referenced_schema_name
			,referenced_entity_name
	
		FROM sys.sql_expression_dependencies AS sed
		INNER JOIN sys.objects AS o
			ON sed.referencing_id = o.object_id
		
		UNION ALL 
		
		SELECT coalesce(X.referencing_schema_name, OBJECT_SCHEMA_NAME(t.object_id)) as referencing_schema_name
			,X.referencing_entity_name
			,so.type AS referencingTypeCode
			,so.type_desc AS referencingTypeDescription
			,NULL AS referenced_server_name
			,NULL AS referenced_database_name
			,OBJECT_SCHEMA_NAME(t.object_id) AS referenced_schema_name
			,OBJECT_NAME(t.object_id) AS referenced_entity_name
		FROM sys.tables t
		CROSS APPLY sys.dm_sql_referencing_entities(quotename(OBJECT_SCHEMA_NAME(t.object_id)) + '.' + Quotename(OBJECT_NAME(t.object_id)), 'OBJECT') X
		LEFT JOIN sys.objects so
			ON so.name = X.referencing_entity_name
				AND schema_name(so.schema_id) = X.referencing_schema_name
		)
	SELECT DISTINCT 
		SERVERNAME = `'$ServerSource`'
		,DatabaseName = `'$DatabaseSource`'
		,X.referencing_schema_name
		,X.referencing_entity_name
		,referencingTypeCode
		,referencingTypeDescription
		,referenced_server_name
		,referenced_database_name
		,referenced_schema_name
		,referenced_entity_name
	 FROM CTE X ;
"@
return  $query
}
function  SQLDocColumnQuery ($ServerSource, $DatabaseSource, $extentedPropertyName)
{
$queryColumns = @"
SELECT 
SERVERNAME = `'$ServerSource`'
,DatabaseName = `'$DatabaseSource`'
,[objectType] =obj.TYPE
,[objectTypeDescription] =NULL-- c.type_desc
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

union all -- parameters

SELECT 
	SERVERNAME = `'$ServerSource`'
	,DatabaseName = `'$DatabaseSource`'
	,[objectType] =sp.TYPE
	,[objectTypeDescription] =NULL-- c.type_desc
	,sp.OBJECT_ID

	,object_schema_name(sp.OBJECT_ID) AS [TableSchemaName]
	,OBJECT_NAME(sp.OBJECT_ID) AS [TableName]
	,par.name
	,CAST(p.value AS NVARCHAR(MAX) ) AS DocumentationDescription
	,par.parameter_id
	,t.name AS datatype
	,par.max_length
	,par.PRECISION
	,par.scale
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
   sys.all_objects AS sp
INNER JOIN sys.parameters par ON sp.Object_id = par.Object_id
LEFT JOIN sys.types t ON t.user_type_id = par.user_type_id
   left JOIN sys.extended_properties AS p ON p.major_id=sp.object_id AND p.class=2
		AND p.minor_id = par.parameter_id
		AND p.name =  `'$extentedPropertyName`'
Where par.name!='' --return value for functions

; 
"@
return  $queryColumns
}
function SQLDOCObjects($ServerSource, $DatabaseSource, $extentedPropertyName)
{
	$query = @"
	SELECT --1
		SERVERNAME = `'$ServerSource`'
		,DatabaseName = `'$DatabaseSource`'
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
		AND p.name =  `'$extentedPropertyName`'
	LEFT JOIN (
		SELECT ic.OBJECT_ID
			,STRING_AGG(COL_NAME(ic.OBJECT_ID, ic.column_id), ',') AS fields
		FROM sys.index_columns ic
		LEFT JOIN sys.indexes AS i ON i.OBJECT_ID = ic.OBJECT_ID
			AND i.index_id = ic.index_id
		GROUP BY ic.OBJECT_ID
		) ic ON ic.OBJECT_ID = c.OBJECT_ID
	LEFT JOIN (
		SELECT constraint_object_id
			,STRING_AGG(COL_NAME(fkc.parent_object_id, fkc.parent_column_id), ',') AS fields
		FROM sys.foreign_key_columns fkc
		GROUP BY constraint_object_id
		) fk ON fk.constraint_object_id = c.OBJECT_ID
	LEFT JOIN (
		SELECT con.OBJECT_ID
			,con.DEFINITION
			,STRING_AGG(COL_NAME(con.parent_object_id, con.parent_column_id), ',') AS fields
		FROM sys.default_constraints con
		GROUP BY con.OBJECT_ID
			,con.DEFINITION
		) dcon ON dcon.OBJECT_ID = c.OBJECT_ID
	LEFT JOIN (
		SELECT con.OBJECT_ID
			,con.DEFINITION
			,STRING_AGG(COL_NAME(con.parent_object_id, con.parent_column_id), ',') AS fields
		FROM sys.check_constraints con
		GROUP BY con.OBJECT_ID
			,con.DEFINITION
		) ccon ON ccon.OBJECT_ID = c.OBJECT_ID
	WHERE c.TYPE NOT IN ('S', 'IT', 'SQ')

	UNION ALL
	
	SELECT --1
		SERVERNAME = `'$ServerSource`'
		,DatabaseName = `'$DatabaseSource`'
		,[objectType] = 'INDEX'
		,object_schema_name(ISNULL(NULLIF(so.parent_object_id, 0), so.OBJECT_ID)) AS [ParentSchemaName]
		,OBJECT_NAME(ISNULL(NULLIF(so.parent_object_id, 0), so.OBJECT_ID)) AS [ParentObjectName]
		,NULL--object_schema_name(so.OBJECT_ID) AS [SchemaName]
		,ix.name AS OBJECTNAME
		,fields
		,NULL  as Definition
		,CAST(ep.value AS NVARCHAR(MAX)) AS DocumentationDescription
	FROM sys.tables so
	INNER JOIN sys.indexes ix ON so.object_id = ix.object_id
	LEFT JOIN sys.extended_properties ep ON ep.major_id = ix.OBJECT_ID
		AND CLASS = 7
		AND ep.minor_id = ix.index_id
		AND Ep.name =  `'$extentedPropertyName`'
	INNER JOIN (
		SELECT ic.OBJECT_ID
			,STRING_AGG(COL_NAME(ic.OBJECT_ID, ic.column_id), ',') AS fields
		FROM sys.index_columns AS ic
		GROUP BY ic.OBJECT_ID
	) ic ON ic.object_id = ix.object_id

	UNION ALL
	SELECT 
		SERVERNAME = `'$ServerSource`'
		,DatabaseName = `'$DatabaseSource`'
		,'-X-' [objectType] 
		,NULL AS [ParentSchemaName]
		,NULL  as [ParentObjectName]
		,NULL AS [SchemaName]
		,NULL AS OBJECTNAME
		,NULL as fields
		,NULL  as Definition
		,`'$Description`' AS DocumentationDescription
		where len(`'$Description`')>0

	; 
"@
return  $query
}

function SQLViewColumnUsage($ServerSource, $DatabaseSource, $extentedPropertyName)
{

	$query=@"
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
			SERVERNAME = `'$ServerSource`'
			,DatabaseName = `'$DatabaseSource`'
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
function Save-QueryResult ($ServerSource , $Database  , $Query , $SQLConnectionString, $Procedure, $ProcedureParamName){

	$QueryResult = Invoke-Sqlcmd -ServerInstance $ServerSource -Database $Database  -Query $Query -OutputAs DataTables
	Save-DoctoDb $SQLConnectionString  -Procedure  $Procedure  -ProcedureParamName $ProcedureParamName  -ProcedureParamValue $QueryResult
}

function Save-SQLObjectCode($ServerSource, $DatabaseSource )
{
	$Procedure="[dbo].[usp_ObjectCodeUpdate]"
	$ProcedureParamName="@TVPObjectCode"

	[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
	$serverInstance = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $ServerSource
	$IncludeTypes = @("StoredProcedures", "Views") #object you want do backup. 
	$ExcludeSchemas = @("sys", "Information_Schema")
	$so = new-object ('Microsoft.SqlServer.Management.Smo.ScriptingOptions')

	$db = $serverInstance.databases[$DatabaseSource]


	$dt = New-Object System.Data.Datatable 
	$col1 = New-Object system.Data.DataColumn SERVERNAME,([string])
	$col2 = New-Object system.Data.DataColumn DatabaseName,([string])
	$col3 = New-Object system.Data.DataColumn SchemaName,([string])
	$col4 = New-Object system.Data.DataColumn ObjectName,([string])
	$col5 = New-Object system.Data.DataColumn sql,([string])
	$dt.columns.add($col1)
	$dt.columns.add($col2)
	$dt.columns.add($col3)
	$dt.columns.add($col4)
	$dt.columns.add($col5)

	#$result =
	 foreach ($Type in $IncludeTypes) {

		foreach ($objs in $db.$Type) { 
            If ($ExcludeSchemas -notcontains $objs.Schema ) {
                        
                $ObjName = "$objs".replace("[$($objs.Schema)].", "").replace("[", "").replace("]", "")                  

				$ofs = ""
                $sql =( [string]$objs.Script($so) ).replace("SET ANSI_NULLS ONSET QUOTED_IDENTIFIER ON","")

				[void]$dt.Rows.Add($ServerSource,$DatabaseSource,"$($objs.Schema)" ,  $ObjName , $sql )
              <#  [pscustomobject]@{ #Output object  prefix with Field_# as the ConvertTo-DataTable orders the fields by name
                    Field_1_SERVERNAME   = $ServerSource
                    Field_2_DatabaseName = $DatabaseSource
                    Field_3_SchemaName   = "$($objs.Schema)"
                    Field_4_ObjectName   = $ObjName
                    Field_5_sql          = $sql
				}
				#>
}
        }
    }     
	


	Save-DoctoDb $SQLConnectionString  -Procedure  $Procedure  -ProcedureParamName $ProcedureParamName  -ProcedureParamValue $dt
}

Write-Verbose "Start  SQLDocColumnQuery"
$query =SQLDocColumnQuery -ServerSource $ServerSource -DatabaseSource $DatabaseSource -extentedPropertyName $extentedPropertyName 
Save-QueryResult -ServerInstance $ServerSource -Database $DatabaseSource  -SQLConnectionString $SQLConnectionString -Query $query -Procedure "[dbo].[usp_ColumnDocUpdate]" -ProcedureParamName  "@TVP"

Write-Verbose "Start  SQLDOCReferencedObjects"
$query = SQLDOCReferencedObjects -ServerSource $ServerSource -DatabaseSource $DatabaseSource -extentedPropertyName $extentedPropertyName 
Save-QueryResult -ServerInstance $ServerSource -Database $DatabaseSource  -SQLConnectionString $SQLConnectionString -Query $query -Procedure "[dbo].[usp_ObjectReferenceUpdate]" -ProcedureParamName  "@TVPObjRef"

 
Write-Verbose "Start  SQLDOCObjects"
$query =SQLDOCObjects -ServerSource $ServerSource -DatabaseSource $DatabaseSource -extentedPropertyName $extentedPropertyName 
Save-QueryResult -ServerInstance $ServerSource -Database $DatabaseSource  -SQLConnectionString $SQLConnectionString -Query $query -Procedure "[dbo].[usp_ObjectDocumentationUpdate]" -ProcedureParamName  "@TVPObjDoc"

Write-Verbose "Start SQLViewColumnUsage"
$query = SQLViewColumnUsage -ServerSource $ServerSource -DatabaseSource $DatabaseSource -extentedPropertyName $extentedPropertyName 
Save-QueryResult -ServerInstance $ServerSource -Database $DatabaseSource  -SQLConnectionString $SQLConnectionString -Query $query -Procedure "[dbo].[usp_ViewColumnUpdate]" -ProcedureParamName  "@TVPViewCol"

Write-Verbose "Start Get-SQLObjectCode" #this has to happen all within the function as cannot marshall the dataset out of the function 
Save-SQLObjectCode -ServerSource $ServerSource -DatabaseSource $DatabaseSource 
