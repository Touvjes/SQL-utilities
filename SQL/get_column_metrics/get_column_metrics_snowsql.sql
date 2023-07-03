EXECUTE IMMEDIATE $$
DECLARE
  schema_name := '<schema>';
  table_name := '<table>';
  c1 CURSOR FOR select column_name from t1;
BEGIN
    create or replace temp table column_metrics(column_name varchar, example_value varchar, ct varchar, ctdistinct numeric, pctpopulated float, updated_at timestamp);
  FOR rec IN c1 DO
     LET cname varchar := rec.column_name;
     LET stmt := 
     'INSERT INTO column_metrics 
     SELECT top 1 
     '''|| cname ||'''                                              as column_name,  
     (SELECT top 1 '|| rec.column_name ||'
     FROM '||schema_name||'.'||table_name||'
     WHERE '|| rec.column_name ||' IS NOT NULL)                     as exmaple_value,
     (SELECT 
       COUNT('||rec.column_name||') 
       FROM '||schema_name||'.'||table_name||')                     as ct,
     (SELECT 
       COUNT(DISTINCT '||rec.column_name||') 
       FROM '||schema_name||'.'||table_name||')                     as ctdistinct,
     (SELECT 
       (COUNT('||rec.column_name||')/(COUNT(*)))*100
       FROM '||schema_name||'.'||table_name||')                     as pctpopulated,
       
     CURRENT_TIMESTAMP                                              as timestamp
       
     FROM '||schema_name||'.'||table_name;
     EXECUTE IMMEDIATE stmt;     
  END FOR;
END;
$$
;
//
SELECT * FROM column_metrics;
