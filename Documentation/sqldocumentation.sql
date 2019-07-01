SELECT --objects AND columns
 CASE WHEN ob.parent_object_id>0 
 THEN OBJECT_SCHEMA_NAME(ob.parent_object_id)
 + '.'+OBJECT_NAME(ob.parent_object_id)+'.'+ob.name 
 ELSE OBJECT_SCHEMA_NAME(ob.OBJECT_ID)+'.'+ob.name END 
 + CASE WHEN ep.minor_id>0 THEN '.'+col.name ELSE '' END AS PATH,
 'schema'+ CASE WHEN ob.parent_object_id>0 THEN '/table'ELSE '' END 
 + '/'+
 CASE WHEN ob.TYPE IN ('TF','FN','IF','FS','FT') THEN 'function'
 WHEN ob.TYPE IN ('P', 'PC','RF','X') THEN 'procedure' 
 WHEN ob.TYPE IN ('U','IT') THEN 'table'
 WHEN ob.TYPE='SQ' THEN 'queue'
 ELSE LOWER(ob.type_desc) END
 + CASE WHEN col.column_id IS NULL THEN '' ELSE '/column'END AS thing, 
 ep.name,VALUE 
 FROM sys.extended_properties ep
 INNER JOIN sys.objects ob ON ep.major_id=ob.OBJECT_ID AND CLASS=1
 LEFT OUTER JOIN sys.columns col 
 ON ep.major_id=col.OBJECT_ID AND CLASS=1 
 AND ep.minor_id=col.column_id
UNION ALL
SELECT --indexes
 OBJECT_SCHEMA_NAME(ob.OBJECT_ID)+'.'+OBJECT_NAME(ob.OBJECT_ID)+'.'+ix.name,
 'schema/'+ LOWER(ob.type_desc) +'/index', ep.name, VALUE
 FROM sys.extended_properties ep
 INNER JOIN sys.objects ob 
 ON ep.major_id=ob.OBJECT_ID AND CLASS=7
 INNER JOIN sys.indexes ix 
 ON ep.major_id=ix.OBJECT_ID AND CLASS=7 
 AND ep.minor_id=ix.index_id
UNION ALL
SELECT --Parameters
 OBJECT_SCHEMA_NAME(ob.OBJECT_ID)
 + '.'+OBJECT_NAME(ob.OBJECT_ID)+'.'+par.name,
 'schema/'+ LOWER(ob.type_desc) +'/parameter', ep.name,VALUE
 FROM sys.extended_properties ep
 INNER JOIN sys.objects ob 
 ON ep.major_id=ob.OBJECT_ID AND CLASS=2
 INNER JOIN sys.PARAMETERS par 
 ON ep.major_id=par.OBJECT_ID 
 AND CLASS=2 AND ep.minor_id=par.parameter_id
UNION ALL
SELECT --schemas
 sch.name, 'schema', ep.name, VALUE
 FROM sys.extended_properties ep
 INNER JOIN sys.schemas sch
 ON CLASS=3 AND ep.major_id=SCHEMA_ID
UNION ALL --Database 
SELECT DB_NAME(), '', ep.name,VALUE
 FROM sys.extended_properties ep WHERE CLASS=0 
UNION ALL--XML Schema Collections
SELECT SCHEMA_NAME(SCHEMA_ID)+'.'+XC.name, 'schema/xml_Schema_collection', ep.name,VALUE
 FROM sys.extended_properties ep
 INNER JOIN sys.xml_schema_collections xc
 ON CLASS=10 AND ep.major_id=xml_collection_id
UNION ALL
SELECT --Database Files
 df.name, 'database_file',ep.name,VALUE FROM sys.extended_properties ep
 INNER JOIN sys.database_files df ON CLASS=22 AND ep.major_id=FILE_ID
UNION ALL
SELECT --Data Spaces
 ds.name,'dataspace', ep.name,VALUE FROM sys.extended_properties ep
 INNER JOIN sys.data_spaces ds ON CLASS=20 AND ep.major_id=data_space_id
UNION ALL SELECT --USER
 dp.name,'database_principal', ep.name,VALUE FROM sys.extended_properties ep
 INNER JOIN sys.database_principals dp ON CLASS=4 AND ep.major_id=dp.principal_id
UNION ALL SELECT --PARTITION FUNCTION
 pf.name,'partition_function', ep.name,VALUE FROM sys.extended_properties ep
 INNER JOIN sys.partition_functions pf ON CLASS=21 AND ep.major_id=pf.function_id
UNION ALL SELECT --REMOTE SERVICE BINDING
 rsb.name,'remote service binding', ep.name,VALUE FROM sys.extended_properties ep
 INNER JOIN sys.remote_service_bindings rsb 
 ON CLASS=18 AND ep.major_id=rsb.remote_service_binding_id
UNION ALL SELECT --Route
 rt.name,'route', ep.name,VALUE FROM sys.extended_properties ep
 INNER JOIN sys.routes rt ON CLASS=19 AND ep.major_id=rt.route_id
UNION ALL SELECT --Service
 sv.name COLLATE DATABASE_DEFAULT ,'service', ep.name,VALUE FROM sys.extended_properties ep
 INNER JOIN sys.services sv ON CLASS=17 AND ep.major_id=sv.service_id
UNION ALL SELECT -- 'CONTRACT'
 svc.name,'service_contract', ep.name,VALUE FROM sys.service_contracts svc
 INNER JOIN sys.extended_properties ep ON CLASS=16 AND ep.major_id=svc.service_contract_id
UNION ALL SELECT -- 'MESSAGE TYPE'
 smt.name,'message_type', ep.name,VALUE FROM sys.service_message_types smt
 INNER JOIN sys.extended_properties ep ON CLASS=15 AND ep.major_id=smt.message_type_id
UNION ALL SELECT -- 'assembly'
 asy.name,'assembly', ep.name,VALUE FROM sys.assemblies asy
 INNER JOIN sys.extended_properties ep ON CLASS=5 AND ep.major_id=asy.assembly_id
/*UNION ALL SELECT --'CERTIFICATE'
 cer.name,'certificate', ep.name,value from sys.certificates cer
 INNER JOIN sys.extended_properties ep ON class=? AND ep.major_id=cer.certificate_id
UNION ALL SELECT --'ASYMMETRIC KEY'
 amk.name,'asymmetric_key', ep.name,value SELECT * from sys.asymmetric_keys amk
 INNER JOIN sys.extended_properties ep ON class=? AND ep.major_id=amk.asymmetric_key_id
SELECT --'SYMMETRIC KEY'
 smk.name,'symmetric_key', ep.name,value from sys.symmetric_keys smk
 INNER JOIN sys.services sv ON class=? AND ep.major_id=smk.symmetric_key_id */
UNION ALL SELECT -- 'PLAN GUIDE' 
 pg.name,'plan_guide', ep.name,VALUE FROM sys.plan_guides pg
 INNER JOIN sys.extended_properties ep ON CLASS=27 AND ep.major_id=pg.plan_guide_id;
