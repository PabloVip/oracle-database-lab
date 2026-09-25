-- scripts/deployment/env/07-primera-conexion.sql
-- Primera conexion a FREEPDB1 como SYSTEM. Uso:
-- docker exec -i "$CONT_NAME" sqlplus -S "system/\"$ORACLE_PWD\"@FREEPDB1" < scripts/deployment/env/07-primera-conexion.sql
SET ECHO ON
SET LINESIZE 120
SELECT 'CONEXION_OK' AS estado FROM DUAL;
SELECT CDB, NAME, CON_ID FROM V$DATABASE;
SELECT NAME, OPEN_MODE, RESTRICTED FROM V$PDBS;
SELECT BANNER FROM V$VERSION WHERE ROWNUM = 1;
SHOW CON_NAME
EXIT
