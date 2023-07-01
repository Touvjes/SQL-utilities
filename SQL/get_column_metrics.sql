create or replace procedure public.get_column_metrics()
as
$$
declare
    v_sql varchar(max);
  row record;
begin
drop table if exists public.column_metrics;
create table public.column_metrics(column_name varchar, val varchar, ct text, ctdistinct numeric, pctpopulated real, testfloat real);
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
            FROM public.data_source_7_sample),
        (SELECT 
            COUNT(DISTINCT '||row.column_name||')
            FROM public.data_source_7_sample),
        (SELECT 
            ROUND((((COUNT('||row.column_name||')*1.00)/(COUNT(*)*1.00))*100.00),2)
            FROM public.data_source_7_sample)
    from public.data_source_7_sample';
  EXECUTE v_sql;
end loop
;
end;
$$ 
language plpgsql
;
call public.get_column_metrics()
;
select 
top 100 
vd.*,
ex.*
from public.column_metrics ex
LEFT JOIN public.column_metadata cm
on ex.column_name = vd.column_name
;

