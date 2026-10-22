-- scripts/lab5/15-reto-alerta.sql — reto de la Parte P: una consulta que devuelve UNA fila solo si hay que despertar a alguien
-- Se ejecuta como C##OPS_RO: bash scripts/ops/ro.sh scripts/lab5/15-reto-alerta.sql
-- Regla: FRA por encima del 85 % o ninguna copia RMAN completada en las últimas 24 h. Sin filas = todo bien.
SET LINESIZE 160 FEEDBACK ON
COLUMN alerta FORMAT A110
SELECT 'ALERTA: FRA al ' || pct || ' % (umbral 85 %) · copias RMAN en 24 h: ' || rman_24h AS alerta
  FROM (SELECT ROUND(100 * f.space_used / NULLIF(f.space_limit, 0), 1) AS pct,
               (SELECT COUNT(*) FROM v$rman_backup_job_details
                 WHERE status = 'COMPLETED' AND start_time > SYSDATE - 1) AS rman_24h
          FROM v$recovery_file_dest f)
 WHERE pct > 85 OR rman_24h = 0;
EXIT
