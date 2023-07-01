/*
Script only works with plpgsql compliant sql variants: postgres, redshift, oracle(?)
This script generates column level data for specified schema and table
This table can then be used to generate schemas as is.
It can also be used as a utility when creating dynamic SQL to query each individual column of a table
*/

create or replace procedure public.get_column_metadata(schema text, tbl text)
as
$$
declare
  row record;
begin
drop table if exists public.column_metadata;
create table public.column_metadata(table_schema varchar,table_name varchar, column_name varchar, data_type varchar);
for row in 
      select 
           cast(table_schema as varchar) as "table_schema"
          ,cast(table_name as varchar) as "table_name"
          ,cast(column_name as varchar) as "column_name"
          ,cast(data_type   as varchar) as "data_type"
      from information_schema.columns
      where 1=1 
      AND table_schema = $1 --comment out both this line and next line to get all tables across all schemas
      AND table_name =  $2 -- comment out just this line to get all tables in a given schema

  loop
  insert into public.column_metadata(table_schema,table_name,column_name, data_type) values (row.table_schema,row.table_name,row.column_name, row.data_type);
end loop
;
end;
$$ 
language plpgsql
;
call public.get_column_metadata(<schema>,<table>)
;
select top 100 * from public.column_metadata;

