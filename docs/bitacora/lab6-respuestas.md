# Lab 6 — Oracle DBA Operations · Respuestas

> Issue: #14 · Rama: `chore/14-administracion-operativa`

## Partes A-C · Rol operativo, parámetros y estados

### 1. ¿Cuántos errores ORA- tenía tu alert log en 24 h en la Parte B y a qué se debían? ¿Por qué ese número no es una alarma por sí solo?

En el apartado 4 de `01-turno` me salieron 6 errores ORA- en 24 h. Mirando el detalle en `01-errores-ora` (apartado 5) vi que eran todos ORA-00800 "Set Priority Failed", de dos en dos (uno de LGWR y otro de VKTM), a las 09:05, 09:38 y 09:44. Cada pareja es un arranque de la base: el docker start de por la mañana, el reinicio de la copia de la A.5 y cuando volví a arrancar después de quedarme sin batería. Salen porque al arrancar Oracle intenta subir la prioridad de esos procesos y dentro de Docker no le dejan, pero no afecta a nada.

No es una alarma porque el 6 solo no dice nada si no sabes de dónde viene. En mi caso lo normal son 2 errores de estos por arranque. Me preocuparía si saliera un error distinto o si subieran sin haber reiniciado la base.

### 2. ¿A qué hora empieza y cuánto dura la ventana de mantenimiento de un miércoles en tu base? ¿Qué tareas automáticas corren en ella?

En `01-automatizacion.spool`, apartado 2, la WEDNESDAY_WINDOW tiene byhour=22 y HORAS 4, así que empieza a las 22:00 y dura 4 horas (hasta las 02:00). En el apartado 1 están las tres tareas automáticas:
- auto optimizer stats collection: actualiza las estadísticas para que el optimizador elija bien los planes.
- auto space advisor: mira qué segmentos tienen espacio que se podría recuperar.
- sql tuning advisor: revisa las consultas que más cargan y propone mejoras.

En el apartado 5 me salió también un job de ORDS_METADATA, que es de cuando instalé ORDS en el Lab 3 (en el PDF no sale).

### 3. Explica con tu salida de la Parte C la diferencia entre lo que mostraban V$SPPARAMETER y V$PARAMETER tras el SCOPE = SPFILE. ¿Qué habría pasado en el siguiente reinicio sin el RESET?

En el apartado 5 de `02-parametros`, después de poner db_files a 250 con SCOPE = SPFILE, V$SPPARAMETER ponía 250 y V$PARAMETER seguía en 200. V$SPPARAMETER enseña lo que hay guardado en el SPFILE y V$PARAMETER lo que está usando la instancia ahora mismo. Con SCOPE = SPFILE el cambio solo se guarda en el archivo y no se aplica hasta reiniciar. Si no hubiera hecho el RESET, en el siguiente reinicio la base habría arrancado con db_files = 250.

### 4. ¿Por qué RESET fue la vuelta atrás correcta para db_files y no lo habría sido para processes? Cita la línea de tu PFILE que lo demuestra.

RESET no vuelve al valor de antes: lo que hace es quitar el parámetro del SPFILE para que se use el valor por defecto. En mi PFILE (`config/02-init_desde_spfile.ora`) no hay ninguna línea de db_files, o sea que nadie lo había cambiado y estaba en su valor por defecto (200). Por eso, con el RESET, se quedaba igual que antes.

Con processes no valdría porque sí estaba puesto a mano, en la línea 31 del PFILE: `*.processes=200`. Si le hago RESET se borra esa línea y al arrancar cogería el valor por defecto de Oracle, que no es 200. Para volver atrás habría que hacer SET otra vez a 200.

Otra cosa que vi: el PFILE sacado del SPFILE tiene 34 líneas y el de memoria 125 (en el PDF eran 41 y 131), porque en el SPFILE solo están los parámetros que se han puesto a mano.

### 5. Tras el reinicio sin estado guardado, ¿qué error obtuvo C##OPS_RO y por qué la instancia decía «Database opened»?

En el apartado 4 de `02-estados-pdb`, después de reiniciar sin estado guardado, C##OPS_RO recibió ORA-01109: database not open, porque FREEPDB1 se había quedado en MOUNTED. La instancia ponía "Database opened" porque eso se refiere al CDB, no a las PDB. Una PDB solo se abre sola al arrancar si tiene el estado guardado con SAVE STATE; si no, se queda montada. Al final del script se abre otra vez, se guarda el estado y FREEPDB1 queda en READ WRITE.

Una cosa rara que me salió: validar-arranque contó 8 ORA-00800 "desde el último arranque", cuando tendrían que ser 2. Pasa porque mi SQLcl va en hora de Madrid (+01:00) y la hora de arranque está en UTC, así que el filtro empieza una hora antes y pilla 4 arranques (09:38, 09:44 y los dos reinicios del script). Los 2 ORA-65019 los provoca el script a propósito.

## Partes D-E · Servicios, sesiones y diccionario

### 6. ¿Qué SID, SPID y evento tenía la sesión de la aplicación en tu ejecución? ¿Qué te dicen MODULE, ACTION y CLIENT_IDENTIFIER que no te diría USERNAME?

En el apartado 3 de `03-sesiones`, la sesión de la aplicación tenía SID 227 (serial 59459), SPID 3819 y el evento PL/SQL lock timer, que sale porque estaba dentro del DBMS_SESSION.SLEEP. El SPID es el número del proceso en el sistema operativo.

MODULE era matriculas, ACTION cierre-periodo y CLIENT_IDENTIFIER ana.garcia@ucam. Con USERNAME solo vería APP_ACADEMIA, que es la misma cuenta para todas las sesiones de la aplicación. Con los otros tres sé de qué parte de la aplicación es la sesión, qué estaba haciendo y para qué usuario, así que si hay un problema sé a quién afecta.

### 7. Tras CANCEL SQL, ¿cuántas transacciones abiertas tenía la aplicación? ¿Y tras KILL SESSION? ¿En qué estado quedó la fila 101 y por qué?

Después del CANCEL SQL (apartado 4) la aplicación seguía teniendo 1 transacción abierta (USED_UREC 1) y seguía conectada: le salió ORA-01013, pero dijo "sigo viva". El CANCEL solo para la sentencia que se está ejecutando; la transacción sigue ahí.

Después del KILL SESSION (apartado 5) quedaron 0 sesiones de la aplicación vivas, así que ninguna transacción. La aplicación recibió ORA-00028 y ORA-03114, y el KILL dio ORA-00031 (sesión marcada para matar). La fila 101 quedó en ACTIVO porque el UPDATE a EGRESADO no estaba confirmado y, al matar la sesión, Oracle hace rollback. Matar una sesión no guarda lo que estaba haciendo: lo deshace.

### 8. ¿Qué valor tiene common_user_prefix en tu imagen? ¿Qué implica para el nombre de una cuenta común?

En `03-cuenta-app`, common_user_prefix vale C## (en el PDF salía vacío). Eso quiere decir que los usuarios comunes, los que se crean en la raíz y están en todos los contenedores, tienen que empezar por C##, como C##OPS_RO. Y al revés: un usuario local de la PDB, como APP_ACADEMIA, no puede empezar por C##.

### 9. Completa con tus cifras la tabla de las tres miradas (ALL_TABLES, DBA_USERS, CDB_USERS, V$DATAFILE) y explica una diferencia.

Mis cifras de `04-tres-miradas`:

| Vista | C##OPS_RO en la raíz | C##OPS_RO en FREEPDB1 | APP_ACADEMIA |
|---|---|---|---|
| ALL_TABLES de ADMIN_ACADEMIA | 0 | 0 | 1 |
| DBA_USERS | 37 | 47 | ORA-00942 |
| CDB_USERS | CON_ID 1 → 37, CON_ID 3 → 47 | solo CON_ID 3 → 47 | ORA-00942 |
| V$DATAFILE | 17 | 10 | ORA-00942 |

A APP_ACADEMIA le funcionan las vistas ALL_ (ALL_TABLES da 1 y ALL_USERS 47) porque esas vistas solo enseñan lo que el usuario puede usar, y la aplicación tiene permiso sobre ACA_ESTUDIANTES. En cambio, las DBA_, CDB_ y V$ le dan ORA-00942 porque para verlas hace falta un privilegio de catálogo como SELECT_CATALOG_ROLE, que C##OPS_RO sí tiene y APP_ACADEMIA no.

### 10. Con tu salida de 04-deltas: ¿cuántas lecturas lógicas por recorrido y cuánto DB time costó la carga? ¿Qué indica la relación entre DB time y DB CPU?

En el apartado 4 de `04-deltas` salen 54079 lecturas lógicas en total, unas 5408 por recorrido. La carga costó 0,27 s de DB time y 0,25 s de DB CPU (0,26 s de reloj). DB time es el tiempo total en la base (CPU más esperas), así que, si es casi igual que DB CPU, casi todo fue CPU y no se esperó a casi nada, porque los bloques ya estaban en memoria. Si DB time fuera mucho más grande que DB CPU, esa diferencia serían esperas y habría que ver cuáles.

## Partes F-G · Espacio y acceso

### 11. Da las tres medidas (asignado, libre, máximo) de TBS_ACADEMIA_HIST antes de la carga y explica cuál usarías para alertar.

En el apartado 2 de `05-almacenamiento`, antes de la carga TBS_ACADEMIA_HIST tenía 10 MB asignados, 3,9 MB libres y un máximo de 40 MB, un 15,16 % sobre el máximo (776 de 5120 bloques).

Para alertar usaría el % sobre el máximo. Los 3,9 MB libres parecen poco, pero solo cuentan lo que ya está asignado, y el tablespace puede crecer hasta 40 MB. Lo que importa de verdad es cuánto llevas usado respecto al máximo.

### 12. ¿Quién insertó y quién «pagó» en el ORA-01950? ¿Por qué ampliar el tablespace no habría resuelto el ORA-01536?

En el ORA-01950 (apartado 4) el que insertó fue SYS, porque el script entra como SYSDBA, pero el mensaje habla de CARGA_HIST, que es la dueña de la tabla. La cuota la paga el dueño de la tabla y no el que inserta, y CARGA_HIST no tenía cuota en ese tablespace.

En el ORA-01536 (apartado 5) el tablespace tenía sitio (3,9 MB libres y podía llegar a 40); lo que se acabó fue la cuota: BYTES = MAX_BYTES = 2097152, o sea, 2 MB usados de 2 MB. Ampliar el tablespace no habría servido de nada porque el límite era del usuario: había que subirle la cuota.

### 13. ¿Cuánto tiempo estuvo suspendida la carga reanudable y qué evidencia de ello dejó Oracle en el alert log?

En `05-resumable` la aplicación vio INICIO 10:36:12 y FIN 10:36:26, así que la carga duró unos 14 segundos y casi todo ese tiempo estuvo suspendida. En el apartado 2 se ve la sesión en SUSPENDED, con SUSPEND_TIME 11/23/26 10:36:11, esperando en el evento "statement suspended, wait error to be cleared". En vez de fallar por la cuota, la sentencia se quedó esperando y siguió sola cuando tuvo cuota.

La prueba en el alert log son dos líneas: "was suspended due to", que demuestra que Oracle suspendió la sentencia, y "was resumed", que demuestra que la reanudó. En la evidencia salen sin hora, por eso la duración la saco de INICIO y FIN.

### 14. Antes y después del SHRINK: filas, bloques y cuota consumida. ¿Por qué un DELETE no devolvió el espacio?

Mis cifras de `05-hwm-shrink`:

| Momento | Filas | Bloques | MB |
|---|---|---|---|
| Antes del DELETE | 20000 | 2944 | 23 |
| Tras el DELETE | 2000 | 2944 | 23 |
| Tras SHRINK SPACE | 2000 | 304 | 2,4 |

La cuota usada bajó de 23 MB a 2,4 MB. Con el DELETE se borraron 18000 filas, pero los bloques seguían siendo 2944. El DELETE solo vacía las filas: los bloques siguen siendo de la tabla, por debajo de la marca de agua alta (HWM), y siguen contando en la cuota. Ese espacio solo lo puede volver a usar la misma tabla. El SHRINK SPACE junta las filas, baja la HWM y libera los bloques que sobran. Para eso hace falta activar ROW MOVEMENT, porque al mover las filas cambia su ROWID.

### 15. ¿Qué valores tenía tu perfil DEFAULT? Justifica dos de los límites de PRF_PERSONAS para una persona de secretaría.

En el apartado 1 de `06-gobierno-acceso`, mi perfil DEFAULT tenía FAILED_LOGIN_ATTEMPTS 10, PASSWORD_LIFE_TIME 180 días, PASSWORD_LOCK_TIME 1 día, INACTIVE_ACCOUNT_TIME 365 y ninguna PASSWORD_VERIFY_FUNCTION. En el PDF salían en UNLIMITED.

De PRF_PERSONAS justifico estos dos para alguien de secretaría:
- 3 intentos y bloqueo de 1 minuto: una persona se sabe su contraseña, así que fallar 3 veces seguidas ya es raro. El minuto de bloqueo frena a alguien que intente adivinarla, y si es la propia persona la que se ha equivocado, solo tiene que esperar un minuto sin llamar a nadie. Lo vi con Ana en `06-probar-acceso`: tres ORA-01017, luego ORA-28000 y la cuenta en LOCKED(TIMED).
- 90 días de inactividad: en secretaría la gente cambia de puesto o se va. Si alguien no entra en 90 días, la cuenta se le bloquea sola y no se queda una cuenta olvidada con acceso a datos de alumnos.

### 16. ¿Por qué Ana pudo leer ACA_MATRICULAS si nadie se la concedió por nombre? ¿Qué error obtuvo al cambiar el nombre de un alumno?

Ana pudo leer ACA_MATRICULAS (60000 matrículas, apartado 1 de `06-probar-acceso`) porque tiene el rol ROL_SECRETARIA_ACADEMIA, que dentro lleva ROL_LECTURA_ACADEMIA, y ese rol tiene SELECT ANY TABLE ON SCHEMA sobre ADMIN_ACADEMIA (apartado 6 de `06-gobierno-acceso`). Es un privilegio de esquema, así que le deja leer todas las tablas del esquema, incluso las que se creen más adelante, sin tener que darlas una a una.

Cuando intentó cambiar el nombre de un alumno le salió ORA-41900 ("Falta el privilegio UPDATE"). No es porque solo tenga lectura: ROL_SECRETARIA_ACADEMIA tiene UPDATE solo sobre la columna ESTADO de ACA_ESTUDIANTES (apartado 6 de `06-gobierno-acceso`), que es un privilegio de columna. Por eso pudo cambiar el estado (en `06-probar-acceso` le salió "1 fila actualizadas"), pero no el nombre. Al intentar borrar también falló, porque DELETE no lo tiene de ninguna forma.

En `06-cascada` (apartados 3 y 5) se ve qué pasa con lo que U6_A había repartido a U6_B cuando el DBA le revoca sus privilegios a U6_A. CREATE SESSION es un privilegio de sistema que U6_A tenía WITH ADMIN OPTION (U6_A: YES, U6_B: NO) y se lo dio a U6_B; al revocárselo a U6_A, U6_B lo conserva, porque la revocación de privilegios de sistema no se propaga. En cambio, el SELECT sobre ACA_ASIGNATURAS es un privilegio de objeto que U6_A recibió WITH GRANT OPTION: antes había 2 privilegios de objeto entre los dos y después 0, porque el de U6_B cae en cascada.

## Partes H-I · Objetos, diagnóstico y guardia

### 17. ¿Qué objetos se invalidaron en cada uno de los tres cambios de columna y por qué no se invalidó nada con la columna nueva?

En `07-objetos` (apartados 2 a 4):
- Con la columna nueva, telefono: no se invalidó nada.
- Al cambiar email_institucional: se invalidó V_CONTACTO_LAB6.
- Al cambiar nombres: se invalidaron V_ACTIVOS_LAB6 y F_TOTAL_ACTIVOS_LAB6.

Oracle controla las dependencias por columna: solo invalida los objetos que usan la columna que cambia. Como la columna nueva (telefono) no la usaba ningún objeto, no se invalidó nada. Al cambiar email_institucional cayó V_CONTACTO_LAB6, que usa esa columna. Al cambiar nombres cayó V_ACTIVOS_LAB6, que sí la usa, y F_TOTAL_ACTIVOS_LAB6 cayó en cascada aunque no use esa columna, porque depende de la vista y no de la tabla. Esa cadena es lo que enseña DBA_DEPENDENCIES (apartado 4 de `07-objetos`): F_TOTAL_ACTIVOS_LAB6 → V_ACTIVOS_LAB6 → ACA_EST_LAB6. Luego, la función se recompiló sola al llamarla (devolvió ACTIVOS 17600), pero V_CONTACTO_LAB6 siguió INVALID hasta que se lanzó UTL_RECOMP (apartados 5 y 6). Al final el índice pasó de UNUSABLE a VALID y quedó INVALIDOS_NEGOCIO = 0.

### 18. Según tus advisors, ¿mejoraría el DB time duplicar la SGA? ¿Y por debajo de qué tamaño la PGA tendría sobreasignaciones?

En el apartado 5 de `07-memoria`, con la SGA al doble (3072 MB) el ESTD_DB_TIME_FACTOR sale 1, o sea, el DB time sería el mismo. Duplicar la SGA no mejoraría nada: con la que tiene ya le llega.

Para la PGA, el advisor da 2 sobreasignaciones con 128 MB y con 256 MB, y 0 desde 384 MB. Así que por debajo de 384 MB tendría sobreasignaciones (en el PDF ya salían con 384). Una sobreasignación es cuando a Oracle no le llega la memoria que tiene como objetivo y tiene que usar más.

### 19. ¿Cuántas lecturas lógicas necesitó la consulta de la aplicación según la traza (o tkprof)? ¿Qué línea de la traza lo dice?

En el apartado 5 de `07-adr-trazas`, la consulta de la aplicación hizo 247 lecturas lógicas. Lo dice la línea FETCH de la traza, en `cr=247` (lecturas consistentes, en memoria), y en tkprof sale lo mismo en la columna query (247). En mi imagen sí venía adrci; en la del PDF no.

### 20. Para cada incidente de la guardia: evidencia clave, intervención y validación (una línea por cada uno).

- INC-601 (bloqueo de fila): en `08-diagnostico-inc1` se veía a ANA_GARCIA (SID 45) esperando en enq: TX - row lock contention por el SID 175 de APP_ACADEMIA (matriculas / cierre-periodo), que tenía un UPDATE sin confirmar → maté la sesión que bloqueaba, no la de Ana: `ALTER SYSTEM KILL SESSION '175,65254' IMMEDIATE` → la fila 101 quedó en ACTIVO (`08-intervencion-inc1`), en `08-validacion-inc1` ya no esperaba nadie y en ASH se ve a Ana esperando hasta las 10:47:23, justo cuando hice el KILL.
- INC-602 (ORA-12514): `08-turno-inc2` decía que la base estaba bien (OPEN y FREEPDB1 en READ WRITE) y en `08-diagnostico-inc2` (apartado 6) el servicio academia_app estaba con ARRANCADO = NO, por eso el listener no lo conocía → arranqué solo ese servicio con `DBMS_SERVICE.START_SERVICE('academia_app')` y guardé el estado con SAVE STATE, sin reiniciar nada → en `08-validacion-inc2-listener` academia_app sale READY y en `08-validacion-inc2-app` la aplicación conecta y lee 17600 estudiantes.
- INC-603 (ORA-28000): `08-sintoma-inc3` daba ORA-28000 y en `08-diagnostico-inc3` (apartado 7) APP_ACADEMIA estaba en LOCKED (bloqueada a mano, a las 10:50) y no en LOCKED(TIMED); con el perfil DEFAULT harían falta 10 fallos, así que la bloqueó el script de bajas → `ALTER USER app_academia ACCOUNT UNLOCK`, sin tocar la contraseña → en `08-validacion-inc3-app` la aplicación vuelve a leer y en `08-validacion-inc3` el apartado 7 sale vacío.

## Simulacro de examen 1Z0-182 (letra y Parte donde lo comprobé)

- S1: B — Parte B (`01-automatizacion`, umbrales de espacio de MMON) y Parte F (umbral 80/95 de TBS_ACADEMIA_HIST)
- S2: C — Parte C (`02-parametros`, parámetros DEFERRED: solo para las sesiones nuevas)
- S3: B — Parte C (`02-pfile-so`, el PFILE sacado de memoria tiene 125 líneas y el del SPFILE 34)
- S4: B y C — Parte C (`02-estados-pdb`, OPEN READ WRITE con la PDB ya abierta da ORA-65019)
- S5: C — Parte C (`02-estados-pdb`, SAVE STATE)
- S6: B — Parte C (`02-estados-pdb`, ORA-01035 con la PDB en modo restringido)
- S7: A — Parte D (`03-servicio`) y Parte I (INC-602, START_SERVICE)
- S8: B — Parte D (`03-sesiones`, SPID 3819 de la sesión 227)
- S9: C — Parte D (`03-sesiones`, 1 transacción abierta después del CANCEL)
- S10: C — Parte D (`03-sesiones`, SYSOPER es PUBLIC y da ORA-00942)
- S11: B — Parte E (`04-deltas`, apartado 1: V$CON_SYSMETRIC, tasas del último minuto de esta PDB)
- S12: A y C — Parte E (`04-deltas`, DB time 0,27 s y DB CPU 0,25 s)
- S13: B — Parte F (`05-almacenamiento`, ORA-01950 de CARGA_HIST aunque insertaba SYS)
- S14: A y C — Parte F (`05-almacenamiento`, ORA-30041 en el temporal)
- S15: A y C — Parte F (`05-resumable`, SUSPENDED unos 14 s)
- S16: B — Parte F (`05-hwm-shrink`, ENABLE ROW MOVEMENT antes del SHRINK)
- S17: B — Parte G (`06-probar-acceso`, Ana en LOCKED(TIMED) después de 3 ORA-01017)
- S18: B — Parte G (`06-cascada`, U6_B conserva CREATE SESSION)
- S19: A y B — Parte H (`07-objetos`, el MOVE deja el índice UNUSABLE)
- S20: B — Parte H (`07-adr-trazas`)
- S21: C — Parte H (`07-adr-trazas`, ADR)
- S22: C — Parte I (INC-601, primero localizar el SID 175 que bloqueaba)
