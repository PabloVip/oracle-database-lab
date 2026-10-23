-- scripts/lab5/05-reto-revision.sql — reto de la Parte F: revisión de código de una consulta del panel de atención al cliente
-- Crea índices temporales, mide la consulta rota y la reescrita, y los borra al final.
WHENEVER SQLERROR CONTINUE
ALTER SESSION SET CONTAINER = FREEPDB1;
SET SERVEROUTPUT ON FORMAT WRAPPED LINESIZE 200 FEEDBACK OFF
CREATE INDEX tiendasur.ix_cli_telefono ON tiendasur.cliente (telefono);
CREATE INDEX tiendasur.ix_cli_upper_apellidos ON tiendasur.cliente (UPPER(apellidos));
EXEC DBMS_STATS.GATHER_TABLE_STATS('TIENDASUR', 'CLIENTE', cascade => TRUE)
PROMPT ===== Reto F: consulta del PR (rota) =====
EXEC lab_tools.medir.consulta('PR rota', 'SELECT * FROM tiendasur.cliente WHERE SUBSTR(telefono, 1, 3) = ''600'' OR UPPER(apellidos) = ''GIL''')
PROMPT ===== Reescrita: LIKE '600%' (sargable) + UPPER(apellidos) servida por un índice funcional =====
EXEC lab_tools.medir.consulta('PR reescrita OR', 'SELECT * FROM tiendasur.cliente WHERE telefono LIKE ''600%'' OR UPPER(apellidos) = ''GIL''')
EXEC lab_tools.medir.consulta('PR reescrita UNION ALL', 'SELECT * FROM tiendasur.cliente WHERE telefono LIKE ''600%'' UNION ALL SELECT * FROM tiendasur.cliente WHERE UPPER(apellidos) = ''GIL'' AND LNNVL(telefono LIKE ''600%'')')
PROMPT ===== Limpieza =====
DROP INDEX tiendasur.ix_cli_telefono;
DROP INDEX tiendasur.ix_cli_upper_apellidos;
EXEC DBMS_STATS.GATHER_TABLE_STATS('TIENDASUR', 'CLIENTE', cascade => TRUE)
EXIT
