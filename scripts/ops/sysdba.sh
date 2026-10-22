#!/usr/bin/env bash
# scripts/ops/sysdba.sh — ejecuta un .sql como SYSDBA dentro del contenedor, sin contraseña.
# Autenticación del sistema operativo (OS authentication): el usuario oracle del contenedor ya pertenece
# al grupo de administradores. Corrige la crítica del Lab 3: sys/<contraseña> en la línea de comandos se ve con ps.
# Uso: bash scripts/ops/sysdba.sh <archivo.sql> [archivo-de-evidencia]
set -euo pipefail
source scripts/deployment/env/00-config.sh
SQL_FILE="${1:?Uso: sysdba.sh <archivo.sql> [archivo-de-evidencia]}"
EVIDENCIA="${2:-}"
[ -f "$SQL_FILE" ] || { echo "No existe $SQL_FILE" >&2; exit 2; }
if [ -n "$EVIDENCIA" ]; then
  mkdir -p "$(dirname "$EVIDENCIA")"
  docker exec -i "$CONT_NAME" sqlplus -s -L / as sysdba < "$SQL_FILE" | tee "$EVIDENCIA"
else
  docker exec -i "$CONT_NAME" sqlplus -s -L / as sysdba < "$SQL_FILE"
fi
