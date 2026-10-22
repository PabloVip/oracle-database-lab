SET LINESIZE 160 PAGESIZE 50 FEEDBACK OFF
ALTER SESSION SET CONTAINER = FREEPDB1;
PROMPT ===== Reto B: filas por bloque de TIENDASUR.PEDIDO (DBMS_ROWID) frente a NUM_ROWS / BLOCKS =====
SELECT MIN(n) AS min_filas, ROUND(AVG(n), 1) AS media_filas, MAX(n) AS max_filas, COUNT(*) AS bloques_con_filas
  FROM (SELECT DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID) AS blk, COUNT(*) AS n
          FROM tiendasur.pedido GROUP BY DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID), DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID));
SELECT num_rows, blocks, ROUND(num_rows / blocks, 1) AS bfr_estadisticas, avg_row_len
  FROM dba_tables WHERE owner = 'TIENDASUR' AND table_name = 'PEDIDO';
PROMPT -- Distribución: cuántos bloques tienen cada número de filas
SELECT n AS filas_en_bloque, COUNT(*) AS bloques
  FROM (SELECT COUNT(*) AS n FROM tiendasur.pedido
         GROUP BY DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID), DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID))
 GROUP BY n ORDER BY bloques DESC FETCH FIRST 8 ROWS ONLY;
EXIT
