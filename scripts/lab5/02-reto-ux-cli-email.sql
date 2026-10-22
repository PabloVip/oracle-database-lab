-- scripts/lab5/02-reto-ux-cli-email.sql — reto de la Parte C: altura calculada frente a medida de UX_CLI_EMAIL
SET LINESIZE 170 PAGESIZE 50 FEEDBACK OFF
ALTER SESSION SET CONTAINER = FREEPDB1;
ANALYZE INDEX tiendasur.ux_cli_email VALIDATE STRUCTURE;
PROMPT ===== Reto C: INDEX_STATS de UX_CLI_EMAIL =====
SELECT name, height, lf_rows, lf_blks, br_rows, br_blks, ROUND(lf_rows_len / lf_rows, 1) AS bytes_por_entrada_hoja,
       pct_used, del_lf_rows
  FROM index_stats;
PROMPT ===== y PK_CLIENTE para comparar =====
ANALYZE INDEX tiendasur.pk_cliente VALIDATE STRUCTURE;
SELECT name, height, lf_rows, lf_blks, br_rows, br_blks, ROUND(lf_rows_len / lf_rows, 1) AS bytes_por_entrada_hoja,
       pct_used, del_lf_rows
  FROM index_stats;
EXIT
