/*
This script utilizes the table generated from the get_column_metadata script to generate a column metric table from a given table.
It then iterates over that table, row by row, generating metrics for each given column,
and saves the results in a table named column_metrics. 
The table can be joined back to the original column metadata table
displaying a full overview of a table's column's metadata, example, and metrics. 

*/

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
     (SELECT max('|| rec.column_name ||')
     FROM '||schema_name||'.'||table_name||'
     WHERE '|| rec.column_name ||' IS NOT NULL)                     as max_value,
     (SELECT min('|| rec.column_name ||')
     FROM '||schema_name||'.'||table_name||'
     WHERE '|| rec.column_name ||' IS NOT NULL)                     as min_value,
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
SELECT 
meta.*,
metric.*
FROM column_metrics metric
LEFT JOIN column_metadata meta on
metric.column_name = meta.column_name
;

 