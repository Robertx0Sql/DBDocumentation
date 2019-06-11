SELECT --objects AND columns
 CASE WHEN ob.parent_object_id>0 
 THEN OBJECT_SCHEMA_NAME(ob.parent_object_id)
 + '.'+OBJECT_NAME(ob.parent_object_id)+'.'+ob.name 
 ELSE OBJECT_SCHEMA_NAME(ob.object_id)+'.'+ob.name END 
 + CASE WHEN ep.minor_id>0 THEN '.'+col.name ELSE '' END AS path,
 'schema'+ CASE WHEN ob.parent_object_id>0 THEN '/table'ELSE '' END 
 + '/'+
 CASE WHEN ob.type IN ('TF','FN','IF','FS','FT') THEN 'function'
 WHEN ob.type IN ('P', 'PC','RF','X') then 'procedure' 
 WHEN ob.type IN ('U','IT') THEN 'table'
 WHEN ob.type='SQ' THEN 'queue'
 ELSE LOWER(ob.type_desc) end
 + CASE WHEN col.column_id IS NULL THEN '' ELSE '/column'END AS thing, 
 ep.name,value 
 FROM sys.extended_properties ep
 inner join sys.objects ob ON ep.major_id=ob.OBJECT_ID AND class=1
 LEFT outer join sys.columns col 
 ON ep.major_id=col.Object_id AND class=1 
 AND ep.minor_id=col.column_id
UNION ALL
SELECT --indexes
 OBJECT_SCHEMA_NAME(ob.object_id)+'.'+OBJECT_NAME(ob.object_id)+'.'+ix.name,
 'schema/'+ LOWER(ob.type_desc) +'/index', ep.name, value
 FROM sys.extended_properties ep
 inner join sys.objects ob 
 ON ep.major_id=ob.OBJECT_ID AND class=7
 inner join sys.indexes ix 
 ON ep.major_id=ix.Object_id AND class=7 
 AND ep.minor_id=ix.index_id
UNION ALL
SELECT --Parameters
 OBJECT_SCHEMA_NAME(ob.object_id)
 + '.'+OBJECT_NAME(ob.object_id)+'.'+par.name,
 'schema/'+ LOWER(ob.type_desc) +'/parameter', ep.name,value
 FROM sys.extended_properties ep
 inner join sys.objects ob 
 ON ep.major_id=ob.OBJECT_ID AND class=2
 inner join sys.parameters par 
 ON ep.major_id=par.Object_id 
 AND class=2 AND ep.minor_id=par.parameter_id
UNION all
SELECT --schemas
 sch.name, 'schema', ep.name, value
 FROM sys.extended_properties ep
 INNER JOIN sys.schemas sch
 ON class=3 AND ep.major_id=SCHEMA_ID
UNION all --Database 
SELECT DB_NAME(), '', ep.name,value
 FROM sys.extended_properties ep where class=0 
UNION all--XML Schema Collections
SELECT SCHEMA_NAME(SCHEMA_ID)+'.'+XC.name, 'schema/xml_Schema_collection', ep.name,value
 FROM sys.extended_properties ep
 INNER JOIN sys.xml_schema_collections xc
 ON class=10 AND ep.major_id=xml_collection_id
UNION all
SELECT --Database Files
 df.name, 'database_file',ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.database_files df ON class=22 AND ep.major_id=file_id
UNION all
SELECT --Data Spaces
 ds.name,'dataspace', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.data_spaces ds ON class=20 AND ep.major_id=data_space_id
UNION ALL SELECT --USER
 dp.name,'database_principal', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.database_principals dp ON class=4 AND ep.major_id=dp.principal_id
UNION ALL SELECT --PARTITION FUNCTION
 pf.name,'partition_function', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.partition_functions pf ON class=21 AND ep.major_id=pf.function_id
UNION ALL SELECT --REMOTE SERVICE BINDING
 rsb.name,'remote service binding', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.remote_service_bindings rsb 
 ON class=18 AND ep.major_id=rsb.remote_service_binding_id
UNION ALL SELECT --Route
 rt.name,'route', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.routes rt ON class=19 AND ep.major_id=rt.route_id
UNION ALL SELECT --Service
 sv.name COLLATE DATABASE_DEFAULT ,'service', ep.name,value FROM sys.extended_properties ep
 INNER JOIN sys.services sv ON class=17 AND ep.major_id=sv.service_id
UNION ALL SELECT -- 'CONTRACT'
 svc.name,'service_contract', ep.name,value FROM sys.service_contracts svc
 INNER JOIN sys.extended_properties ep ON class=16 AND ep.major_id=svc.service_contract_id
UNION ALL SELECT -- 'MESSAGE TYPE'
 smt.name,'message_type', ep.name,value FROM sys.service_message_types smt
 INNER JOIN sys.extended_properties ep ON class=15 AND ep.major_id=smt.message_type_id
UNION ALL SELECT -- 'assembly'
 asy.name,'assembly', ep.name,value FROM sys.assemblies asy
 INNER JOIN sys.extended_properties ep ON class=5 AND ep.major_id=asy.assembly_id
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
 pg.name,'plan_guide', ep.name,value FROM sys.plan_guides pg
 INNER JOIN sys.extended_properties ep ON class=27 AND ep.major_id=pg.plan_guide_id
