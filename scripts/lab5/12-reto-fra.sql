-- scripts/lab5/12-reto-fra.sql — reto de la Parte M: cuánto crece la FRA tras 12-undo-y-redo (forzando el archivado)
SET LINESIZE 120 FEEDBACK OFF
ALTER SYSTEM ARCHIVE LOG CURRENT;
PROMPT ===== FRA después de 12-undo-y-redo + ARCHIVE LOG CURRENT (antes: 8.2 MB) =====
SELECT ROUND(space_used / 1048576, 1) AS fra_usado_mb FROM v$recovery_file_dest;
SELECT sequence#, ROUND(blocks * block_size / 1048576, 1) AS mb FROM v$archived_log
 WHERE name LIKE '%/fra/%' ORDER BY sequence# DESC FETCH FIRST 5 ROWS ONLY;
EXIT
