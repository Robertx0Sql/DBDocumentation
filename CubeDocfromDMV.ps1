#CubeDocfromDMV.ps1
[CmdletBinding()]

param([string]$SSASServer = ".", 
    [string]$SSASDatabase = "SLCombinedCube"
    , [string]$DocServer = "."
    , [string]$DocDatabase = "Documentation"
    #,[string]$ServerConnection =$(Throw "Parameter missing: -Server Connection")
    , [PSCredential]$DocCredential 
)
function BoolToSqlBit ([string]$val) {
    if ($val -eq $true) { "1" }else { "0" }
}
function BlanktoSQLNULL([string]$val) {
    #$val
    if ($val -eq "" ) { "NULL" } else { "'" + $val.Replace("'", "''") + "'" }
}
function export-ASData {
    param ($dmv 
        , $DataRow
    )
        
    switch ($dmv) {
        "MDSCHEMA_CUBES" {
            #"MDSCHEMA_CUBES $i" 
  
            $SQLCmd = " INSERT INTO dbo.[MDSCHEMA_CUBES] 
  ([CATALOG_NAME] ,[SCHEMA_NAME] ,[CUBE_NAME] ,[CUBE_TYPE] ,[CUBE_GUID] ,[CREATED_ON] ,[LAST_SCHEMA_UPDATE] ,[SCHEMA_UPDATED_BY] ,[LAST_DATA_UPDATE] ,[DATA_UPDATED_BY] ,[DESCRIPTION] ,[IS_DRILLTHROUGH_ENABLED] ,[IS_LINKABLE] ,[IS_WRITE_ENABLED] ,[IS_SQL_ENABLED] ,[CUBE_CAPTION] ,[BASE_CUBE_NAME] ,[CUBE_Source]) 
  VALUES('" + $dataRow.CATALOG_NAME + "'" + "," + 
            (BlanktoSQLNULL $dataRow.SCHEMA_NAME ) + "," + 
            (BlanktoSQLNULL $dataRow.CUBE_NAME ) + "," + 
            (BlanktoSQLNULL $dataRow.CUBE_TYPE ) + "," + 
            (BlanktoSQLNULL $dataRow.CUBE_GUID ) + "," + 
            (BlanktoSQLNULL $dataRow.CREATED_ON ) + "," + 
            (BlanktoSQLNULL $dataRow.LAST_SCHEMA_UPDATE ) + "," + 
            (BlanktoSQLNULL $dataRow.SCHEMA_UPDATED_BY ) + "," + 
            (BlanktoSQLNULL $dataRow.LAST_DATA_UPDATE ) + "," + 
            (BlanktoSQLNULL $dataRow.DATA_UPDATED_BY ) + "," + 
            (BlanktoSQLNULL $dataRow.DESCRIPTION ) + "," + 
            (BoolToSqlBit $dataRow.IS_DRILLTHROUGH_ENABLED ) + "," + 
            (BoolToSqlBit $dataRow.IS_LINKABLE) + "," + 
            (BoolToSqlBit $dataRow.IS_WRITE_ENABLED) + "," + 
            (BoolToSqlBit $dataRow.IS_SQL_ENABLED) + "," + 
            (BlanktoSQLNULL $dataRow.CUBE_CAPTION ) + "," + 
            (BlanktoSQLNULL $dataRow.BASE_CUBE_NAME ) + "," + 
            (BlanktoSQLNULL $dataRow.CUBE_Source ) +    
            ")" 
  
            #$SQLCmd
  
            $SQLconn.Open() # Open SQL Connection
            $cmdSQL = $SQLconn.CreateCommand()
  
            $cmdSQL.CommandText = $SQLCmd
            $result=$cmdSQL.ExecuteNonQuery() 
            $SQLconn.Close()
  
        } 
  
        "MDSCHEMA_DIMENSIONS" {
           # "MDSCHEMA_DIMENSIONS" ; $i
      
            $sql = "INSERT INTO [dbo].[MDSCHEMA_DIMENSIONS]           (CATALOG_NAME,SCHEMA_NAME,CUBE_NAME,DIMENSION_NAME,DIMENSION_UNIQUE_NAME,DIMENSION_GUID,DIMENSION_CAPTION,DIMENSION_ORDINAL,DIMENSION_TYPE,DIMENSION_CARDINALITY,DEFAULT_HIERARCHY,DESCRIPTION,IS_VIRTUAL,IS_READWRITE,DIMENSION_UNIQUE_SETTINGS,DIMENSION_MASTER_NAME,DIMENSION_IS_VISIBLE)
  VALUES (" + 
  
            (BlanktoSQLNULL $dataRow.CATALOG_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.SCHEMA_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.CUBE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_UNIQUE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_GUID) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_CAPTION) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_ORDINAL) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_TYPE) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_CARDINALITY) + "," + 
            (BlanktoSQLNULL $dataRow.DEFAULT_HIERARCHY) + "," + 
            (BlanktoSQLNULL $dataRow.DESCRIPTION) + "," + 
            (BoolToSqlBit $dataRow.IS_VIRTUAL) + "," + 
            (BoolToSqlBit $dataRow.IS_READWRITE) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_UNIQUE_SETTINGS) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_MASTER_NAME) + "," + 
            (BoolToSqlBit $dataRow.DIMENSION_IS_VISIBLE) + "
  )"
  
            #$sql
  
            $SQLconn.Open() # Open SQL Connection
            $cmdSQL = $SQLconn.CreateCommand()
  
            $cmdSQL.CommandText = $sql
            $result=$cmdSQL.ExecuteNonQuery() 
            $SQLconn.Close()
        } 
        "MDSCHEMA_LEVELS" {
            #"MDSCHEMA_LEVELS" ; $i
   
            $sql = "INSERT INTO [dbo].[MDSCHEMA_LEVELS]           (CATALOG_NAME,SCHEMA_NAME,CUBE_NAME,DIMENSION_UNIQUE_NAME,HIERARCHY_UNIQUE_NAME,LEVEL_NAME,LEVEL_UNIQUE_NAME,LEVEL_GUID,LEVEL_CAPTION,LEVEL_NUMBER,LEVEL_CARDINALITY,LEVEL_TYPE,DESCRIPTION,CUSTOM_ROLLUP_SETTINGS,LEVEL_UNIQUE_SETTINGS,LEVEL_IS_VISIBLE,LEVEL_ORDERING_PROPERTY,LEVEL_DBTYPE,LEVEL_MASTER_UNIQUE_NAME,LEVEL_NAME_SQL_COLUMN_NAME,LEVEL_KEY_SQL_COLUMN_NAME,LEVEL_UNIQUE_NAME_SQL_COLUMN_NAME,LEVEL_ATTRIBUTE_HIERARCHY_NAME,LEVEL_KEY_CARDINALITY,LEVEL_ORIGIN)
  VALUES (" +
            (BlanktoSQLNULL $dataRow.CATALOG_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.SCHEMA_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.CUBE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_UNIQUE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.HIERARCHY_UNIQUE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_UNIQUE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_GUID) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_CAPTION) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_NUMBER) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_CARDINALITY) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_TYPE) + "," + 
            (BlanktoSQLNULL $dataRow.DESCRIPTION) + "," + 
            (BlanktoSQLNULL $dataRow.CUSTOM_ROLLUP_SETTINGS) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_UNIQUE_SETTINGS) + "," + 
            (BoolToSqlBit $dataRow.LEVEL_IS_VISIBLE) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_ORDERING_PROPERTY) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_DBTYPE) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_MASTER_UNIQUE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_NAME_SQL_COLUMN_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_KEY_SQL_COLUMN_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_UNIQUE_NAME_SQL_COLUMN_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_ATTRIBUTE_HIERARCHY_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_KEY_CARDINALITY) + "," + 
            (BlanktoSQLNULL $dataRow.LEVEL_ORIGIN) + "
  )"
  
            #$sql
  
            $SQLconn.Open() # Open SQL Connection
            $cmdSQL = $SQLconn.CreateCommand()
  
            $cmdSQL.CommandText = $sql
            $result=$cmdSQL.ExecuteNonQuery() 
            $SQLconn.Close()
  
        } 
        "MDSCHEMA_MEASUREGROUP_DIMENSIONS" {
            #"MDSCHEMA_MEASUREGROUP_DIMENSIONS." ; $i
            $sql = "INSERT INTO [dbo].[MDSCHEMA_MEASUREGROUP_DIMENSIONS] (CATALOG_NAME,SCHEMA_NAME,CUBE_NAME,MEASUREGROUP_NAME,MEASUREGROUP_CARDINALITY,DIMENSION_UNIQUE_NAME,DIMENSION_CARDINALITY,DIMENSION_IS_VISIBLE,DIMENSION_IS_FACT_DIMENSION,DIMENSION_PATH,DIMENSION_GRANULARITY)
  VALUES (" +
            (BlanktoSQLNULL $dataRow.CATALOG_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.SCHEMA_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.CUBE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.MEASUREGROUP_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.MEASUREGROUP_CARDINALITY) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_UNIQUE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_CARDINALITY) + "," + 
            (BoolToSqlBit $dataRow.DIMENSION_IS_VISIBLE) + "," + 
            (BoolToSqlBit $dataRow.DIMENSION_IS_FACT_DIMENSION) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_PATH) + "," + 
            (BlanktoSQLNULL $dataRow.DIMENSION_GRANULARITY) + 
  
            ")"
            #$sql
  
            $SQLconn.Open() # Open SQL Connection
            $cmdSQL = $SQLconn.CreateCommand()
  
            $cmdSQL.CommandText = $sql
            $result=$cmdSQL.ExecuteNonQuery() 
            $SQLconn.Close()
  
        } 
        "MDSCHEMA_MEASUREGROUPS" {
            #"MDSCHEMA_MEASUREGROUPS." ; $i
            $sql = "INSERT INTO [dbo].[MDSCHEMA_MEASUREGROUPS] (CATALOG_NAME,SCHEMA_NAME,CUBE_NAME,MEASUREGROUP_NAME,DESCRIPTION,IS_WRITE_ENABLED,MEASUREGROUP_CAPTION)
  VALUES (" +
            (BlanktoSQLNULL $dataRow.CATALOG_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.SCHEMA_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.CUBE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.MEASUREGROUP_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.DESCRIPTION) + "," + 
            (BoolToSqlBit $dataRow.IS_WRITE_ENABLED) + "," + 
            (BlanktoSQLNULL $dataRow.MEASUREGROUP_CAPTION) + 
            ")"
            #$sql
  
            $SQLconn.Open() # Open SQL Connection
            $cmdSQL = $SQLconn.CreateCommand()
  
            $cmdSQL.CommandText = $sql
            $result=$cmdSQL.ExecuteNonQuery() 
            $SQLconn.Close()
        } 
        "MDSCHEMA_MEASURES" {
            #"MDSCHEMA_MEASURES." ; $i
  
            $sql = "INSERT INTO [dbo].[MDSCHEMA_MEASURES] (CATALOG_NAME,SCHEMA_NAME,CUBE_NAME,MEASURE_NAME,MEASURE_UNIQUE_NAME,MEASURE_CAPTION,MEASURE_GUID,MEASURE_AGGREGATOR,DATA_TYPE,NUMERIC_PRECISION,NUMERIC_SCALE,MEASURE_UNITS,DESCRIPTION,EXPRESSION,MEASURE_IS_VISIBLE,LEVELS_LIST,MEASURE_NAME_SQL_COLUMN_NAME,MEASURE_UNQUALIFIED_CAPTION,MEASUREGROUP_NAME,MEASURE_DISPLAY_FOLDER,DEFAULT_FORMAT_STRING)
  VALUES (" +
            (BlanktoSQLNULL $dataRow.CATALOG_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.SCHEMA_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.CUBE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.MEASURE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.MEASURE_UNIQUE_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.MEASURE_CAPTION) + "," + 
            (BlanktoSQLNULL $dataRow.MEASURE_GUID) + "," + 
            (BlanktoSQLNULL $dataRow.MEASURE_AGGREGATOR) + "," + 
            (BlanktoSQLNULL $dataRow.DATA_TYPE) + "," + 
            (BlanktoSQLNULL $dataRow.NUMERIC_PRECISION) + "," + 
            (BlanktoSQLNULL $dataRow.NUMERIC_SCALE) + "," + 
            (BlanktoSQLNULL $dataRow.MEASURE_UNITS) + "," + 
            (BlanktoSQLNULL $dataRow.DESCRIPTION) + "," + 
            (BlanktoSQLNULL $dataRow.EXPRESSION) + "," + 
            (BoolToSqlBit $dataRow.MEASURE_IS_VISIBLE) + "," + 
            (BlanktoSQLNULL $dataRow.LEVELS_LIST) + "," + 
            (BlanktoSQLNULL $dataRow.MEASURE_NAME_SQL_COLUMN_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.MEASURE_UNQUALIFIED_CAPTION) + "," + 
            (BlanktoSQLNULL $dataRow.MEASUREGROUP_NAME) + "," + 
            (BlanktoSQLNULL $dataRow.MEASURE_DISPLAY_FOLDER) + "," + 
            (BlanktoSQLNULL $dataRow.DEFAULT_FORMAT_STRING) + 
            ")"
  
            #$sql
  
            $SQLconn.Open() # Open SQL Connection
            $cmdSQL = $SQLconn.CreateCommand()
  
            $cmdSQL.CommandText = $sql
            $result=$cmdSQL.ExecuteNonQuery() 
            $SQLconn.Close()
        } 
  
      
    }
}

#Import adomdClient namespace, use void to hide the default ouput
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices.AdomdClient") 

$DMV_array = "MDSCHEMA_CUBES", "MDSCHEMA_DIMENSIONS", "MDSCHEMA_LEVELS", "MDSCHEMA_MEASUREGROUP_DIMENSIONS", "MDSCHEMA_MEASUREGROUPS", "MDSCHEMA_MEASURES"

[string]$ASconnectionString = "Datasource=" + $SSASServer + ";Initial Catalog=" + $SSASDatabase;

 

$SQLconn = New-Object System.Data.SqlClient.SqlConnection 
$SQLcmd = New-Object System.Data.SqlClient.SqlCommand

$SQLConnectionString = "Data Source={0};Initial Catalog={1};Integrated Security=SSPI;" -f $DocServer, $DocDatabase
if ($null -ne $DocCredential) {
    $SQLConnectionString = "Data Source={0};Initial Catalog={1};User ID={2};Password={3}" -f $DocServer, $DocDatabase, $DocCredential.UserName , $DocCredential.GetNetworkCredential().Password
}

Write-Debug "SQLConnectionString $SQLConnectionString" 
$SQLconn.ConnectionString = $SQLConnectionString 


foreach ($dmv in $DMV_array) { 


    #Get only the active sessions and remove yourself
    $Query = 'SELECT * FROM $system.' + $dmv ;
    #$Query
    [xml]$Data = Invoke-ASCmd -Query $Query -ConnectionString $ASconnectionString
    #    [string]$commandText = 'SELECT * FROM $system.' + $dmv ;
    #    [System.Data.DataSet]$dataset = new-object System.Data.DataSet;

    [string]$SQLcmd = "";
    #try
    if ( 1 -eq 1) {
  
  
    
        $sql = "DELETE FROM  dbo.[{0}] WHERE CATALOG_NAME = '{1}'" -f $dmv, $SSASDatabase

        $SQLconn.Open() # Open SQL Connection
        $cmdSQL = $SQLconn.CreateCommand()

        $cmdSQL.CommandText = $sql
        $result=$cmdSQL.ExecuteNonQuery()  
        $SQLconn.Close()
    
        "dmv: $($dmv), $($data.return.root.row.length) records"   

        if ($data.return.root.row.length -eq 1) {
            #$data.return.root.row
            export-ASData $dmv $data.return.root.row
        }
        else {
            #report every 20% progress
            $mudulo =   [int]($data.return.root.row.length *.05 )
            #Loop through each row of the default table on the dataset
            for ($i = 0; $i -lt $data.return.root.row.length ; $i ++ ) {
                export-ASData $dmv $data.return.root.row[$i]
                
                $pc =[int](($i+1)/($data.return.root.row.length)*100)
                Write-Progress -Activity "..  processed $($i+1) of $($data.return.root.row.length) rows  for $dmv" -Status "$($pc)% Complete:" -PercentComplete $pc
    
                 if (($i+1)%$mudulo -eq 0 -and $i -ne 0 -or $i -eq ($data.return.root.row.length-1 ) )
                 {
                     #Write-Host " ..  processed $($pc)"
                }
            }
        }
    }
}


<#
$sql ="DELETE FROM  dbo.[{0}] WHERE CATALOG_NAME = '{1}'" -f "MeasureGroup_Aggregation",  $SSASDatabase

$sql="INSERT INTO [dbo].[MeasureGroup_Aggregation] (CATALOG_NAME,SCHEMA_NAME,CUBE_NAME,MEASUREGROUP_NAME,AggregationDesignID, AggregationDesignName, ,AggregationID, AggregationName,   CubeDimensionID , AttributeID ,CubeDimensionName, AttributeName)
VALUES ("+
    (BlanktoSQLNULL $dataRow.CATALOG_NAME) + "," + 

")"
#>