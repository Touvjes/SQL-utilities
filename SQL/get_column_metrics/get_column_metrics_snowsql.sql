-- get_column_metrics
EXECUTE IMMEDIATE $$
DECLARE
  c1 CURSOR FOR select column_name from t1;
BEGIN
    create or replace temp table test(exmaple_value varchar);
  FOR rec IN c1 DO
     LET stmt := 'INSERT INTO test SELECT top 1  '|| rec.column_name ||' FROM clm_test';
     EXECUTE IMMEDIATE stmt;
  END FOR;
  
END;
$$