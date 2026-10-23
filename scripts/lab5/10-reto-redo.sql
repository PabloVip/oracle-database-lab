-- scripts/lab5/10-reto-redo.sql — reto de la Parte K: cambios de log por hora y redo generado
SET LINESIZE 160 PAGESIZE 50 FEEDBACK OFF
PROMPT ===== Cambios de log por hora (v$log_history, hoy) =====
SELECT TO_CHAR(first_time, 'YYYY-MM-DD HH24') AS hora, COUNT(*) AS cambios
  FROM v$log_history WHERE first_time > TRUNC(SYSDATE) GROUP BY TO_CHAR(first_time, 'YYYY-MM-DD HH24') ORDER BY 1;
PROMPT ===== Redo archivado por hora (MB), la medida que dimensiona el grupo =====
SELECT TO_CHAR(first_time, 'YYYY-MM-DD HH24') AS hora, COUNT(*) AS archivados,
       ROUND(SUM(blocks * block_size) / 1048576) AS mb_redo
  FROM v$archived_log WHERE first_time > TRUNC(SYSDATE) AND dest_id = 1 GROUP BY TO_CHAR(first_time, 'YYYY-MM-DD HH24') ORDER BY 1;
PROMPT ===== Tamaño actual de los grupos =====
SELECT group#, ROUND(bytes / 1048576) AS mb, members FROM v$log ORDER BY group#;
EXIT
