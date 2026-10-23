-- scripts/lab5/03-reto-q9.sql — reto de la Parte D: ¿índice cubriente para Q9 (20 pedidos más recientes, todas las columnas)?
ALTER SESSION SET CONTAINER = FREEPDB1;
SET SERVEROUTPUT ON FORMAT WRAPPED LINESIZE 200 FEEDBACK OFF
PROMPT ===== Reto D: Q9 con IX_PED_FECHA tal cual =====
EXEC lab_tools.medir.consulta('Q9 actual', 'SELECT * FROM tiendasur.pedido ORDER BY fecha_pedido DESC FETCH FIRST 20 ROWS ONLY')
PROMPT ===== Tamaño de la tabla y del índice actual (lo que costaría duplicar la tabla en un índice cubriente) =====
SET LINESIZE 120
COLUMN segment_name FORMAT A16
SELECT segment_name, segment_type, ROUND(bytes / 1048576, 1) AS mb
  FROM dba_segments WHERE owner = 'TIENDASUR' AND segment_name IN ('PEDIDO', 'IX_PED_FECHA', 'PK_PEDIDO') ORDER BY 1;
EXIT
