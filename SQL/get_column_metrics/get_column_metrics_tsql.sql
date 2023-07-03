DECLARE @Sql NVARCHAR(MAX);

WITH cte AS
(
    SELECT
       c.name AS ColName,
       column_id AS ColIdx,
       t.name AS TableName,
       types.name AS TypeName
    FROM sys.columns c 
    JOIN sys.tables t 
    ON c.object_id = t.object_id
    JOIN sys.types
    ON types.system_type_id = c.system_type_id 
    WHERE t.name = 'MyTable'
)
SELECT @Sql = CAST('' AS NVARCHAR(MAX)) + 'SELECT
  ''' + QUOTENAME(TableName) + ''' AS TableName, 
  t2.*
FROM
(
  SELECT ' + STRING_AGG(CAST('' AS NVARCHAR(MAX)) + '
    COUNT(CASE ' + QUOTENAME(ColName) + ' WHEN '''' THEN 1 END) AS ' + QUOTENAME(ColName + '_BlankCount') + ',
    COUNT(CASE WHEN ' + QUOTENAME(ColName) + ' <> '''' THEN 1 END) AS ' + QUOTENAME(ColName + '_NonBlankCount') + ',
    COUNT(' + QUOTENAME(ColName) + ') AS ' + QUOTENAME(ColName + '_TotalCount') + ',
    100.0 * COUNT(' + QUOTENAME(ColName) + ') / NULLIF(COUNT(*), 0) AS ' + QUOTENAME(ColName + '_PopulationPercent') + ',
    ' + CASE WHEN TypeName NOT IN ('tinyint', 'smallint', 'int') THEN 'NULL' ELSE 'COUNT(CASE ' + QUOTENAME(ColName) + ' WHEN 0 THEN 1 END)' END + ' AS ' + QUOTENAME(ColName + '_ZeroCount') + ',
    MIN(LEN(' + QUOTENAME(ColName) + ')) AS ' + QUOTENAME(ColName + '_MinLength') + ',
    MAX(LEN(' + QUOTENAME(ColName) + ')) AS ' + QUOTENAME(ColName + '_MaxLength') + ',
    CAST(MIN(' + QUOTENAME(ColName) + ') AS NVARCHAR(MAX)) AS ' + QUOTENAME(ColName + '_MinValue') + ',
    CAST(MAX(' + QUOTENAME(ColName) + ') AS NVARCHAR(MAX)) AS ' + QUOTENAME(ColName + '_MaxValue') + ',
    COUNT(DISTINCT ' + QUOTENAME(ColName) + ') AS ' + QUOTENAME(ColName + '_DistinctValueCount'), ', ') + '
  FROM ' + QUOTENAME(TableName) + '
) t1
CROSS APPLY
(
   VALUES ' + STRING_AGG(CAST('' AS NVARCHAR(MAX)) +
  '(' + 
       CAST(ColIdx AS VARCHAR(20)) + ', 
      ''' + QUOTENAME(ColName) + ''', 
      ''' + TypeName + ''', 
      ' + QUOTENAME(ColName + '_BlankCount') + ', 
      ' + QUOTENAME(ColName + '_NonBlankCount') + ', 
      ' + QUOTENAME(ColName + '_TotalCount') + ', 
      ' + QUOTENAME(ColName + '_PopulationPercent') + ', 
      ' + QUOTENAME(ColName + '_ZeroCount') + ', 
      ' + QUOTENAME(ColName + '_MinLength') + ', 
      ' + QUOTENAME(ColName + '_MaxLength') + ', 
      ' + QUOTENAME(ColName + '_MinValue') + ', 
      ' + QUOTENAME(ColName + '_MaxValue') + ', 
      ' + QUOTENAME(ColName + '_DistinctValueCount') + 
  ')', ', 
  ') + '
) t2(ColIdx, ColName, TypeName, BlankCount, NonBlankCount, TotalCount, ' +
    'PopulationPercent, ZeroCount, MinLength, MaxLength, MinValue, ' + 
    'MaxValue, DistinctValueCount)
ORDER BY ColIdx'
FROM cte
GROUP BY TableName;

--SELECT @Sql;

EXEC(@Sql);