#CubeDocfromDMV.ps1

param([string]$SSASServer = ".", 
    [string]$SSASDatabase = "SLCombinedCube"
    , [string]$SqlServerDoc = "."
    , [string]$SqlDatabaseDoc = "Documentation"
    #,[string]$ServerConnection =$(Throw "Parameter missing: -Server Connection")
)
function BoolToSqlBit ([string]$val) {
    if ($val -eq $true) { "1" }else { "0" }
}
function BlanktoSQLNULL([string]$val) {
    #$val
    if ($val -eq "" ) { "NULL" } else { "'" + $val.Replace("'", "''") + "'" }
}
#Import adomdClient namespace, use void to hide the default ouput
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices.AdomdClient") 

$DMV_array = "MDSCHEMA_CUBES" , "MDSCHEMA_DIMENSIONS", "MDSCHEMA_LEVELS", "MDSCHEMA_MEASUREGROUP_DIMENSIONS", "MDSCHEMA_MEASUREGROUPS", "MDSCHEMA_MEASURES"

[string]$ASconnectionString = "Datasource=" + $SSASServer + ";Initial Catalog=" + $SSASDatabase;

 

$SQLconn = New-Object System.Data.SqlClient.SqlConnection 
$SQLcmd = New-Object System.Data.SqlClient.SqlCommand

$SQLConnectionString = "Data Source={0};Initial Catalog={1};Integrated Security=SSPI;" -f $SqlServerDoc, $SqlDatabaseDoc
$SQLConnectionString 
$SQLconn.ConnectionString = $SQLConnectionString 


foreach ($dmv in $DMV_array) { 

    #Get only the active sessions and remove yourself
    [string]$commandText = 'SELECT * FROM $system.' + $dmv ;
    [System.Data.DataSet]$dataset = new-object System.Data.DataSet;

    [string]$SQLcmd = "";
    #try
    if ( 1 -eq 1) {
        # Open the connection to the server 
        [Microsoft.AnalysisServices.AdomdClient.AdomdConnection]$conAS = new-object Microsoft.AnalysisServices.AdomdClient.AdomdConnection($ASconnectionString);
        $conAS.Open();

        # Create the command object and set the mdx query text
        [Microsoft.AnalysisServices.AdomdClient.AdomdCommand]$cmdAS = $conAS.CreateCommand();
        $cmdAS.CommandText = $commandText;

        #create a dataadapter and use it to fill a dataset
        [Microsoft.AnalysisServices.AdomdClient.AdomdDataAdapter]$asDataAdapter = new-object Microsoft.AnalysisServices.AdomdClient.AdomdDataAdapter($cmdAS) ;

        [void]$asDataAdapter.Fill($dataset);
        #Close the connection as we dont need it anymore
        $conAS.Close();

  
  
    
        $sql = "DELETE FROM  dbo.[{0}] WHERE CATALOG_NAME = '{1}'" -f $dmv, $SSASDatabase
        #$sql 

        $SQLconn.Open() # Open SQL Connection
        $cmdSQL = $SQLconn.CreateCommand()

        $cmdSQL.CommandText = $sql
        $cmdSQL.ExecuteNonQuery()
        $SQLconn.Close()
    
    
    

        #Loop through each row of the default table on the dataset
        for ($i = 0; $i -lt $dataset.Tables[0].Rows.Count; $i ++ ) {
    
            switch ($dmv) {
                "MDSCHEMA_CUBES" {
                    "MDSCHEMA_CUBES" 
      
                    $SQLCmd = " INSERT INTO dbo.[MDSCHEMA_CUBES] 
([CATALOG_NAME] ,[SCHEMA_NAME] ,[CUBE_NAME] ,[CUBE_TYPE] ,[CUBE_GUID] ,[CREATED_ON] ,[LAST_SCHEMA_UPDATE] ,[SCHEMA_UPDATED_BY] ,[LAST_DATA_UPDATE] ,[DATA_UPDATED_BY] ,[DESCRIPTION] ,[IS_DRILLTHROUGH_ENABLED] ,[IS_LINKABLE] ,[IS_WRITE_ENABLED] ,[IS_SQL_ENABLED] ,[CUBE_CAPTION] ,[BASE_CUBE_NAME] ,[CUBE_Source]) 
VALUES('" + $dataset.Tables[0].Rows[$i].CATALOG_NAME + "'" + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].SCHEMA_NAME ) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CUBE_NAME ) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CUBE_TYPE ) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CUBE_GUID ) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CREATED_ON ) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LAST_SCHEMA_UPDATE ) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].SCHEMA_UPDATED_BY ) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LAST_DATA_UPDATE ) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DATA_UPDATED_BY ) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DESCRIPTION ) + "," + 
                    (BoolToSqlBit $dataset.Tables[0].Rows[$i].IS_DRILLTHROUGH_ENABLED ) + "," + 
                    (BoolToSqlBit $dataset.Tables[0].Rows[$i].IS_LINKABLE) + "," + 
                    (BoolToSqlBit $dataset.Tables[0].Rows[$i].IS_WRITE_ENABLED) + "," + 
                    (BoolToSqlBit $dataset.Tables[0].Rows[$i].IS_SQL_ENABLED) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CUBE_CAPTION ) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].BASE_CUBE_NAME ) + "," + 
                    ( $dataset.Tables[0].Rows[$i].CUBE_Source ) +    
                    ")" 

                    #$SQLCmd

                    $SQLconn.Open() # Open SQL Connection
                    $cmdSQL = $SQLconn.CreateCommand()

                    $cmdSQL.CommandText = $SQLCmd
                    $cmdSQL.ExecuteNonQuery()
                    $SQLconn.Close()

                } 

                "MDSCHEMA_DIMENSIONS" {
                    "MDSCHEMA_DIMENSIONS" ; $i
    
                    $sql = "INSERT INTO [dbo].[MDSCHEMA_DIMENSIONS]           (CATALOG_NAME,SCHEMA_NAME,CUBE_NAME,DIMENSION_NAME,DIMENSION_UNIQUE_NAME,DIMENSION_GUID,DIMENSION_CAPTION,DIMENSION_ORDINAL,DIMENSION_TYPE,DIMENSION_CARDINALITY,DEFAULT_HIERARCHY,DESCRIPTION,IS_VIRTUAL,IS_READWRITE,DIMENSION_UNIQUE_SETTINGS,DIMENSION_MASTER_NAME,DIMENSION_IS_VISIBLE)
VALUES (" + 

                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CATALOG_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].SCHEMA_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CUBE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_UNIQUE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_GUID) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_CAPTION) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_ORDINAL) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_TYPE) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_CARDINALITY) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DEFAULT_HIERARCHY) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DESCRIPTION) + "," + 
                    (BoolToSqlBit $dataset.Tables[0].Rows[$i].IS_VIRTUAL) + "," + 
                    (BoolToSqlBit $dataset.Tables[0].Rows[$i].IS_READWRITE) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_UNIQUE_SETTINGS) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_MASTER_NAME) + "," + 
                    (BoolToSqlBit $dataset.Tables[0].Rows[$i].DIMENSION_IS_VISIBLE) + "
)"

                    #$sql

                    $SQLconn.Open() # Open SQL Connection
                    $cmdSQL = $SQLconn.CreateCommand()

                    $cmdSQL.CommandText = $sql
                    $cmdSQL.ExecuteNonQuery()
                    $SQLconn.Close()
                } 
                "MDSCHEMA_LEVELS" {
                    "MDSCHEMA_LEVELS" ; $i
 
                    $sql = "INSERT INTO [dbo].[MDSCHEMA_LEVELS]           (CATALOG_NAME,SCHEMA_NAME,CUBE_NAME,DIMENSION_UNIQUE_NAME,HIERARCHY_UNIQUE_NAME,LEVEL_NAME,LEVEL_UNIQUE_NAME,LEVEL_GUID,LEVEL_CAPTION,LEVEL_NUMBER,LEVEL_CARDINALITY,LEVEL_TYPE,DESCRIPTION,CUSTOM_ROLLUP_SETTINGS,LEVEL_UNIQUE_SETTINGS,LEVEL_IS_VISIBLE,LEVEL_ORDERING_PROPERTY,LEVEL_DBTYPE,LEVEL_MASTER_UNIQUE_NAME,LEVEL_NAME_SQL_COLUMN_NAME,LEVEL_KEY_SQL_COLUMN_NAME,LEVEL_UNIQUE_NAME_SQL_COLUMN_NAME,LEVEL_ATTRIBUTE_HIERARCHY_NAME,LEVEL_KEY_CARDINALITY,LEVEL_ORIGIN)
VALUES (" +
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CATALOG_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].SCHEMA_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CUBE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_UNIQUE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].HIERARCHY_UNIQUE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_UNIQUE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_GUID) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_CAPTION) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_NUMBER) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_CARDINALITY) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_TYPE) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DESCRIPTION) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CUSTOM_ROLLUP_SETTINGS) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_UNIQUE_SETTINGS) + "," + 
                    (BoolToSqlBit $dataset.Tables[0].Rows[$i].LEVEL_IS_VISIBLE) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_ORDERING_PROPERTY) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_DBTYPE) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_MASTER_UNIQUE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_NAME_SQL_COLUMN_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_KEY_SQL_COLUMN_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_UNIQUE_NAME_SQL_COLUMN_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_ATTRIBUTE_HIERARCHY_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_KEY_CARDINALITY) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVEL_ORIGIN) + "
)"

                    #$sql

                    $SQLconn.Open() # Open SQL Connection
                    $cmdSQL = $SQLconn.CreateCommand()

                    $cmdSQL.CommandText = $sql
                    $cmdSQL.ExecuteNonQuery()
                    $SQLconn.Close()

                } 
                "MDSCHEMA_MEASUREGROUP_DIMENSIONS" {
                    "MDSCHEMA_MEASUREGROUP_DIMENSIONS." ; $i
                    $sql = "INSERT INTO [dbo].[MDSCHEMA_MEASUREGROUP_DIMENSIONS] (CATALOG_NAME,SCHEMA_NAME,CUBE_NAME,MEASUREGROUP_NAME,MEASUREGROUP_CARDINALITY,DIMENSION_UNIQUE_NAME,DIMENSION_CARDINALITY,DIMENSION_IS_VISIBLE,DIMENSION_IS_FACT_DIMENSION,DIMENSION_PATH,DIMENSION_GRANULARITY)
VALUES (" +
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CATALOG_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].SCHEMA_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CUBE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASUREGROUP_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASUREGROUP_CARDINALITY) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_UNIQUE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_CARDINALITY) + "," + 
                    (BoolToSqlBit $dataset.Tables[0].Rows[$i].DIMENSION_IS_VISIBLE) + "," + 
                    (BoolToSqlBit $dataset.Tables[0].Rows[$i].DIMENSION_IS_FACT_DIMENSION) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_PATH) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DIMENSION_GRANULARITY) + 

                    ")"
                    #$sql

                    $SQLconn.Open() # Open SQL Connection
                    $cmdSQL = $SQLconn.CreateCommand()

                    $cmdSQL.CommandText = $sql
                    $cmdSQL.ExecuteNonQuery()
                    $SQLconn.Close()

                } 
                "MDSCHEMA_MEASUREGROUPS" {
                    "MDSCHEMA_MEASUREGROUPS." ; $i
                    $sql = "INSERT INTO [dbo].[MDSCHEMA_MEASUREGROUPS] (CATALOG_NAME,SCHEMA_NAME,CUBE_NAME,MEASUREGROUP_NAME,DESCRIPTION,IS_WRITE_ENABLED,MEASUREGROUP_CAPTION)
VALUES (" +
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CATALOG_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].SCHEMA_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CUBE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASUREGROUP_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DESCRIPTION) + "," + 
                    (BoolToSqlBit $dataset.Tables[0].Rows[$i].IS_WRITE_ENABLED) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASUREGROUP_CAPTION) + 
                    ")"
                    #$sql

                    $SQLconn.Open() # Open SQL Connection
                    $cmdSQL = $SQLconn.CreateCommand()

                    $cmdSQL.CommandText = $sql
                    $cmdSQL.ExecuteNonQuery()
                    $SQLconn.Close()
                } 
                "MDSCHEMA_MEASURES" {
                    "MDSCHEMA_MEASURES." ; $i

                    $sql = "INSERT INTO [dbo].[MDSCHEMA_MEASURES] (CATALOG_NAME,SCHEMA_NAME,CUBE_NAME,MEASURE_NAME,MEASURE_UNIQUE_NAME,MEASURE_CAPTION,MEASURE_GUID,MEASURE_AGGREGATOR,DATA_TYPE,NUMERIC_PRECISION,NUMERIC_SCALE,MEASURE_UNITS,DESCRIPTION,EXPRESSION,MEASURE_IS_VISIBLE,LEVELS_LIST,MEASURE_NAME_SQL_COLUMN_NAME,MEASURE_UNQUALIFIED_CAPTION,MEASUREGROUP_NAME,MEASURE_DISPLAY_FOLDER,DEFAULT_FORMAT_STRING)
VALUES (" +
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CATALOG_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].SCHEMA_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CUBE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASURE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASURE_UNIQUE_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASURE_CAPTION) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASURE_GUID) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASURE_AGGREGATOR) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DATA_TYPE) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].NUMERIC_PRECISION) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].NUMERIC_SCALE) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASURE_UNITS) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DESCRIPTION) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].EXPRESSION) + "," + 
                    (BoolToSqlBit $dataset.Tables[0].Rows[$i].MEASURE_IS_VISIBLE) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].LEVELS_LIST) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASURE_NAME_SQL_COLUMN_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASURE_UNQUALIFIED_CAPTION) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASUREGROUP_NAME) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].MEASURE_DISPLAY_FOLDER) + "," + 
                    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].DEFAULT_FORMAT_STRING) + 
                    ")"

                    #$sql

                    $SQLconn.Open() # Open SQL Connection
                    $cmdSQL = $SQLconn.CreateCommand()

                    $cmdSQL.CommandText = $sql
                    $cmdSQL.ExecuteNonQuery()
                    $SQLconn.Close()
                } 

    
            }

        }


   
    }
}


<#
$sql ="DELETE FROM  dbo.[{0}] WHERE CATALOG_NAME = '{1}'" -f "MeasureGroup_Aggregation",  $SSASDatabase

$sql="INSERT INTO [dbo].[MeasureGroup_Aggregation] (CATALOG_NAME,SCHEMA_NAME,CUBE_NAME,MEASUREGROUP_NAME,AggregationDesignID, AggregationDesignName, ,AggregationID, AggregationName,   CubeDimensionID , AttributeID ,CubeDimensionName, AttributeName)
VALUES ("+
    (BlanktoSQLNULL $dataset.Tables[0].Rows[$i].CATALOG_NAME) + "," + 

")"
#>