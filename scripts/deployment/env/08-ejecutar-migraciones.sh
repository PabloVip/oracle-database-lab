#!/usr/bin/env bash
# scripts/deployment/env/08-ejecutar-migraciones.sh
# Ejecuta V000 y V001 en orden contra FREEPDB1. Uso:
#   bash scripts/deployment/env/08-ejecutar-migraciones.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh
set -a; source config/.env; set +a

TMPDIR_MIG="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_MIG"' EXIT
sed "s/__APP_PWD__/${APP_USER_PWD}/g" database/migrations/V000__tablespaces_usuarios.sql > "$TMPDIR_MIG/V000.sql"

echo "== V000: tablespaces y usuarios =="
docker exec -i "$CONT_NAME" sqlplus -S "system/\"$ORACLE_PWD\"@FREEPDB1" < "$TMPDIR_MIG/V000.sql"

echo "== V001: tablas de negocio =="
docker exec -i "$CONT_NAME" sqlplus -S "system/\"$ORACLE_PWD\"@FREEPDB1" < database/migrations/V001__tablas_negocio.sql

echo "== Verificacion: usuarios, tablespaces y tablas =="
docker exec -i "$CONT_NAME" sqlplus -S "system/\"$ORACLE_PWD\"@FREEPDB1" <<'SQL'
SET LINESIZE 120
SELECT USERNAME, DEFAULT_TABLESPACE FROM DBA_USERS WHERE USERNAME IN ('ACADEMIA','CLINICA','RETAIL','LOGISTICA','FINTECH') ORDER BY 1;
SELECT TABLESPACE_NAME FROM DBA_TABLESPACES WHERE TABLESPACE_NAME LIKE 'TS\_%' ESCAPE '\' ORDER BY 1;
SELECT OWNER, TABLE_NAME FROM DBA_TABLES WHERE OWNER IN ('ACADEMIA','CLINICA','RETAIL','LOGISTICA','FINTECH') ORDER BY 1, 2;
EXIT
SQL
