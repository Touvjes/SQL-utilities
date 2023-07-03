-- get_column_metrics
EXECUTE IMMEDIATE $$
DECLARE
  schema_name := 'OFFICEALLY';
  table_name := 'CLM_TEST';
  c1 CURSOR FOR select column_name from t1;
BEGIN
    create or replace temp table column_metrics(column_name varchar, example_value varchar, updated_at timestamp);
  FOR rec IN c1 DO
     LET cname varchar := rec.column_name;
     LET stmt := 
     'INSERT INTO column_metrics 
     SELECT top 1 
     '''|| cname ||'''              as column_name,  
     '|| rec.column_name ||'        as exmaple_value,
     CURRENT_TIMESTAMP              as timestamp
     FROM '||schema_name||'.'||table_name;
     EXECUTE IMMEDIATE stmt;     
  END FOR;
    
END;
$$
;
//
//SELECT * FROM clm_test
SELECT * FROM column_metrics;
SELECT  * FROM TEST;