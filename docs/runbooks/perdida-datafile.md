# Runbook · Pérdida de un datafile (oralab-26ai)

> Para la persona de guardia que no ha hecho el Lab 5. Probado en el simulacro D
> (`scripts/lab5/14d-perdida-datafile.sh`): RPO 0, RTO 8-9 s.

## 1. Síntoma

Las consultas sobre un tablespace fallan con este trío (y el alert log repite las mismas líneas):

```
ORA-01116: error in opening database file 26
ORA-01110: data file 26: '/opt/oracle/oradata/FREE/FREEPDB1/academia01.dbf'
ORA-27041: unable to open file   (Linux Error: 2: No such file or directory)
```

Si un proceso de fondo detecta el fallo antes, el alert log muestra además **ORA-63999** y Oracle **cierra la PDB
entera** (queda `MOUNTED`): entonces fallan todas las consultas de esa PDB, no solo las de un tablespace.

## 2. Comprobaciones previas (antes de tocar nada)

```bash
docker exec -it oralab-26ai rman target /
```
```sql
-- en SQL*Plus como SYSDBA (docker exec -it oralab-26ai sqlplus / as sysdba)
SELECT log_mode FROM v$database;                         -- debe ser ARCHIVELOG; si no, ir al punto 5
SELECT name, open_mode FROM v$pdbs;                      -- ¿la PDB sigue READ WRITE o está MOUNTED?
SELECT file#, name, status FROM v$datafile WHERE file# = 26;
```
```
RMAN> LIST BACKUP OF DATAFILE 26;                        -- tiene que existir una copia; si no, ir al punto 5
```

Si la PDB está **cerrándose** (ORA-01089), esperar a que quede `MOUNTED` antes de lanzar el RESTORE: un cierre a
medias y un RESTORE a la vez se pisan.

## 3. Reparación

**Camino A · la PDB sigue abierta (solo ese tablespace está caído)**

```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER DATABASE DATAFILE 26 OFFLINE;
```
```
RMAN> RESTORE DATAFILE 26;
RMAN> RECOVER DATAFILE 26;
```
```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER DATABASE DATAFILE 26 ONLINE;
```

**Camino B · Oracle cerró la PDB (ORA-63999, PDB `MOUNTED`)**

```
RMAN> RESTORE DATAFILE 26;
RMAN> RECOVER DATAFILE 26;
```
```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER DATABASE DATAFILE 26 ONLINE;
ALTER SESSION SET CONTAINER = CDB$ROOT;
ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;
```

## 4. Verificar que funcionó

```sql
SELECT name, open_mode FROM v$pdbs;                      -- FREEPDB1 READ WRITE
ALTER SESSION SET CONTAINER = FREEPDB1;
SELECT COUNT(*) FROM admin_academia.aca_estudiantes;     -- fila de control: 20000
```

Al reabrir la PDB el alert log puede registrar ORA-01113/ORA-01110 de sus otros archivos: es la comprobación de
cabeceras de la reapertura, no un incidente nuevo, si la PDB termina `READ WRITE`.

## 5. Si no hay ARCHIVELOG o no hay copia RMAN

No improvisar: parar la base y restaurar la última copia en frío
(`bash scripts/ops/restaurar-estado.sh backups/<fecha>_<etiqueta>`). Se pierde todo lo posterior a esa copia
(RPO = antigüedad de la copia). Avisar antes de restaurar.

## 6. A quién avisar

1. Al responsable de la base (propietario del repositorio `oracle-database-lab`): al empezar y al terminar.
2. A los usuarios de la PDB afectada, si estuvo cerrada: cuánto tiempo y que no hubo pérdida de datos (o cuánta).
3. Abrir una Issue con la cronología (fallo, diagnóstico, reparación), los ORA- y el RTO medido.
