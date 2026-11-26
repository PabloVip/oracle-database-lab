# Laboratorio 7 · Respuestas · E065

<!--
CÓMO SE RELLENA
- Copia este archivo como docs/bitacora/lab7-respuestas.md y pon tu código en el título.
- Responde con TUS números: cada respuesta cita el archivo de evidencia de donde sale (docs/bitacora/lab7/evidencia/...).
  Una cifra sin evidencia no puntúa. Las cifras del PPTX son de referencia: las tuyas serán parecidas, no iguales.
- 3 a 6 líneas por pregunta. No pegues salidas enteras: el archivo de evidencia ya las tiene.
- No borres los títulos: scripts/lab7/09-verificacion-final.sh comprueba que están todos.
-->

## Parte B · C01 · Más sesiones no es más rendimiento
1. ¿Cuántas llamadas por segundo y qué p95 tuviste con 1, 2 y 8 sesiones? ¿Qué número de sesiones recomiendas y por qué?

Con 1 sesión: 7,2 llamadas/s y p95 de 142,8 ms. Con 8 sesiones: 12,4 llamadas/s y p95 de 1084,2 ms (`evidencia/casos/20261126T182822Z_C01_entender.txt`). Con el pool de 2 sesiones: 14,1 llamadas/s y p95 de 159 ms (`evidencia/casos/20261126T183316Z_C01_validar.txt`).
Multiplicar por 8 las sesiones solo multiplica el throughput por 1,7, mientras que el p95 se multiplica por 7,6. Con 2 sesiones sale un 14 % más de trabajo que con 8 y el p95 es 6,8 veces menor.
Recomiendo 2 sesiones, tantas como CPU_COUNT = 2. Cada llamada gasta sobre todo CPU, así que solo pueden avanzar 2 a la vez. A partir de ahí, más sesiones no dan más trabajo: solo añaden cola y espera.

2. ¿Qué evento domina con 8 sesiones y qué significa en Oracle Free?

Domina `resmgr:cpu quantum`, con el 74,4 % de las muestras de ASH. El 25,6 % restante es ON CPU (`evidencia/casos/20261126T183112Z_C01_diagnosticar.txt`).
Es una espera de la clase Scheduler: la sesión está lista para usar CPU, pero el Resource Manager no la deja porque Oracle Free limita la CPU de la instancia (CPU_COUNT = 2).
Las 82 muestras en CPU en unos 41 s dan unas 2 sesiones en CPU de media (las 2 CPU que hay). Las otras 238 muestras son sesiones esperando turno, y por eso el AAS es 7,8.
Con 1 sesión, en cambio, el 100 % de las muestras estaba en CPU y no había esperas. No es un problema de disco ni de bloqueos: es una cola de CPU.

3. Comprueba la ley de Little (N = X · R) con tus tres medidas.

Uso la R media en segundos (`evidencia/casos/20261126T183345Z_C01_observar.txt`):
- 1 sesión: 7,2 × 0,1365 = 0,98 ≈ 1
- 2 sesiones: 14,1 × 0,1412 = 1,99 ≈ 2
- 8 sesiones: 12,4 × 0,6293 = 7,80 ≈ 8 (coincide con el AAS de 7,8)

En los tres casos el N calculado coincide con las sesiones reales. Con 8 sesiones X ya no puede crecer porque está limitado por las 2 CPU, así que la única forma de que se cumpla la ley es que suba R: 8 / 12,4 ≈ 0,65 s.

## Parte C · C03 · Literales y análisis completos
1. Análisis completos y tiempo con literales, con variables de enlace y con CURSOR_SHARING = FORCE (tus cifras).

- **Literales:** 5000 fichas en 2400 ms (2390 ms de CPU) y 5059 hard parses. 2190 ms se fueron en analizar, el 91 % del tiempo (`evidencia/casos/20261126T183526Z_C03_diagnosticar.txt`). En la shared pool quedaban 716 cursores de una sola ejecución que ocupaban 18534 KB (`evidencia/casos/20261126T183453Z_C03_entender.txt`).
- **Variable de enlace:** 120 ms y 28 hard parses (`evidencia/casos/20261126T183536Z_C03_solucionar.txt`), con 1 cursor frente a 756 (`evidencia/casos/20261126T183537Z_C03_validar.txt`).
- **FORCE:** 170 ms y 28 hard parses, con un solo SQL_ID con `:"SYS_B_0"` y 5000 ejecuciones (`evidencia/casos/20261126T183701Z_C03_observar.txt`).

Con binds va 20 veces más rápido: lo que se ahorra es el hard parse de cada valor (comprobar la sentencia, optimizarla, generar el plan y reservar memoria en la shared pool), que es puro consumo de CPU.

2. ¿Por qué FORCE es un puente y no la solución? ¿Qué ve el DBA en V$SQL que lo delata (FORCE_MATCHING_SIGNATURE)?

FORCE arregla el síntoma desde la base de datos, pero la aplicación sigue mandando literales. Oracle tiene que sustituirlos en cada llamada, y por eso tarda 170 ms frente a los 120 ms de los binds reales.
Además, allí donde se activa (en mi caso solo en la sesión) cambia todos los literales, incluidos los que el optimizador necesita para estimar bien, como un valor con histograma. Así se comparte un único plan entre valores con selectividades muy distintas.
Por eso es un puente hasta que se corrija el código.
En V$SQL lo delata FORCE_MATCHING_SIGNATURE: la firma 14573098645096361820 aparecía en 711 SQL_ID distintos con 711 ejecuciones, una cada uno (`evidencia/casos/20261126T183526Z_C03_diagnosticar.txt`). Eso significa que es la misma sentencia repetida con literales concatenados.

## Parte C · C04 · El informe que se desborda a TEMP
1. Bloques de TEMP, tipo de pasada y tiempo del informe antes y después. ¿Qué hacía el disparador de logon?

**Antes:** el informe de 1 000 000 de filas tardaba 1660 ms y escribía y leía 5456 bloques de TEMP, unos 42,6 MB (`evidencia/casos/20261126T184204Z_C04_entender.txt`). En V$SQL_WORKAREA se ve que la ordenación necesitaba 48,0 MB, solo usó 1016 KB e hizo 1 PASS (one-pass) con política MANUAL (`evidencia/casos/20261126T184205Z_C04_diagnosticar.txt`).
**El disparador:** T6.C04_LEGADO (AFTER LOGON en T6_INF) ponía `workarea_size_policy = MANUAL` y `sort_area_size = 1048576` (1 MB). Así la sesión ignoraba la PGA automática, que le habría dado hasta 100 MB.
**Después:** tras `DROP TRIGGER t6.c04_legado`, el informe completo tarda 600 ms, no usa TEMP y queda en OPTIMAL. El TOP 100 tarda 90 ms (`evidencia/casos/20261126T184234Z_C04_solucionar.txt`).

2. ¿Por qué el TOP 100 cabe en memoria y el informe completo no?

Ordenar es una operación bloqueante: para devolver la primera fila del informe completo hay que guardar y ordenar el millón de filas, y eso necesita 48 MB.
El TOP 100 usa SORT ORDER BY STOPKEY. También recorre el millón de filas, pero solo guarda las 100 mejores que lleva hasta ese momento y descarta el resto sobre la marcha. La memoria depende de las 100 filas que guarda y no de las que lee, así que usa 0,0 MB y queda en OPTIMAL (`evidencia/casos/20261126T184235Z_C04_observar.txt`).
La idea es reducir antes de ordenar.

## Parte D · C07 · EXPLAIN PLAN frente al plan real
1. Copia el predicado que delata el problema en el plan real y explica de dónde sale.

`2 - filter(TO_NUMBER("CODIGO_POSTAL")=:B1)` con `Peeked bind :B1 (NUMBER) = 30038`, en el plan 2571571058 con TABLE ACCESS FULL PEDIDO (`evidencia/casos/20261126T184350Z_C07_diagnosticar.txt`).
CODIGO_POSTAL es VARCHAR2 y la V1 manda un NUMBER. Al comparar texto con número, Oracle convierte el texto a número, es decir, aplica TO_NUMBER a la columna de cada fila.
El índice IX_T6_PED_CP guarda CODIGO_POSTAL tal cual, así que con la función aplicada no se puede usar para buscar: aparece `filter` en vez de `access` y se recorre la tabla entera.
La cura es mandar el tipo correcto (V2 con VARCHAR2), y no crear un índice sobre TO_NUMBER, que taparía el error de la aplicación y fallaría con códigos no numéricos.

2. Lecturas y p95 de V1 y V2. ¿Por qué EXPLAIN PLAN no lo vio?

V1: 5227 lecturas por búsqueda y p95 de 56,8 ms. V2: 95 lecturas y p95 de 0,5 ms. Son 55 veces menos lecturas (`evidencia/casos/20261126T184433Z_C07_validar.txt`).
EXPLAIN PLAN no ejecuta la sentencia ni mira el tipo de la variable, así que trató :CP como texto. Por eso mostraba INDEX RANGE SCAN con `access("CODIGO_POSTAL"=:CP)`, coste 94 y plan 2982358210 (`evidencia/casos/20261126T184349Z_C07_entender.txt`), que en realidad es el plan de la V2.
DISPLAY_CURSOR enseña el plan que se ejecutó de verdad, con el bind NUMBER y el TO_NUMBER.

## Parte D · C08 · E-Rows frente a A-Rows
1. Estimación y filas reales antes y después del grupo de columnas. ¿En qué línea del plan se separan por primera vez?

**Antes** (plan 2405883318, `evidencia/casos/20261126T184459Z_C08_diagnosticar.txt`):
- Id 4 INDEX RANGE SCAN IX_T6_CLI_CIUDAD: E-Rows 50 frente a A-Rows 56. Acierta.
- Id 3 TABLE ACCESS CLIENTE con el filtro de COMUNIDAD: E-Rows 3 frente a A-Rows 56. Es la primera línea donde se separan.
- El error sube hasta Id 2 (30 frente a 599).

**Después** de crear el grupo (CIUDAD, COMUNIDAD) y recoger: Id 3 estima 50 (reales 56) e Id 2 estima 500 (reales 599), con el mismo plan (`evidencia/casos/20261126T184528Z_C08_solucionar.txt`).

2. ¿Por qué el optimizador multiplicaba mal las dos selectividades?

Supone que las columnas son independientes: 100 000 × 1/2000 × 1/18 ≈ 3 (`evidencia/casos/20261126T184458Z_C08_entender.txt`).
Pero cada ciudad pertenece a una sola comunidad, así que el filtro de comunidad no quita ninguna fila, y multiplicar por 1/18 divide la estimación entre 18 sin motivo.
El grupo de columnas crea la columna oculta SYS_STUBJHRJ63BYYQ61EBQAQU2TM_, que tiene NUM_DISTINCT 2000, igual que CIUDAD sola, porque la comunidad no aporta combinaciones nuevas (`evidencia/casos/20261126T184529Z_C08_observar.txt`). Con eso estima 100 000 / 2000 = 50.

## Parte E · C12 · Estadísticas obsoletas
1. Filas según las estadísticas y reales; método de unión y lecturas antes y después.

Según las estadísticas, CARRITO tenía 100 filas, pero había 200 100 tras cargar 200 000 sin recoger (`evidencia/casos/20261126T184600Z_C12_entender.txt`).

**Antes:** NESTED LOOPS (plan 3942147839) con 200K accesos por índice a PK_T6_PEDIDO y 212 376 lecturas (`evidencia/casos/20261126T184601Z_C12_diagnosticar.txt`). Con 100 filas los bucles serían baratos, pero con 200K son 200K búsquedas sueltas.
**Después** de `GATHER_TABLE_STATS('T6','CARRITO', no_invalidate => FALSE)`: HASH JOIN (plan 582079594), E-Rows igual a A-Rows (200K) y 5907 lecturas, 36 veces menos (`evidencia/casos/20261126T184644Z_C12_validar.txt`).

2. ¿Por qué la tarea automática no lo habría arreglado a tiempo? ¿Quién debe recoger y cuándo?

La tarea automática está activa y habría visto la tabla obsoleta (STALE_PERCENT 10), pero solo trabaja en la ventana de mantenimiento, que empieza a las 22:00 (`evidencia/casos/20261126T184645Z_C12_observar.txt`).
Si la carga es a las 3:00, el informe iría mal durante 19 horas.
Debe recoger el propio proceso de carga, justo al terminar, con `no_invalidate => FALSE` para que los cursores se vuelvan a optimizar enseguida.

## Parte E · C13 · El ciclo de estadísticas con red
1. Describe el ciclo que seguiste (pendientes, probar, publicar, restaurar, bloquear) con la vista que comprueba cada paso.

El UPDATE pasó 135 277 pedidos a 'E'. Sin histograma, el optimizador estimaba 250 000 (1/4) y había 185 277 (`evidencia/casos/20261126T184707Z_C13_entender.txt`).

1. **Pendientes:** `PUBLISH=FALSE` y GATHER con ESTADO SIZE 254. Se comprueba en DBA_TAB_PENDING_STATS (pendientes de las 18:47:34).
2. **Probar:** `ALTER SESSION SET optimizer_use_pending_statistics=TRUE`, solo en mi sesión. El plan pasa a estimar 185 277.
3. **Publicar:** PUBLISH_PENDING_STATS y `PUBLISH=TRUE`. En DBA_TAB_STATISTICS sale STALE = NO, el histograma es FREQUENCY y quedan 0 pendientes (`evidencia/casos/20261126T184738Z_C13_validar.txt`).
4. **Restaurar:** en DBA_TAB_STATS_HISTORY están las versiones (retención de 31 días). `RESTORE_TABLE_STATS(..., SYSTIMESTAMP - 60 s)` devuelve ESTADO a HISTOGRAM NONE.
5. **Bloquear:** LOCK_TABLE_STATS. En DBA_TAB_STATISTICS sale STATTYPE_LOCKED = ALL (`evidencia/casos/20261126T184743Z_C13_observar.txt`).

2. ¿Qué error obtuviste al recoger sobre estadísticas bloqueadas y cómo se recoge si de verdad hace falta?

`ORA-20005: object statistics are locked (stattype = ALL)` al lanzar GATHER sobre la tabla bloqueada (`evidencia/casos/20261126T184743Z_C13_observar.txt`).
Si hace falta recoger, hay dos opciones:
- `GATHER_TABLE_STATS(..., force => TRUE)`: ignora el bloqueo y lo mantiene.
- UNLOCK_TABLE_STATS, recoger y volver a bloquear si el bloqueo era a propósito.

Hay que tener en cuenta que, mientras siga bloqueada, la tarea automática se salta la tabla.

## Parte E · C14 · El índice invisible
1. Lecturas por apertura del panel antes y después. ¿Cómo probaste el índice sin que lo viera nadie más?

**Antes:** 5266 lecturas y 14,2 ms por apertura del panel, con un FULL que estimaba 22 374 filas cuando eran 2056 (`evidencia/casos/20261126T184831Z_C14_diagnosticar.txt`).
**Después:** 118 lecturas y 0,26 ms (`evidencia/casos/20261126T184904Z_C14_validar.txt`).
**Cómo lo probé:** creé `ix_t6_c14_pend (estado, canal, fecha_pedido)` como INVISIBLE ONLINE. ONLINE deja seguir haciendo DML mientras se crea, con solo bloqueos breves al principio y al final. Las demás sesiones seguían con el FULL (plan 2571571058). Solo en mi sesión puse `optimizer_use_invisible_indexes=TRUE`: plan 2691093566 con INDEX RANGE SCAN y 116 buffers. Después lo hice VISIBLE (`evidencia/casos/20261126T184904Z_C14_solucionar.txt`).
Las igualdades van primero en el índice y el rango de fecha al final, para que el rango sea un trozo seguido del índice.

2. Redo con el índice INVISIBLE y VISIBLE: ¿qué demuestra?

Al cambiar el canal de 20 000 pedidos, el redo fue de 9007 KB sin el índice, 10 403 KB con el índice INVISIBLE y 10 402 KB con el índice VISIBLE (`evidencia/casos/20261126T184907Z_C14_observar.txt`).
Demuestra que un índice invisible se mantiene en cada escritura igual que uno visible: cuesta unos 1396 KB más (+15,5 %). Ser invisible solo cambia que el optimizador lo use o no.
Si al hacerlo visible algo empeora, la vuelta atrás inmediata es `ALTER INDEX ... INVISIBLE`. Borrarlo es la decisión final, cuando se confirma que nadie lo necesita, porque mientras exista sigue costando redo.

## Parte F · C17 · INC-604 con AWR, ASH y ADDM
1. SLI y SLO; p95 antes y después; instantáneas AWR que usaste.

El SLI es el p95 de la búsqueda por código postal y el SLO es p95 < 20 ms.
- **Antes (V1):** p95 de 78,6 ms con 3971 llamadas, así que incumple (`evidencia/casos/20261126T185201Z_C17_entender.txt`).
- **Después (V2), con la misma carga de 3 sesiones durante 120 s:** p95 de 0,63 ms y 33 299 búsquedas, así que cumple (`evidencia/casos/20261126T185503Z_C17_validar.txt`).

Instantáneas AWR: 15 → 16 para la V1 (18:49 a 18:51) y 17 → 18 para la V2 (18:52 a 18:55) (`evidencia/herramientas/20261126T185759Z_t6-awr.txt`).

2. ¿Qué dijeron ASH, AWR y ADDM, y qué no podían decirte? ¿Cuál fue el ÚNICO cambio?

Todo esto está en `evidencia/casos/20261126T185203Z_C17_diagnosticar.txt`:
- **ASH:** la sentencia 0dbx7196jdajy estaba casi siempre ON CPU (236 muestras).
- **AWR (15 → 16):** esa sentencia gastó 279,4 s en 3948 ejecuciones, con 5213 gets por ejecución.
- **ADDM:** DB time de 323 s y AAS de 2,63. Atribuye el 88,89 % a esa SQL (Top SQL) y un 22,19 % a CPU throttling.

Las tres herramientas dicen qué sentencia gasta, pero no por qué. El porqué era el parámetro NUMBER de BUSCAR_CP_V1, que metía un TO_NUMBER en la columna. Eso solo se ve en el plan real con predicados y en el código.
El único cambio fue que la web llama a `buscar_cp_v2(TO_CHAR(:cp))`, la versión con parámetro VARCHAR2 (`evidencia/casos/20261126T185258Z_C17_solucionar.txt`).

## Parte F · C18 · SQL Plan Management
1. PLAN_HASH_VALUE y lecturas del lunes, del martes y con la línea base.

Es el mismo SQL_ID, 8hn59jfgw00y7 (`evidencia/casos/20261126T185600Z_C18_entender.txt`):
- **Lunes:** plan 1767728868 (INDEX RANGE SCAN IX_T6_PED_ESTADO), 197 lecturas por ejecución, 8,6 ms.
- **Martes:** plan 2571571058 (FULL PEDIDO), 5227 lecturas, 33,2 ms (`evidencia/casos/20261126T185558Z_C18_provocar.txt`).
- **Con la línea base cargada desde AWR** (SQL_PLAN_0a27u7nan424ba00b9863, ACCEPTED YES): vuelve al plan 1767728868 con 193 lecturas (`evidencia/casos/20261126T185802Z_C18_solucionar.txt`).

Entre el lunes y el martes nadie cambió el código. Lo que cambió fue la recogida nocturna con SIZE 1, que borró el histograma de ESTADO.

2. ¿Qué hizo la evolución con el plan nuevo y por qué? ¿Qué queda pendiente para que no vuelva a pasar?

El plan nuevo (SQL_PLAN_0a27u7nan424b95a18d93, AUTO-CAPTURE) se guardó como no aceptado. La evolución (TASK_65) lo comparó con el plan de la línea base y dio "failed the benefit criterion", así que sigue con ACCEPTED NO (`evidencia/casos/20261126T185806Z_C18_observar.txt`).
No lo acepta porque el FULL lee mucho más que el plan del índice.
Queda pendiente arreglar la causa: ESTADO sigue sin histograma (`evidencia/casos/20261126T185804Z_C18_validar.txt`) y la preferencia METHOD_OPT SIZE 1 lo volvería a borrar. Hay que cambiar la preferencia para que ESTADO tenga SIZE 254 y recoger con RB-2. SPM solo da tiempo para hacerlo.

## Parte G · Incidente 1 · INC-605
- **Síntoma (con números):** el informe de cestas abandonadas va mal. Según las estadísticas, CESTA tiene 100 filas, pero se han insertado 215 000 (215 100 reales), con STALE YES y LOCKED ALL (`evidencia/herramientas/20261126T190001Z_t6-estad.txt`).
- **Playbook y pasos seguidos (herramientas y vistas):** PB-3 ("ayer iba bien"). Con `t6 estad CESTA` revisé DBA_TAB_STATISTICS (NUM_ROWS, STALE, LOCKED), DBA_TAB_MODIFICATIONS (215 000 inserts), el historial de estadísticas y las preferencias (PUBLISH TRUE, METHOD_OPT SIZE AUTO).
- **Causa raíz:** las estadísticas estaban bloqueadas, así que la tarea automática se salta la tabla aunque esté obsoleta, y el optimizador sigue creyendo que tiene 100 filas.
- **Arreglo aplicado (órdenes exactas) y por qué ese:**
  1. `EXEC DBMS_STATS.UNLOCK_TABLE_STATS('T6','CESTA')`
  2. RB-2:
     - `SET_TABLE_PREFS('T6','CESTA','PUBLISH','FALSE')`
     - `GATHER_TABLE_STATS('T6','CESTA')`
     - probar con `optimizer_use_pending_statistics=TRUE`
     - `PUBLISH_PENDING_STATS('T6','CESTA')`
     - `PUBLISH` vuelve a `TRUE`

  UNLOCK y no `force => TRUE`: con force recogería una vez, pero el bloqueo seguiría y tras la próxima carga volvería a pasar lo mismo.
- **Verificación (archivo de evidencia con todo OK):** `evidencia/incidentes/20261126T190223Z_INC-605_verificar.txt`: 215 100 filas frente a 215 100 reales, HASH JOIN y bloqueo NO. En `evidencia/herramientas/20261126T190222Z_t6-estad.txt` sale STALE NO.
- **Prevención (qué evitaría que se repita):** no bloquear las estadísticas de una tabla de trabajo que cambia de tamaño. Si alguna vez se bloquean a propósito, el proceso que carga debe recoger al terminar.

## Parte G · Incidente 2 · INC-608
- **Síntoma (con números):** el informe por `estado = 'P'` estima 250 000 filas y hay 20 000. ESTADO no tiene histograma (NONE) y METHOD_OPT es `FOR ALL COLUMNS SIZE 1` (`evidencia/incidentes/20261126T190310Z_INC-608_verificar.txt`, 3 FALLO).
- **Playbook y pasos seguidos (herramientas y vistas):** PB-3. Con `t6 estad PEDIDO` (`evidencia/herramientas/20261126T190312Z_t6-estad.txt`) vi en DBA_TAB_COL_STATISTICS que ESTADO tiene 4 valores distintos sin histograma. En las preferencias de la tabla (DBA_TAB_STAT_PREFS) estaba METHOD_OPT SIZE 1.
- **Causa raíz:** la preferencia METHOD_OPT SIZE 1 borra el histograma en cada recogida, así que el optimizador reparte por igual entre los 4 estados (1/4 de 1 000 000).
- **Arreglo aplicado (órdenes exactas) y por qué ese:**
  1. `EXEC DBMS_STATS.SET_TABLE_PREFS('T6','PEDIDO','METHOD_OPT','FOR ALL COLUMNS SIZE 1 FOR COLUMNS ESTADO SIZE 254')`
  2. RB-2:
     - `PUBLISH` a `FALSE`
     - `GATHER_TABLE_STATS('T6','PEDIDO')`
     - probar con `optimizer_use_pending_statistics=TRUE`
     - `PUBLISH_PENDING_STATS`
     - `PUBLISH` a `TRUE`

  Hay que cambiar la preferencia porque, si solo recojo hoy, la próxima recogida usa otra vez SIZE 1 y vuelve a borrar el histograma.
- **Verificación (archivo de evidencia con todo OK):** `evidencia/incidentes/20261126T190416Z_INC-608_verificar.txt`: estima 20 000 frente a 20 000 reales, ESTADO con histograma FREQUENCY y la preferencia ya incluye ESTADO SIZE 254.
- **Prevención (qué evitaría que se repita):** dejar la preferencia a nivel de tabla para que la recogida nocturna conserve el histograma, y revisar las preferencias con `t6 estad` después de cambiarlas.

## Parte G · Incidente 3 · INC-611
- **Síntoma (con números):** el listado de Ciudad1745 / COM12 estima 3 clientes y hay 52, y no existe la extensión (CIUDAD, COMUNIDAD) (`evidencia/incidentes/20261126T190448Z_INC-611_verificar.txt`).
- **Playbook y pasos seguidos (herramientas y vistas):** PB-2. Con `t6 estad CLIENTE` (`evidencia/herramientas/20261126T190450Z_t6-estad.txt`) vi CIUDAD con 2000 valores distintos y COMUNIDAD con 18, sin histogramas y sin extensiones.
- **Causa raíz:** las columnas están correlacionadas (cada ciudad pertenece a una sola comunidad), pero el optimizador las trata como independientes: 100 000 × 1/2000 × 1/18 ≈ 3.
- **Arreglo aplicado (órdenes exactas) y por qué ese:**
  1. `SELECT DBMS_STATS.CREATE_EXTENDED_STATS('T6','CLIENTE','(CIUDAD,COMUNIDAD)') FROM dual;`
  2. Recoger CLIENTE con RB-2:
     - `PUBLISH` a `FALSE`
     - `GATHER_TABLE_STATS('T6','CLIENTE')`
     - probar en sesión
     - `PUBLISH_PENDING_STATS`
     - `PUBLISH` a `TRUE`

  El grupo de columnas le dice al optimizador cuántas combinaciones reales hay (2000).
- **Verificación (archivo de evidencia con todo OK):** `evidencia/incidentes/20261126T190533Z_INC-611_verificar.txt`: estima 50 frente a 52 reales, y la extensión SYS_STUBJHRJ63BYYQ61EBQAQU2TM_ tiene estadísticas con NUM_DISTINCT 2000 (`evidencia/herramientas/20261126T190532Z_t6-estad.txt`). Sale 50 y no 52 porque es la media (100 000 / 2000) y el grupo no tiene histograma.
- **Prevención (qué evitaría que se repita):** la extensión se queda en la tabla y las próximas recogidas la mantienen. Conviene buscar otras columnas correlacionadas que se filtren juntas y crearles su grupo.

## Parte H · Reflexión
1. De todo el laboratorio, ¿qué cambio dio más mejora por menos riesgo? Justifícalo con tus números.

El cambio de C17/C07: llamar a la V2 con el parámetro VARCHAR2 (`buscar_cp_v2(TO_CHAR(:cp))`).
Mejora: el p95 pasó de 78,6 a 0,63 ms (unas 125 veces), los gets por ejecución de 5213 a 100, y con la misma carga se hicieron 33 299 búsquedas en vez de 3971 (`evidencia/casos/20261126T185503Z_C17_validar.txt`).
El riesgo es muy bajo: es un solo cambio, no crea objetos ni toca estadísticas o parámetros, no añade coste a las escrituras y se deshace volviendo a la V1.
En comparación, el índice de C14 mejoró 45 veces las lecturas (5266 a 118), pero añade un 15,5 % de redo a cada escritura. FORCE en C03 cambia todos los literales donde se activa.

2. Un caso no evaluable (sin ★) que hayas hecho y qué aprendiste de él (opcional, cuenta para la certificación).

No he hecho casos sin ★ en este laboratorio.
