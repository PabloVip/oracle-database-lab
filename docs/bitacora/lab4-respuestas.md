# Lab 4 — Oracle DBA Workflow I · Respuestas

> Issue: #10 · Branch: `chore/10-oracle-dba-workflow-i`
>
> Los datos concretos (SCN, PID, tamaños, fechas) salen de MI evidencia, en `docs/bitacora/lab4/evidencia/`;
> cada respuesta cita el archivo del que salen.

## Puntos de control

**Parte B — ¿Cuántos archivos salieron como FUERA en el paso 3 del backup?**
0 archivos (evidencia `script/20261022T204729Z_00-backup-lab3.script.log`, paso 3; `manifiesto.txt`:
`archivos_fuera_del_volumen=0`). Los cinco datafiles de negocio (`academia01.dbf`, `clinica01.dbf`,
`fintech01.dbf`, `logistica01.dbf` y `retail01.dbf`) estaban en `$ORACLE_HOME/dbs`, pero en esta imagen
`$ORACLE_HOME/dbs` es un enlace simbólico a `/opt/oracle/oradata/dbconfig/FREE/dbs`, es decir, al volumen:
`readlink -f` resuelve la ruta real dentro de `/opt/oracle/oradata` y salen "dentro", igual que el SPFILE y el
password file. Estaban en el volumen, pero en una carpeta no estándar (evidencia 01, bloque B: "DENTRO del
volumen, pero en carpeta no estándar"), y por eso se reubicaron igualmente a `FREE/FREEPDB1`.

**Parte E — Errores esperados.**
- ORA-01507 en NOMOUNT: `v$database` se alimenta del control file, que en NOMOUNT aún no está abierto.
  `v$parameter` sí responde porque los parámetros ya están en la memoria de la instancia (leídos del SPFILE).
- ORA-01219 en MOUNT: `dba_tables` es una vista del diccionario, que vive en el tablespace SYSTEM (un datafile
  todavía cerrado). En MOUNT solo funcionan las vistas fijas (V$ y X$), que leen memoria y control file.
- Las cifras de "Total System Global Area" de `STARTUP NOMOUNT` coinciden con `v$sga` de la evidencia 08:
  Fixed Size 5 033 232 B (4,8 MB) / Variable Size 452 984 832 B (432 MB) / Database Buffers 1 140 850 688 B
  (1088 MB) / Redo Buffers 4 530 176 B (4,3 MB); total 1 603 398 928 B.

**Parte G — Interpretación del experimento de caché.**
- Toda lectura física termina en una lógica: el bloque se trae del disco al buffer cache y desde ahí se lee.
  En mi evidencia las lógicas NO son iguales: ronda 1 = 359, ronda 2 = 247. Las 112 lógicas de más de la
  ronda 1 son, muy probablemente, llamadas recursivas: tras el FLUSH, el primer análisis de la consulta lee
  bloques del diccionario (también expulsados de la caché). La ronda 2 (247) es el coste "puro" del full scan.
- 261 lecturas físicas para 244 bloques: 245 son la tabla (244 bloques + la cabecera del segmento, que el
  full scan también lee y que no cuenta en `BLOCKS`; `v$bh` muestra 245 bloques en caché) y las 16 restantes
  son, presumiblemente, bloques del diccionario de esas llamadas recursivas.
- Tasa de acierto de la ronda 2: 1 − 0/247 = 100 %. Ronda 1: 1 − 261/359 ≈ 27 %.

---

## Preguntas tipo examen (P1–P12)

| # | Respuesta | Justificación |
|---|-----------|---------------|
| P1 | **A, D** | Tras SHUTDOWN IMMEDIATE todos los datafiles comparten el SCN de checkpoint: la copia es consistente, no necesita redo y abre con un STARTUP normal. No exige ARCHIVELOG ni RMAN. |
| P2 | **B** | En Standard Edition no existe el MOVE DATAFILE online (opción de EE); el método offline (OFFLINE, copia con el SO, RENAME, ONLINE) solo deja sin servicio ese tablespace. |
| P3 | **A, C** | STARTUP_TIME es de la instancia y cambia en cada arranque; CREATED es de la base. El DBID no cambia al recrear el contenedor, una instancia monta una sola base y v$database ya responde en MOUNT. |
| P4 | **A, C** | En NOMOUNT ya hay parámetros en memoria (v$parameter) y es la etapa para CREATE CONTROLFILE. ARCHIVELOG y renombrar SYSTEM exigen MOUNT; dba_users exige OPEN. |
| P5 | **B** | ALTER DATABASE ARCHIVELOG cambia el control file y requiere la base montada pero no abierta. |
| P6 | **B** | Si la instancia arrancó con SPFILE, el SCOPE por defecto es BOTH: memoria y SPFILE. |
| P7 | **C** | PROCESSES no es modificable a nivel de PDB (ISPDB_MODIFIABLE=FALSE): desde una PDB da ORA-65040 antes de valorar si es estático. |
| P8 | **A, C** | Se arranca con un PFILE bueno y se regenera el SPFILE desde él. RESET en memoria no toca el SPFILE, RESETLOGS es de recuperación y ABORT no arregla nada. |
| P9 | **B** | Con MEMORY_TARGET=0 y SGA_TARGET>0 manda ASMM; un DB_CACHE_SIZE fijado actúa como mínimo del buffer cache. |
| P10 | **A, D** | La sort area y la memoria de sesión de un servidor dedicado están en la PGA; shared pool, log buffer y buffer cache están en la SGA. |
| P11 | **C** | El COMMIT vuelve cuando LGWR ha escrito el redo en los redo logs online; DBWn escribe los bloques más tarde. |
| P12 | **B, D** | PMON y SMON son obligatorios; ARC0 solo existe en ARCHIVELOG, CJQ0 es opcional (jobs) y RECO depende de las transacciones distribuidas. |

---

## Preguntas de comprobación

### Respaldo

**1. ¿Por qué la copia de la Parte B es consistente? ¿Qué pasaría con la base abierta?**
Porque `backup-estado.sh` hace `SHUTDOWN IMMEDIATE` antes de copiar: Oracle hace un checkpoint final, cierra
datafiles, control files y redo, y todos los datafiles quedan con el mismo SCN de checkpoint. Al restaurarla no
hay que aplicar redo. Con la base abierta, DBWn seguiría escribiendo mientras `tar` copia: cada archivo tendría un
SCN distinto (incluso bloques a medio escribir) y la copia sería inconsistente; solo sería recuperable en modo
ARCHIVELOG y con RMAN (o con `ALTER DATABASE BEGIN BACKUP`), aplicando redo archivado. Mi base está en
ARCHIVELOG (evidencia 00, línea `META|base|FREE|log_mode=ARCHIVELOG|scn=3163699`), pero `tar` sin
`BEGIN BACKUP` ni RMAN no garantiza bloques consistentes ni guarda el redo archivado necesario, así que sin la
parada la copia tampoco sería fiable.

**2. ¿Para qué sirven `manifiesto.txt` y `SHA256SUMS`? ¿Qué comprueba `restaurar-estado.sh` antes de tocar nada?**
`manifiesto.txt` describe la copia: etiqueta, fecha UTC, contenedor, volumen, imagen, commit de Git
(`b8b359f`), tipo de copia y número de archivos fuera del volumen. `SHA256SUMS` guarda la huella de cada
archivo de la copia. `restaurar-estado.sh` ejecuta primero `sha256sum --check`: si una sola huella no coincide
(copia dañada o modificada) se detiene sin tocar el volumen. Después pide escribir el nombre del volumen como
confirmación (salvo `--si`).

**3. Define RPO y RTO con los datos de tu copia.**
- RPO (cuántos datos puedo perder): todo lo hecho después de la copia `20261022T204729Z_lab3-final`, tomada el
  2026-10-22 a las 20:47 UTC (manifiesto: `fecha_utc=20261022T204912Z`) con SCN 3163699. Si restauro, vuelvo
  exactamente a ese punto.
- RTO (cuánto tardo en volver a dar servicio): el tiempo de `restaurar-estado.sh`. La copia ocupa 505 MB
  (volumen de 4780 MB comprimido) y el backup tardó unos 3 minutos (20:47:29 → ~20:50:20 UTC: parada + tar +
  arranque hasta READWRITE/READWRITE en 60 s); la restauración tarda un orden similar, unos 3 minutos
  (estimado, no medido).

### Diagnóstico y correcciones

**4. ¿Dónde creó Oracle los datafiles de V000 y por qué? ¿Qué parámetro lo habría evitado?**
En `$ORACLE_HOME/dbs` (`/opt/oracle/product/26ai/dbhomeFree/dbs/academia01.dbf`, etc.; evidencia 01,
bloque 4 y bloque B). V000 usó una ruta relativa (`DATAFILE 'academia01.dbf'`) y `db_create_file_dest` estaba
vacío (evidencia 01, bloque 5: "(vacío: sin OMF)"); Oracle resuelve la ruta relativa desde `$ORACLE_HOME/dbs`,
que está en la capa del contenedor y no en el volumen. Se habría evitado con `DB_CREATE_FILE_DEST` apuntando al
volumen (OMF) o escribiendo la ruta absoluta dentro de `/opt/oracle/oradata`.

**5. ¿Por qué `ALTER TABLESPACE ... RENAME DATAFILE` no basta para mover un archivo?**
Porque no mueve nada en disco: solo cambia la ruta que guarda el control file. El archivo tiene que estar ya
copiado en la ruta nueva (por eso `03-reubicar-datafiles.sh` hace `cp -p` antes) y el tablespace tiene que estar
OFFLINE. Al ponerlo ONLINE Oracle abre el archivo nuevo y valida la cabecera; solo entonces se borra el original.

**6. ¿Por qué no se edita V000 y se crea V003? ¿Por qué invalidar una contraseña es mejor que borrarla?**
V000 ya se aplicó: una migración aplicada es historia y el repositorio debe describir lo que se ejecutó
(migraciones solo hacia delante). Si la editara, otro entorno reconstruido desde el repo no coincidiría con el
real. Las contraseñas de V000 están en el historial de Git para siempre, aunque borre el archivo; por eso hay que
darlas por comprometidas y quitarles el valor: V003 convierte a los `ADMIN_*` en cuentas de solo esquema
(`NO AUTHENTICATION`), y la contraseña antigua da ORA-01017 (evidencia 04, `AUTHENTICATION_TYPE = NONE`;
comprobado con `sql admin_academia/...@//localhost:1521/FREEPDB1`).

**7. ¿Qué demuestra la prueba de persistencia y por qué se ejecuta después de reubicar?**
Que la base vive en el volumen y no en el contenedor: se hace `docker rm`, se recrea el contenedor con
`05-crear-contenedor.sh` v2 y los cinco tablespaces y los datos siguen ahí (evidencia 03, bloques ANTES y
DESPUÉS idénticos: 5 tablespaces ONLINE en `FREE/FREEPDB1` y 3/3/2/3/3 tablas por `ADMIN_*`; la prueba se hizo
antes de V002, así que el recuento de estudiantes es 0 en ambos bloques, y tras V002 da 20000 con la fila 101
ACTIVO). También demuestra que 8181 ya no se publica (`docker port`). Se ejecuta
después de reubicar porque, si los datafiles siguieran en `$ORACLE_HOME/dbs`, `docker rm` los borraría con la
capa del contenedor y se perderían los cinco entornos.

### Instancia y arranque

**8. Tres datos de la instancia y tres de la base de datos.**
- Instancia (evidencia 05): `INSTANCE_NAME` FREE, `HOST_NAME` 97a77b58859a (id del contenedor), `STARTUP_TIME`
  2026-10-22 20:57:39 (y el SID 60 de mi sesión como C##OPS_RO).
- Base de datos: `DBID` 1509902213, `CREATED` 2026-07-05, `LOG_MODE` ARCHIVELOG (y los 16 datafiles, 2 control
  files y 3 miembros de redo del bloque 5).
El HOST_NAME cambió tras recrear el contenedor (antes 82f7121218db, evidencia 01); el DBID no.

**9. ¿Qué lee Oracle en NOMOUNT, MOUNT y OPEN? Relación con ORA-01507 y ORA-01219.**
NOMOUNT lee el SPFILE (o PFILE), reserva la SGA y arranca los procesos de background. MOUNT lee los control
files (estructura: datafiles y redo). OPEN abre datafiles y redo online (y hace recuperación de instancia si hace
falta). ORA-01507 aparece en NOMOUNT al consultar `v$database` porque el control file no está abierto.
ORA-01219 aparece en MOUNT al consultar `dba_tables` porque el diccionario está en SYSTEM, un datafile que aún
no se ha abierto (evidencia 06).

**10. ¿Por qué FREEPDB1 se abre sola tras `ALTER DATABASE OPEN`? ¿Y si no lo hiciera?**
Porque tiene un estado guardado: `dba_pdb_saved_states` muestra `FREEPDB1 FREE OPEN` (evidencia 06), fruto de un
`ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE` que hizo la imagen. Si no se abriera, la vería en MOUNTED en
`v$pdbs` y las aplicaciones recibirían ORA-01109; la abriría con `ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;` y
después `ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE;` para que no se repita.

**11. Clasifica ORA-00800 y ORA-20013 del alert log.**
Ruido conocido, no alerta real. ORA-00800 [Set Priority Failed] [VKTM]/[LGWR] es un error "soft": Oracle intenta
subir la prioridad de esos procesos y el contenedor no tiene la capacidad CAP_SYS_NICE; la base abre igual
(evidencia 06-alert-log: aparece 4 veces, 2 por arranque, y tras el aviso llega `Completed: ALTER DATABASE OPEN`).
ORA-20013 (DBMS_QOPATCH, inventario de parches no legible dentro de la imagen) no aparece en mis últimas 400
líneas del alert log; si saliera, tampoco afectaría al servicio. En su lugar aparece una vez el trío
ORA-27301/27302/27303 (`error returned by chdir() is 2` en `spstp:9`) justo antes del primer arranque del
contenedor recreado: un `chdir` a un directorio que no existe en el contenedor nuevo; la base montó y abrió
igual. Se documentan como conocidos y se excluyen de las alertas; cualquier otro ORA- se investigaría.

### Parámetros

**12. Diferencia entre `v$parameter` y `v$spparameter` con `db_files`.**
`v$parameter` es el valor en memoria de la instancia; `v$spparameter` es lo escrito en el SPFILE. En la evidencia
07-parametros-cambios, tras `ALTER SYSTEM SET db_files = 300 SCOPE = SPFILE`: memoria 200, SPFILE 300 (cambio
pendiente hasta el próximo arranque). Tras `ALTER SYSTEM RESET db_files SCOPE = SPFILE`: memoria 200, SPFILE
"(no especificado)": la línea desapareció y en el próximo arranque tomará su valor por defecto.

**13. ¿Qué hace SCOPE=BOTH y cuál es el SCOPE por defecto con SPFILE?**
BOTH aplica el cambio en memoria ya y lo escribe en el SPFILE, así que sobrevive al reinicio (bloque 2: open_cursors
500 / 500 con el comentario "Lab4: prueba SCOPE=BOTH"). Si la instancia arrancó con SPFILE, BOTH es el valor por defecto; si arrancó con
PFILE, el defecto es MEMORY.

**14. ¿Por qué PROCESSES rechaza el cambio en memoria aunque v$parameter lo marque IMMEDIATE?**
Porque PROCESSES dimensiona estructuras de la SGA que se reservan al arrancar la instancia; no se pueden
redimensionar en caliente, así que el cambio en memoria da ORA-02095 (evidencia 07, bloque 4). En la práctica y en
el examen es estático: se cambia con SCOPE=SPFILE y reinicio. La metadata orienta, pero la prueba decide.

**15. ¿Para qué sirve versionar el PFILE? ¿Qué es "configuration drift"?**
El PFILE (`evidencia/config/initFREE_lab4.ora`, 32 líneas; la versión FROM MEMORY tiene 122) es una foto legible de la configuración. Versionado
en Git, un `git diff` entre dos fotos muestra cualquier cambio de parámetros. Configuration drift es que la
configuración real se vaya alejando de la documentada por cambios que nadie registró; comparar el PFILE de hoy con
el anterior lo detecta. Además sirve de copia de seguridad: si un SPFILE mal editado impide arrancar,
`STARTUP PFILE=...` y `CREATE SPFILE FROM PFILE` lo reparan.

### Memoria y procesos

**16. ¿Qué modelo de gestión de memoria usa tu instancia?**
ASMM (Automatic Shared Memory Management). Evidencia 08, bloque 1: `memory_target = 0` y `memory_size = 0`
(no hay AMM), `sga_target = 1536M` (Oracle reparte la SGA entre buffer cache, shared pool, large pool y java
pool) y `pga_aggregate_target = 512M` (la PGA se gestiona aparte). `db_cache_size = 0` no significa sin caché,
sino sin mínimo fijado.

**17. Explica las cifras del experimento de caché.**
Ronda 1 (caché fría tras FLUSH): 359 lecturas lógicas y 261 físicas: cada bloque de la tabla se trajo del disco.
Ronda 2: 247 lógicas y 0 físicas: todos los bloques ya estaban en el buffer cache. Cada físico acaba leído también
desde la caché; las 112 lógicas y 16 físicas extra de la ronda 1 son, muy probablemente, llamadas recursivas al
diccionario tras el FLUSH. 245 = 244 bloques + la cabecera del segmento. Tasa de acierto ronda 2: 1 − 0/247 =
100 %. `v$bh` confirma 245 bloques de ACA_ESTUDIANTES en caché (evidencia
`script/20261022T210935Z_08-experimento-cache.script.log`).

**18. ¿Por qué no se suma el RSS de los procesos?**
Porque el RSS de cada proceso incluye las páginas de la SGA compartida que ha tocado, y esa misma memoria
aparece repetida en todos los procesos. Sumar el RSS de los 58 procesos de background daría varios GB en un contenedor que usa
2,04 GiB (`docker stats`, evidencia 05). La memoria real se mide con `v$sga` + `v$pgastat` o `docker stats`.

**19. Relaciona el SPID de LGWR con el PID de /proc. ¿Por qué docker top muestra otro número?**
`v$process.spid` de LGWR = 1762 (evidencia 09 spool) y `09-procesos-so.sh 1762` muestra en `/proc` del
contenedor el PID 1762 = `db_lgwr_FREE`: es el mismo proceso. `docker top` muestra 20238 porque enseña el PID
del anfitrión: el contenedor tiene su propio espacio de nombres de PID (PID namespace), y el mismo proceso tiene un
número dentro y otro fuera.

**20. ¿Qué hace PMON y qué hace SMON? Un ejemplo de cada uno.**
PMON limpia procesos de usuario caídos: deshace su transacción con el undo y libera bloqueos y recursos. Ejemplo:
el portátil de un usuario se apaga a mitad de un UPDATE; PMON detecta el proceso huérfano, hace rollback y la
otra sesión deja de esperar el bloqueo. SMON hace la recuperación de instancia al arrancar y limpia segmentos
temporales. Ejemplo: tras un SHUTDOWN ABORT o un corte de luz, en el siguiente STARTUP SMON aplica el redo y
deshace lo no confirmado (alert log: "Crash Recovery").

### Seguridad y trabajo profesional

**21. ¿Por qué C##OPS_RO y no SYSTEM para observar? ¿Qué no puede hacer?**
Por mínimo privilegio: para mirar no hace falta poder romper. SYSTEM puede crear, borrar y modificar objetos y
usuarios; un error de consulta o un script equivocado con SYSTEM puede dañar la base. C##OPS_RO solo tiene
CREATE SESSION, SET CONTAINER y SELECT_CATALOG_ROLE (con CONTAINER_DATA=ALL para ver todas las PDB). No puede
hacer DML ni DDL, ni ALTER SYSTEM, ni STARTUP/SHUTDOWN, ni leer los datos de las tablas de negocio.

**22. ¿Qué dos vías de exposición de contraseñas corrige este laboratorio?**
1. Contraseñas literales en el repositorio: V000 dejó las de los cinco `ADMIN_*` en Git → V003 las invalida
   (schema-only accounts).
2. La contraseña de SYS en la línea de comandos: el 08 del Lab 3 pasaba `sys/<contraseña>@...` a `docker exec`
   (visible con `ps` y en los eventos de Docker) → el 08 v2 usa `/ as sysdba` (autenticación del SO). Además, el
   05 v2 ya no pasa `ORACLE_PWD` al recrear el contenedor (no aparece en `docker inspect`), y la contraseña de
   C##OPS_RO viaja por stdin desde `config/.env`, nunca como argumento.
