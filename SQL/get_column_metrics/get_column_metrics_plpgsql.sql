/*
This procedure utilizes the get_column_metadata function to generate a column metadata table from a given table.
It then iterates over that table, row by row, generating metrics for each given column,
and saves the results in a table named column_metrics. 
The view can be joined back to the original column metadata table
displaying a full overview of a table's column's metadata, example, and metrics. 

*/

create or replace procedure public.get_column_metrics(schema text, tbl text)
as
$$
declare
    schema2 varchar;
    tbl2 varchar;
    v_sql varchar(max);
  row record;
begin
call public.get_column_metadata($1,$2);
drop table if exists public.column_metrics;
create table public.column_metrics(column_name varchar, example_value varchar, ct text, ctdistinct numeric, pctpopulated real, updated_at timestamp);
for row in 
      select 
        column_name
      from public.column_metadata
  loop
  v_sql := 
    'insert into public.column_metrics 
    select top 1 '
        ||chr(39)||row.column_name||chr(39)||', '
        ||row.column_name||'::text, 
        (SELECT 
            COUNT('||row.column_name||') 
            FROM '|| quote_ident(schema)||'.'|| quote_ident(tbl)||'),
        (SELECT 
            COUNT(DISTINCT '||row.column_name||')
            FROM '|| quote_ident(schema)||'.'|| quote_ident(tbl)||'),
        (SELECT 
            ROUND((((COUNT('||row.column_name||')*1.00)/(COUNT(*)*1.00))*100.00),2)
            FROM '|| quote_ident(schema)||'.'|| quote_ident(tbl)||'),
        (SELECT CURRENT_TIMESTAMP)
    from '|| quote_ident(schema)||'.'|| quote_ident(tbl);
  EXECUTE v_sql;
end loop
;
end;
$$ 
language plpgsql
;
call public.get_column_metrics('validation_test', 'data_source_7_sample')
;
select 
top 100 
cm.*,
ex.*
from public.column_metrics ex
LEFT JOIN public.column_metadata cm
on ex.column_name = cm.column_name
;
