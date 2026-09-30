# Lab 3 — Respuestas de comprobación

> Entorno real de este laboratorio: **CachyOS (Linux nativo, x86_64)** con Docker Engine nativo y bash.
> No uso WSL 2, así que las respuestas 21 y 22 explican el motivo del curso y cómo aplica a mi caso.

## Docker

**1. ¿Qué diferencia hay entre una imagen y un contenedor?**
Una imagen es una plantilla de solo lectura (`hello-world:latest`, `alpine:3.20`); un contenedor es una
instancia en ejecución creada a partir de ella, con su propio sistema de archivos temporal y su propio
proceso. En G2, `docker run hello-world` creó un contenedor con nombre aleatorio a partir de la imagen,
que siguió existiendo en `docker images` después de que el contenedor terminara. En G4, desde la misma
imagen `alpine:3.20` creé el contenedor `prueba`: dentro tenía su propio hostname (su ID) y al salir quedó
en `Exited`, mientras que la imagen seguía intacta para crear otros.

**2. En G5 `nota.txt` desapareció y en G6 no. ¿Por qué?**
En G5 el archivo se escribió en la capa de escritura del propio contenedor `prueba`; al hacer `docker rm`
esa capa se borró, y `prueba2` arrancó desde la imagen limpia. En G6 el archivo se escribió en `/datos`,
que era el volumen con nombre `datos-prueba`: el volumen vive fuera del ciclo de vida del contenedor, así
que aunque el primer contenedor se borrara (`--rm`), el segundo lo montó de nuevo y encontró el dato.

**3. `docker ps` vs `docker ps -a`; ¿qué significa `Exited (0)`?**
`docker ps` solo lista contenedores en marcha; `docker ps -a` lista todos, incluidos los detenidos.
`Exited (0)` significa que el proceso principal terminó y lo hizo correctamente (código de salida 0);
un código distinto de 0 indica que terminó con error.

**4. En `-p 8181:8181`, ¿qué número es de mi equipo y cuál del contenedor? ¿Y `-p 80:8080` con nginx?**
El formato es `anfitrión:contenedor`: el primero es el puerto de mi equipo y el segundo el del contenedor.
Con `-p 80:8080` publicaría mi puerto 80 hacia el 8080 del contenedor, pero nginx escucha en el 80, así
que la página no cargaría (y además el 80 del anfitrión podría requerir privilegios o estar ocupado).

**5. ¿Por qué Oracle se queda en marcha y hello-world termina sola?**
Un contenedor vive lo que vive su proceso principal. `hello-world` imprime su mensaje y su proceso acaba,
por eso queda en `Exited (0)`. El proceso principal de `oralab-26ai` es el motor de base de datos (y el
script que lo supervisa), que no termina, así que el contenedor sigue `Up`.

**6. ¿Qué es el digest y por qué lo registramos si usamos `:latest`?**
El digest (`sha256:...`) es la huella criptográfica exacta del contenido de la imagen. La etiqueta
`:latest` es un puntero móvil que mañana puede apuntar a otra versión; el digest no cambia. Registrarlo
en la evidencia 04 deja constancia de qué versión exacta de Oracle instalé, aunque `:latest` avance.

**7. ¿Qué comando borraría realmente los datos de Oracle? ¿Por qué `docker rm oralab-26ai` no lo hace?**
`docker volume rm oralab-26ai-data` (o un `docker system prune -a --volumes` con el contenedor
detenido/borrado). `docker rm oralab-26ai` solo elimina el contenedor; los datafiles del sistema están en el volumen
con nombre montado en `/opt/oracle/oradata`, que sobrevive y se puede volver a montar con el script 05.
Hallazgo de mi laboratorio: los 5 datafiles de los tablespaces `TBS_*` creados por V000 usan nombres
relativos y quedaron en `.../dbhomeFree/dbs/` dentro del contenedor, no en el volumen. Con `docker stop/start`
no pasa nada, pero con `docker rm` + recrear se perderían. Pendiente: migración V002 con
`ALTER DATABASE MOVE DATAFILE` o documentarlo en el PR.

## Git, organización y evidencia

**8. ¿Por qué dentro de `oracle-database-lab` con Issue, branch y PR?**
Porque preparar un entorno es un cambio de infraestructura: así queda reproducible (los scripts permiten
rehacerlo), verificable (el reviewer ve scripts y salidas reales, no un "me funciona") y trazable (el
Issue explica el porqué, cada commit un paso y el PR la revisión). En una carpeta aparte perdería el
historial, la protección de `main` y acabaría con un *snowflake server*.

**9. `source 00-config.sh` vs `bash 00-config.sh`.**
`bash` ejecuta el archivo en una shell hija que desaparece al terminar, y con ella las variables y la
función `ts`. `source` lo ejecuta en mi shell actual, así que `CONT_NAME`, `EVID`, `ts`, etc. quedan
disponibles para los comandos siguientes. Por eso las constantes se cargan siempre con `source`.

**10. Partes de `20260915T091230Z_02-docker.script.log`.**
`20260915T091230Z`: fecha y hora en UTC en ISO 8601 compacto (15/09/2026 09:12:30, la `Z` indica UTC);
`02`: número del paso/Parte que la produjo (Parte F, script `02-verificar-docker.sh`); `docker`:
descripción en kebab-case; `.script.log`: tipo de evidencia, salida de terminal (frente a `.spool.log`
para sesiones SQL o `.png` para capturas).

**11. ¿Para qué sirve `.gitattributes`?**
Fija en el repositorio que `.sh`, `.sql` y `.md` se guardan con finales de línea LF para todo el equipo,
sea cual sea su sistema. Evita que un script con CRLF (Windows) falle en Linux con errores como
`$'\r': command not found` y que los diffs se llenen de cambios invisibles.

**12. ¿Por qué *Create a merge commit* y no *Squash and merge*?**
Porque cada commit de esta branch corresponde a una Parte y tiene valor por sí mismo como registro de
cuándo y cómo se verificó cada herramienta. El squash los fundiría en uno y se perdería ese historial
paso a paso; el merge commit lo conserva en `main`.

## Seguridad

**13. Las cuatro capas de la Parte D y qué pasa si me salto la primera.**
1) Añadir `config/.env` (y `backups/`) a `.gitignore` **antes** de crear el archivo; 2) versionar una
plantilla sin secretos, `config/.env.example`; 3) crear el `config/.env` real local y comprobar con
`git check-ignore -v` que Git lo ignora; 4) cargar los secretos con `set -a; source config/.env; set +a`
y usar siempre `"$ORACLE_PWD"`, sin teclear la contraseña. Si me salto la primera, `config/.env`
aparecería en `git status` y un `git add .` lo metería en un commit: la contraseña quedaría para siempre
en el historial.

**14. ¿Por qué no escribir la contraseña en el `docker run` aunque el script no se suba?**
Porque todo lo que se teclea queda en el historial de la shell (`~/.bash_history`) en texto plano, y
también puede acabar en una grabación de `script` o en una evidencia. Con `"$ORACLE_PWD"` solo queda el
nombre de la variable; el valor sale de `config/.env`.

**15. Si la contraseña está en un commit ya publicado, ¿basta con borrarla?**
No: sigue en el historial y cualquiera puede recuperarla. Hay que darla por comprometida y rotarla
(cambiarla en `config/.env` y recrear/alterar las cuentas afectadas), avisar al docente para limpiar la
branch/historial y revisar con `git log -p | grep -c -F "$ORACLE_PWD"` que ya no aparece.

## Oracle y herramientas

**16. ¿Por qué no `SPOOL` ni `@archivo.sql` con el sqlplus del contenedor?**
Ese sqlplus corre dentro del contenedor: `SPOOL` escribiría el archivo en el sistema de archivos del
contenedor, no en mi repositorio, y `@archivo.sql` buscaría el script dentro del contenedor, donde no
existe (SP2-0310). En su lugar, enviamos el `.sql` del repositorio por la entrada estándar
(`docker exec -i ... < archivo.sql`) y capturamos la salida en mi equipo con `tee`.

**17. ¿Qué hace `WHENEVER SQLERROR EXIT SQL.SQLCODE`?**
Hace que SQL*Plus termine en cuanto una sentencia falla, devolviendo el código de error. Así el script
08 lo detecta (`if ! ...`) y no ejecuta V001 sobre un V000 a medias. Sin esa línea, sqlplus seguiría
con las sentencias siguientes sobre un estado inconsistente y terminaría con código 0, ocultando el fallo.

**18. ¿Qué es una migración y por qué no se editan V000 y V001 tras aplicarlas?**
Es un script SQL versionado y numerado que lleva la base de un estado al siguiente, en orden. Si se
edita una ya aplicada, las bases donde se ejecutó la versión antigua y las nuevas dejarían de coincidir
sin que nadie lo sepa. Para corregir algo se crea una migración nueva (V002...). En mi caso, las
migraciones provisionales nunca llegaron a `main`, por eso las sustituí por las oficiales antes del PR y
limpié los objetos que habían creado.

**19. ¿Por qué `FREEPDB1` y no `FREE` ni un SID en SQL Developer?**
`FREEPDB1` es el servicio de la PDB, la base de datos de trabajo donde están los 5 esquemas de negocio.
`FREE` (o el SID) conecta al contenedor raíz `CDB$ROOT`, donde no hay que crear objetos de aplicación;
además, elegir SID en vez de Service name provoca errores como ORA-12505.

**20. SQLcl frente a SQL*Plus.**
SQLcl es moderno: autocompletado, historial, formato automático (`SET SQLFORMAT ansiconsole`),
conexiones guardadas (`CONNECT -save`), integración con Liquibase y se instala en mi equipo (su `SPOOL`
escribe en mi repositorio). SQL*Plus está en cualquier servidor Oracle: cuando solo tienes una terminal
en el servidor es lo que hay. Un DBA necesita las dos.

## Entorno de trabajo

**21. ¿Por qué pasar de Git Bash a Ubuntu en WSL 2?**
Porque Oracle, Docker y los servidores de producción son Linux, y Git Bash es solo una emulación:
convierte rutas tipo `/opt/...` a rutas de Windows y rompe argumentos de Docker, necesita `winpty` para
`docker run -it` ("not a TTY"), no trae `free`, `ss`, `htop` y las herramientas Java dan problemas al
pedir contraseñas. En Linux real esos problemas desaparecen. En mi caso trabajo directamente en Linux
nativo (CachyOS), con el mismo resultado: mismos comandos y rutas que un servidor.

**22. ¿Por qué clonar en `~/oracle-database-lab` y no en `/mnt/c/...`? ¿Por qué bash y no zsh?**
En WSL, `/mnt/c` es el disco de Windows: cada operación cruza entre dos sistemas de archivos (Git y
Docker van mucho más lentos), no se conservan los permisos de ejecución y vuelven los problemas de
finales de línea. En mi CachyOS el repositorio vive en mi `$HOME` Linux, que es lo equivalente.
Los scripts van en bash porque es la shell que existe en todos los servidores; zsh es cómoda para uso
interactivo pero tiene diferencias sutiles (arrays, globbing, expansión) y normalmente no está instalada
en un servidor.
