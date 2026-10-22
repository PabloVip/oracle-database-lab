-- scripts/lab5/08-reto-mttr.sql — reto de la Parte I: el MTTR estimado bajo carga (sin checkpoint)
SET LINESIZE 160 PAGESIZE 50 FEEDBACK OFF
PROMPT ===== Antes del UPDATE =====
SELECT estimated_mttr, actual_redo_blks, recovery_estimated_ios FROM v$instance_recovery;
ALTER SESSION SET CONTAINER = FREEPDB1;
UPDATE admin_academia.aca_estudiantes SET estado = estado;
COMMIT;
ALTER SESSION SET CONTAINER = CDB$ROOT;
PROMPT ===== Justo después del UPDATE de 20 000 filas + COMMIT (sin checkpoint) =====
SELECT estimated_mttr, actual_redo_blks, recovery_estimated_ios FROM v$instance_recovery;
EXIT
