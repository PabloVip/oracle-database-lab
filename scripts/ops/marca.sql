-- scripts/ops/marca.sql — define &marca con la marca de tiempo UTC (igual que ts() en 00-config.sh)
-- Uso al principio de un script: @scripts/ops/marca  y después  SPOOL .../&marca._NN-nombre.spool.log
SET TERMOUT OFF VERIFY OFF
COLUMN marca NEW_VALUE marca NOPRINT
SELECT TO_CHAR(SYS_EXTRACT_UTC(SYSTIMESTAMP), 'YYYYMMDD"T"HH24MISS"Z"') AS marca FROM dual;
COLUMN marca CLEAR
SET TERMOUT ON
