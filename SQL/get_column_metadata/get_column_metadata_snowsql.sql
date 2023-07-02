/*
Script designed for snowflake.
This script generates column level data for specified schema and table
This table can then be used to generate schemas as is.
It can also be used as a utility when creating dynamic SQL to query each individual column of a table
*/
CREATE OR REPLACE TEMPORARY TABLE column_metadata as (
select t.table_schema, 
       t.table_name, 
       c.column_name,
       c.data_type
from information_schema.tables t
left join information_schema.columns c 
              on t.table_schema = c.table_schema 
              and t.table_name = c.table_name
where 1=1
    AND table_type != 'VIEW'
    AND table_schema = <schema>
    and t.table_name = <table_name>
order by table_schema,
         table_name
  )
