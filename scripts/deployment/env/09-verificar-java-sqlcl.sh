#!/usr/bin/env bash
# scripts/deployment/env/09-verificar-java-sqlcl.sh
echo "== Java =="
java -version 2>&1
echo
echo "JAVA_HOME=$JAVA_HOME"
echo
echo "== SQLcl =="
if command -v sql > /dev/null; then
  sql -version 2>&1
else
  echo "FALTA sql (SQLcl no esta en el PATH)"
fi
echo
echo "== SQL*Plus del contenedor =="
source scripts/deployment/env/00-config.sh
set -a; source config/.env; set +a
docker exec -i "$CONT_NAME" sqlplus -S "system/\"$ORACLE_PWD\"@FREEPDB1" <<'SQL'
SHOW RELEASE
EXIT
SQL
