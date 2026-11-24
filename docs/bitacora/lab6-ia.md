He leído la política de uso de IA de la asignatura.

# Declaración de uso de IA · Lab 6 · E065

<!--
CÓMO SE RELLENA (léelo y borra este comentario si quieres; el script de evaluación lo ignora)
- La PRIMERA línea es obligatoria y no se toca: «He leído la política de uso de IA de la asignatura.»
- Copia este archivo como docs/bitacora/lab6-ia.md (junto a lab6-respuestas.md) y pon tu código en el título.
  Cada laboratorio tiene el suyo: en el Lab 7 será docs/bitacora/lab7-ia.md.
  «No he usado IA.».
- Si la has usado: borra la línea «No he usado IA.» y escribe UNA entrada por cada uso, con los 7 campos.
  Un campo vacío es una entrada incompleta (D3: −0,5 por entrada).
- Preguntar a la IA como tutor o corregir la ortografía de un texto propio está permitido: decláralo también.
  Si no copiaste código, escribe «no aplica» en «Código recibido» y en «Evidencia de ejecución» (no cuentan como vacíos).
  Los demás campos son siempre obligatorios.
- Una entrada con TODOS los campos vacíos (la de ejemplo sin tocar) no cuenta: se ignora.
- El código copiado de una IA puntúa si lo EJECUTAS en tu contenedor, lo EXPLICAS con tus palabras,
  dices para qué lo usaste y adjuntas aquí el código y el prompt LITERAL.
-->

## Entrada 1
- **Herramienta:** Claude
- **Prompt (literal, copiado tal cual):**
```text
Corrigeme el siguiente error que te muestro por pantalla, ya que llevo 15m y no se porque me da error.
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):** no lo guardé y no recuerdo si llegué a pegar algún comando suyo
- **Dónde lo usé (parte, script o pregunta):** Parte A, en la app de Claude, antes de empezar con Claude Code
- **Propósito (para qué lo necesitaba):** arreglar un error que me salía en la terminal y que llevaba un rato sin saber resolver
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** le enseñé el error que me salía por pantalla y me explicó por qué pasaba y cómo arreglarlo, y con eso pude seguir con la práctica. No guardé la conversación y no recuerdo cuál era el error exacto.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** no la guardé

## Entrada 2
- **Herramienta:** Claude
- **Prompt (literal, copiado tal cual):**
```text
Dime que poner en la terminal para poder abrir otra vez una nueva ventana y continuar por el paso que me había quedado.
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):** no lo guardé y no recuerdo los comandos exactos que me dio
- **Dónde lo usé (parte, script o pregunta):** Parte A, en la app de Claude, antes de empezar con Claude Code
- **Propósito (para qué lo necesitaba):** volver a abrir la terminal y seguir la práctica por el paso en el que me había quedado
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** le pregunté qué tenía que poner en una terminal nueva para seguir donde lo había dejado, y me dijo qué comandos ejecutar para volver a la carpeta del laboratorio y cargar otra vez la configuración. No guardé la conversación y no recuerdo los comandos exactos.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** no la guardé

## Entrada 3
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
okay pues dame los comandos y yo los pego en la terminal
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cd ~/oracle-database-lab
docker start oralab-26ai
bash scripts/ops/esperar-healthy.sh
git switch main
git pull
git status
git tag -l "lab*-final"
bash scripts/lab5/16-verificacion-final.sh | tail -3
cd ~/Descargas/"LAB6 CALIDAD"
unzip -q P2_Lab6_v1.3_Estudiante.zip -d kit
cp -r kit/repo-kit/. ~/oracle-database-lab/
cd ~/oracle-database-lab
source scripts/deployment/env/00-config.sh
mkdir -p "$EVID_LAB6"/{script,spool,config}
chmod +x scripts/lab6/*.sh scripts/ops/*.sh
ls scripts/lab6
grep -q APP_ACADEMIA_PWD config/.env || printf 'APP_ACADEMIA_PWD=""\nANA_GARCIA_PWD=""\n' >> config/.env
grep -q '^ESTUDIANTE=' config/.env || echo 'ESTUDIANTE=""' >> config/.env
nano config/.env
git check-ignore config/.env && echo "config/.env está fuera de Git"
bash scripts/ops/alumno.sh
source config/.env
cp docs/plantillas/IA.md docs/bitacora/lab6-ia.md
sed -i "s/E0NN/$ESTUDIANTE/" docs/bitacora/lab6-ia.md
ls -d .claude CLAUDE.md AGENTS.md .cursor 2>/dev/null && echo "ATENCIÓN: archivos de agente" || echo "Sin archivos de agente"
nano docs/bitacora/lab6-ia.md
bash scripts/ops/backup-estado.sh lab6-inicio \
  | tee "$EVID_LAB6/script/$(ts)_00-backup-lab6-inicio.script.log"
git switch -c chore/N-administracion-operativa
git add scripts/ config/.env.example docs/plantillas/ docs/bitacora/lab6-ia.md login.sql .gitignore "$EVID_LAB6/script/"*_00-*
git status
git commit -m "chore(ops): add Lab 6 kit, AI declaration and back up starting point

Refs #N"
```
- **Dónde lo usé (parte, script o pregunta):** Parte A (A.1 a A.6)
- **Propósito (para qué lo necesitaba):** preparar el punto de partida del Lab 6: arrancar la base, comprobar que el Lab 5 estaba bien, copiar el kit, poner mi código y las contraseñas, hacer la copia de seguridad y crear la rama con el primer commit.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** `docker start` y `esperar-healthy.sh` arrancan el contenedor y esperan a que el CDB y la PDB estén en READ WRITE. Los `git switch main`, `pull`, `status` y `tag -l` comprueban que parto de main limpio y con las etiquetas de los labs anteriores, y `16-verificacion-final.sh` que el Lab 5 da TODO OK. `unzip` y `cp -r` descomprimen el kit y copian sus scripts al repositorio. `source 00-config.sh` carga las variables (como EVID_LAB6), `mkdir` crea las carpetas de evidencias script, spool y config, y `chmod` da permiso de ejecución a los scripts. Los `grep ... >> config/.env` añaden las variables de las contraseñas y de mi código si no estaban, y con `nano` las relleno. `git check-ignore` comprueba que config/.env no se sube a Git, y `alumno.sh` genera login.sql para que cada evidencia lleve mi cabecera con E065. `cp IA.md` y `sed` crean esta declaración con mi código en el título, y `ls -d .claude ...` comprueba que no hay archivos de agentes. `backup-estado.sh lab6-inicio` para la base, hace una copia en frío del punto de partida (evidencia 00) y la vuelve a arrancar. Por último, `git switch -c`, `git add` y `git commit` crean la rama del Lab 6 y hacen el commit de la Parte A.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** docs/bitacora/lab6/evidencia/script/20261123T092756Z_00-backup-lab6-inicio.script.log

## Entrada 4
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
Cual es mi codigo de la lista de clase para el paso A.3?
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):** no aplica
- **Dónde lo usé (parte, script o pregunta):** Parte A.3
- **Propósito (para qué lo necesitaba):** saber qué código de alumno tenía que poner en ESTUDIANTE dentro de config/.env.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** me explicó que el código lo asigna el profesor en la lista de clase (una E y tres dígitos), que no es la matrícula y que no me lo podía inventar, porque si no coincide con la lista cada evidencia queda en NR (D6).
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** no aplica

## Entrada 5
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
revisa el A.4
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
python3 scripts/ops/autoria.py --alumno E065
```
- **Dónde lo usé (parte, script o pregunta):** Parte A.4 (docs/bitacora/lab6-ia.md)
- **Propósito (para qué lo necesitaba):** comprobar si mi lab6-ia.md cumplía la plantilla antes de seguir.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** autoria.py es el comprobador del kit: revisa la declaración (primera línea, campos vacíos y «No he usado IA.» junto con entradas), busca archivos y commits de agentes y comprueba que hay evidencias, y escribe un [FALLO] por cada cosa que sería un descuento.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** [COMPLETA TÚ: la ruta del …_09-autoria.script.log que genera el comando con cabecera]

## Entrada 6
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
[pegué la salida de python3 scripts/ops/autoria.py --alumno E065]
y esto lo podemos dejar para luego y continuar con otras cosas?
se me ha quedado sin bateria el portatil, ayudame a recuperar por donde ibamos
[pegué la salida de docker start, esperar-healthy.sh y gh label create]
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cd ~/oracle-database-lab
source scripts/deployment/env/00-config.sh
docker start oralab-26ai
bash scripts/ops/esperar-healthy.sh
gh label create operations
gh issue create \
  --title "Oracle DBA Operations: daily operations runbook on oralab-26ai (Unit 5)" \
  --label infra --label operations --label documentation \
  --body-file - <<'EOF'
## Description
Walk through Unit 5 on the Lab 5 environment: shift checklist, parameters and PDB states,
an application service and session handling, dictionary perspectives and deltas, storage
with quotas and resumable allocation, access governance, objects/memory/ADR, and an
on-call drill with three real incidents.

## Acceptance criteria
- [ ] AI use declared in docs/bitacora/lab6-ia.md and student code in every evidence header (AI policy)
- [ ] Cold backup of the starting point (evidence 00)
- [ ] Shift checklist and automated maintenance reviewed (01)
- [ ] Parameter safety net, SCOPE rollback, PDB states and SAVE STATE validated (02)
- [ ] academia_app service, APP_ACADEMIA account, session observed, cancelled and killed (03)
- [ ] Three dictionary perspectives and a measured delta (04)
- [ ] TBS_ACADEMIA_HIST with MAXSIZE, ORA-01950/01536, resumable load, shrink (05)
- [ ] Profile, functional roles, nominal account, access debt paid, grant cascade (06)
- [ ] Invalid objects, UNUSABLE index, memory, critical files, ADR and session trace (07)
- [ ] On-call drill: 3 incidents solved with evidence and postmortems (08)
- [ ] 09-verificacion-final.sh: all checks OK; answers in docs/bitacora/lab6-respuestas.md
EOF
```
- **Dónde lo usé (parte, script o pregunta):** Parte A (A.5 y A.6: copia de seguridad, etiqueta `operations` e Issue #14) y recuperación tras apagarse el portátil
- **Propósito (para qué lo necesitaba):** seguir con la práctica dejando la declaración para más tarde, recuperar el trabajo después de quedarme sin batería y crear el Issue del Lab 6.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** `source 00-config.sh` vuelve a cargar las variables en la terminal nueva. `docker start` y `esperar-healthy.sh` arrancan otra vez la base después del apagado (Oracle se recupera solo). `gh label create operations` crea la etiqueta que faltaba en mi repositorio, y `gh issue create` crea el Issue #14 con el título, las etiquetas y los criterios de aceptación del apartado A.6.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** docs/bitacora/lab6/evidencia/script/20261123T092756Z_00-backup-lab6-inicio.script.log · Issue #14 en GitHub

## Entrada 7
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
Enfoca lo que vamos haciendo para optener la maxima nota a menor coste, esta es la salida:
[pegué la salida de gh issue create y del commit de la Parte A]
[pegué la salida de la Parte B, del filter-branch y de 15-healthcheck.sql]
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cd ~/oracle-database-lab
git branch -m chore/14-administracion-operativa
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --msg-filter 'sed "s/^Refs #N$/Refs #14/"' 09bc26b..HEAD
git log --format='%h %s | %(trailers:only,unfold)' -3
git log -3 --format='%B' | grep Refs
git branch --show-current
source scripts/deployment/env/00-config.sh
bash scripts/ops/ro.sh scripts/ops/turno.sql | tee "$EVID_LAB6/script/$(ts)_01-turno.script.log"
bash scripts/ops/ro.sh scripts/lab6/01-automatizacion.sql freepdb1
bash scripts/ops/ro.sh scripts/lab5/15-healthcheck.sql | tee "$EVID_LAB6/script/$(ts)_01-errores-ora.script.log"
git clean -n docs/bitacora/lab5/
git clean -f docs/bitacora/lab5/
git add scripts/ops/turno.sql scripts/lab6/01-* "$EVID_LAB6"
git commit -m "docs(ops): add shift checklist and review automated maintenance

Refs #14"
git add "$EVID_LAB6"
git commit --amend --no-edit
git status --short
```
- **Dónde lo usé (parte, script o pregunta):** Parte A.6 (nombre de la rama y `Refs #14` de los commits) y Parte B (lista de turno, automatización y causa de los errores ORA-, pregunta 1)
- **Propósito (para qué lo necesitaba):** corregir el nombre de la rama y el «Refs #N» que había dejado sin cambiar, y hacer la Parte B averiguando de dónde salían los errores ORA-.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** `git branch -m` cambia el nombre de la rama a chore/14-administracion-operativa, y `git filter-branch --msg-filter` cambia «Refs #N» por «Refs #14» en mis commits del Lab 6, que aún no había subido; los `git log` y `git branch --show-current` lo comprueban. `turno.sql` es la lista de turno de solo lectura (salieron 6 errores ORA- en 24 h). `01-automatizacion.sql` enseña las tareas automáticas, las ventanas de mantenimiento, los umbrales, AWR y los trabajos del Scheduler. `15-healthcheck.sql` lista los errores ORA- con su hora y mensaje (los 6 ORA-00800). `git clean -n` y `-f` borran el spool que ese script dejó en la carpeta del Lab 5, y `git add`, `commit` y `commit --amend` hacen el commit de la Parte B con la evidencia nueva dentro.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** docs/bitacora/lab6/evidencia/script/20261123T101918Z_01-turno.script.log · docs/bitacora/lab6/evidencia/script/20261123T102157Z_01-errores-ora.script.log · docs/bitacora/lab6/evidencia/spool/20261123T101922Z_01-automatizacion.spool.log

## Entrada 8
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
[pegué la salida del cierre de la Parte B y de la Parte C]
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cd ~/oracle-database-lab
source scripts/deployment/env/00-config.sh
bash scripts/lab6/02-pfile-so.sh preparar
bash scripts/ops/sysdba.sh scripts/lab6/02-parametros.sql "$EVID_LAB6/script/$(ts)_02-parametros.script.log"
bash scripts/lab6/02-pfile-so.sh comparar
grep -n "processes\|db_files" "$EVID_LAB6"/config/*_02-init_desde_spfile.ora
bash scripts/lab6/02-estados-pdb.sh | tee "$EVID_LAB6/script/$(ts)_02-estados-pdb.script.log"
git add scripts/lab6/02-* scripts/ops/validar-arranque.sql "$EVID_LAB6"
git commit -m "feat(ops): parameter safety net, PDB states and post-startup validation

Refs #14"
```
- **Dónde lo usé (parte, script o pregunta):** Parte C (parámetros, PFILE y estados de la PDB; preguntas 3, 4 y 5)
- **Propósito (para qué lo necesitaba):** hacer la Parte C: guardar los parámetros antes de tocarlos, probar SCOPE y RESET, y ver los estados de la PDB.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** `02-pfile-so.sh preparar` deja lista la carpeta para sacar los PFILE. `02-parametros.sql` guarda una copia en texto de los parámetros, intenta cambiar en memoria uno estático (ORA-02095), cambia db_files con SCOPE = SPFILE, lo deshace con RESET y prueba que desde la PDB no se puede cambiar un parámetro del CDB (ORA-65040). `02-pfile-so.sh comparar` saca y compara el PFILE del SPFILE (34 líneas) y el de memoria (125), y el `grep` busca processes y db_files (línea 31 con processes=200 y ninguna de db_files). `02-estados-pdb.sh` lleva FREEPDB1 por solo lectura, modo restringido y un reinicio sin estado guardado, la deja abierta con el estado guardado y lanza validar-arranque. `git add` y `git commit` hacen el commit de la Parte C.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** docs/bitacora/lab6/evidencia/script/20261123T102343Z_02-parametros.script.log · docs/bitacora/lab6/evidencia/script/20261123T102343Z_02-estados-pdb.script.log · docs/bitacora/lab6/evidencia/config/20261123T102343Z_02-init_desde_spfile.ora

## Entrada 9
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
[pegué la salida de la Parte C]
ya he cambiado las contraseñas, ahora que?
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cd ~/oracle-database-lab
nano config/.env
source config/.env; for v in "$APP_ACADEMIA_PWD" "$ANA_GARCIA_PWD"; do echo "longitud=${#v} simbolo=$([[ $v =~ [^A-Za-z0-9] ]] && echo si || echo no)"; done
sed -i '/^\(APP_ACADEMIA_PWD\|ANA_GARCIA_PWD\)=/ s/@/#/g' config/.env
source config/.env; for v in "$APP_ACADEMIA_PWD" "$ANA_GARCIA_PWD"; do echo "longitud=${#v} arroba=$([[ $v == *@* ]] && echo SI || echo no) simbolo=$([[ $v =~ [^A-Za-z0-9] ]] && echo si || echo no)"; done
source scripts/deployment/env/00-config.sh
bash scripts/ops/sysdba.sh scripts/lab6/03-servicio.sql "$EVID_LAB6/script/$(ts)_03-servicio.script.log"
bash scripts/lab6/03-cuenta-app.sh | tee "$EVID_LAB6/script/$(ts)_03-cuenta-app.script.log"
bash scripts/lab6/03-sesiones.sh | tee "$EVID_LAB6/script/$(ts)_03-sesiones.script.log"
git add scripts/lab6/03-* scripts/ops/app.sh "$EVID_LAB6"
git commit -m "feat(db): add academia_app service and application account; session handling

Refs #14"
```
- **Dónde lo usé (parte, script o pregunta):** Parte A.3 (contraseñas de config/.env) y Parte D (servicio, cuenta de la aplicación y sesiones; preguntas 6, 7 y 8)
- **Propósito (para qué lo necesitaba):** arreglar las dos contraseñas, que no tenían símbolo y luego tenían una @, y hacer la Parte D.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** con `nano` edito las contraseñas, y el bucle `for` comprueba su longitud y si tienen símbolo sin enseñarlas. `sed -i` cambia la @ por # en esas dos líneas, porque la @ rompe la conexión usuario/clave@servicio, y el segundo `for` lo vuelve a comprobar. `03-servicio.sql` crea y arranca el servicio academia_app en FREEPDB1 y guarda el estado. `03-cuenta-app.sh` crea la cuenta APP_ACADEMIA con su rol y enseña common_user_prefix. `03-sesiones.sh` abre una sesión de la aplicación, la observa (SID, SPID, evento, MODULE, ACTION y cliente), le hace CANCEL SQL y después KILL SESSION, y prueba qué ve SYSOPER. `git add` y `git commit` hacen el commit de la Parte D.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** docs/bitacora/lab6/evidencia/script/20261123T102900Z_03-servicio.script.log · docs/bitacora/lab6/evidencia/script/20261123T102900Z_03-cuenta-app.script.log · docs/bitacora/lab6/evidencia/script/20261123T102900Z_03-sesiones.script.log

## Entrada 10
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
[pegué la salida del commit de la Parte D]
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cd ~/oracle-database-lab
source scripts/deployment/env/00-config.sh
bash scripts/lab6/04-tres-miradas.sh | tee "$EVID_LAB6/script/$(ts)_04-tres-miradas.script.log"
bash scripts/ops/ro.sh scripts/lab6/04-diccionario.sql
bash scripts/ops/sysdba.sh scripts/lab6/04-deltas.sql "$EVID_LAB6/script/$(ts)_04-deltas.script.log"
git add scripts/lab6/04-* "$EVID_LAB6"
git commit -m "docs(ops): dictionary perspectives and delta measurement

Refs #14"
```
- **Dónde lo usé (parte, script o pregunta):** Parte E (tres miradas al diccionario y deltas; preguntas 9 y 10)
- **Propósito (para qué lo necesitaba):** hacer la Parte E: comparar lo que ve cada usuario en el diccionario y medir lo que cuesta una carga.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** `04-tres-miradas.sh` consulta ALL_TABLES, DBA_USERS, CDB_USERS y V$DATAFILE como C##OPS_RO desde la raíz, como C##OPS_RO desde FREEPDB1 y como APP_ACADEMIA. `04-diccionario.sql` recorre vistas del diccionario con C##OPS_RO y guarda su propio spool. `04-deltas.sql` enseña las tasas del último minuto (V$CON_SYSMETRIC), toma una foto de las estadísticas antes y después de una carga y calcula la diferencia (DB time, DB CPU y lecturas lógicas). `git add` y `git commit` hacen el commit de la Parte E.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** docs/bitacora/lab6/evidencia/script/20261123T103116Z_04-tres-miradas.script.log · docs/bitacora/lab6/evidencia/spool/20261123T103124Z_04-diccionario.spool.log · docs/bitacora/lab6/evidencia/script/20261123T103125Z_04-deltas.script.log

## Entrada 11
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
[pegué la salida de la Parte E]
[pegué la salida del commit de la Parte E]
[pegué la salida de la Parte F]
no estoy apuntando nada de preguntas, lo estoy dejando para el final, pasa algo?
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cd ~/oracle-database-lab
source scripts/deployment/env/00-config.sh
bash scripts/ops/sysdba.sh scripts/lab6/05-almacenamiento.sql "$EVID_LAB6/script/$(ts)_05-almacenamiento.script.log"
bash scripts/lab6/05-resumable.sh | tee "$EVID_LAB6/script/$(ts)_05-resumable.script.log"
bash scripts/ops/sysdba.sh scripts/lab6/05-hwm-shrink.sql "$EVID_LAB6/script/$(ts)_05-hwm-shrink.script.log"
git add scripts/lab6/05-* "$EVID_LAB6"
git commit -m "feat(db): add capped history tablespace, quotas, alert threshold and resumable load

Refs #14"
```
- **Dónde lo usé (parte, script o pregunta):** Parte F (tablespace con techo, cuotas, carga reanudable y SHRINK; preguntas 11 a 14)
- **Propósito (para qué lo necesitaba):** hacer la Parte F y saber si podía dejar las preguntas para el final.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** `05-almacenamiento.sql` crea TBS_ACADEMIA_HIST con un máximo de 40 MB, mide lo asignado, lo libre y el máximo, provoca los errores de cuota ORA-01950 (sin cuota), ORA-01536 (cuota agotada) y ORA-30041 (cuota en el temporal) y fija el umbral de alerta. `05-resumable.sh` lanza una carga con RESUMABLE que se suspende al quedarse sin cuota y sigue sola cuando se amplía. `05-hwm-shrink.sql` mide la tabla antes y después de un DELETE y de un SHRINK SPACE. `git add` y `git commit` hacen el commit de la Parte F. Sobre las preguntas, me explicó que podía dejarlas para el final porque las cifras quedan en las evidencias, pero que no repitiera scripts.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** docs/bitacora/lab6/evidencia/script/20261123T103611Z_05-almacenamiento.script.log · docs/bitacora/lab6/evidencia/script/20261123T103611Z_05-resumable.script.log · docs/bitacora/lab6/evidencia/script/20261123T103626Z_05-hwm-shrink.script.log

## Entrada 12
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
[pegué la salida del commit de la Parte F]
lee tu mi consola
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cd ~/oracle-database-lab
source scripts/deployment/env/00-config.sh
bash scripts/lab6/06-gobierno-acceso.sh | tee "$EVID_LAB6/script/$(ts)_06-gobierno-acceso.script.log"
bash scripts/lab6/06-probar-acceso.sh | tee "$EVID_LAB6/script/$(ts)_06-probar-acceso.script.log"
bash scripts/lab6/06-cascada.sh | tee "$EVID_LAB6/script/$(ts)_06-cascada.script.log"
git add scripts/lab6/06-* "$EVID_LAB6"
git commit -m "feat(security): person profile, functional roles, nominal account and access debt paid

Refs #14"
```
- **Dónde lo usé (parte, script o pregunta):** Parte G (perfil, roles funcionales, cuenta nominal y cascada; preguntas 15 y 16)
- **Propósito (para qué lo necesitaba):** hacer la Parte G y que Claude leyera las evidencias directamente en vez de tener que pegarle la salida.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** `06-gobierno-acceso.sh` enseña el perfil DEFAULT, crea el perfil PRF_PERSONAS (la función de verificación rechaza la contraseña débil de prueba_debil con ORA-28003), los roles funcionales y la cuenta nominal ANA_GARCIA, y deja a la aplicación solo con su rol. `06-probar-acceso.sh` prueba lo que Ana puede hacer y lo que no (lee matrículas y cambia el estado, pero recibe ORA-41900 al cambiar el nombre y al borrar), que la aplicación no puede insertar en el histórico (ORA-00942) y bloquea a Ana con 3 contraseñas erróneas (ORA-28000 y LOCKED(TIMED)). `06-cascada.sh` crea U6_A y U6_B, reparte un privilegio de sistema WITH ADMIN OPTION y uno de objeto WITH GRANT OPTION, se los revoca a U6_A y enseña qué conserva U6_B. `git add` y `git commit` hacen el commit de la Parte G.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** docs/bitacora/lab6/evidencia/script/20261123T103958Z_06-gobierno-acceso.script.log · docs/bitacora/lab6/evidencia/script/20261123T103959Z_06-probar-acceso.script.log · docs/bitacora/lab6/evidencia/script/20261123T104006Z_06-cascada.script.log

## Entrada 13
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
hecho commit parte g
hecho
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cd ~/oracle-database-lab
source scripts/deployment/env/00-config.sh
bash scripts/ops/sysdba.sh scripts/lab6/07-objetos.sql "$EVID_LAB6/script/$(ts)_07-objetos.script.log"
bash scripts/ops/ro.sh scripts/lab6/07-memoria.sql | tee "$EVID_LAB6/script/$(ts)_07-memoria.script.log"
bash scripts/ops/ro.sh scripts/lab6/07-archivos-criticos.sql | tee "$EVID_LAB6/script/$(ts)_07-archivos-criticos.script.log"
docker exec oralab-26ai ls -l /opt/oracle/product/26ai/dbhomeFree/dbs/
bash scripts/lab6/07-adr-trazas.sh | tee "$EVID_LAB6/script/$(ts)_07-adr-trazas.script.log"
git add scripts/lab6/07-* "$EVID_LAB6"
git commit -m "docs(ops): object validity, memory advisors, critical files and ADR tracing

Refs #14"
```
- **Dónde lo usé (parte, script o pregunta):** Parte H (objetos, memoria, archivos críticos y ADR; preguntas 17, 18 y 19)
- **Propósito (para qué lo necesitaba):** hacer la Parte H: objetos inválidos, memoria, archivos críticos y trazas.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** `07-objetos.sql` cambia columnas de una tabla de prueba y enseña qué objetos se invalidan y de qué dependen (DBA_DEPENDENCIES), los recompila, deja un índice UNUSABLE con un MOVE, lo reconstruye y vacía la papelera. `07-memoria.sql` enseña la SGA, la PGA y sus advisors. `07-archivos-criticos.sql` lista los archivos críticos de la base. El `ls -l` de dbs/ enseña los archivos de esa carpeta dentro del contenedor. `07-adr-trazas.sh` enseña el ADR, activa la traza de la sesión de la aplicación con DBMS_MONITOR y la resume con tkprof. `git add` y `git commit` hacen el commit de la Parte H.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** docs/bitacora/lab6/evidencia/script/20261123T104232Z_07-objetos.script.log · docs/bitacora/lab6/evidencia/script/20261123T104234Z_07-memoria.script.log · docs/bitacora/lab6/evidencia/script/20261123T104236Z_07-archivos-criticos.script.log · docs/bitacora/lab6/evidencia/script/20261123T104238Z_07-adr-trazas.script.log

## Entrada 14
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
hecho commit parte h
hecho
hecho
hecho
hecho
hecho
hecho
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cd ~/oracle-database-lab
source scripts/deployment/env/00-config.sh
# INC-601
bash scripts/lab6/08-guardia.sh incidente 1 | tee "$EVID_LAB6/script/$(ts)_08-incidente1-ticket.script.log"
bash scripts/ops/ro.sh scripts/lab6/08-diagnostico.sql | tee "$EVID_LAB6/script/$(ts)_08-diagnostico-inc1.script.log"
{ bash scripts/ops/cabecera.sh 08-intervencion-inc1
  printf "ALTER SYSTEM KILL SESSION '175,65254' IMMEDIATE;\n" | docker exec -i oralab-26ai sqlplus -s / as sysdba
  sleep 5
  printf "SET FEEDBACK OFF\nALTER SESSION SET CONTAINER = FREEPDB1;\nSELECT estudiante_id, estado FROM admin_academia.aca_estudiantes WHERE estudiante_id = 101;\n" | docker exec -i oralab-26ai sqlplus -s / as sysdba
} | tee "$EVID_LAB6/script/$(ts)_08-intervencion-inc1.script.log"
bash scripts/ops/ro.sh scripts/lab6/08-diagnostico.sql | tee "$EVID_LAB6/script/$(ts)_08-validacion-inc1.script.log"
# INC-602
bash scripts/lab6/08-guardia.sh incidente 2 | tee "$EVID_LAB6/script/$(ts)_08-incidente2-ticket.script.log"
bash scripts/ops/ro.sh scripts/ops/turno.sql | tee "$EVID_LAB6/script/$(ts)_08-turno-inc2.script.log"
bash scripts/ops/ro.sh scripts/lab6/08-diagnostico.sql | tee "$EVID_LAB6/script/$(ts)_08-diagnostico-inc2.script.log"
docker exec oralab-26ai lsnrctl status | tee "$EVID_LAB6/script/$(ts)_08-listener-inc2.script.log"
rm "$EVID_LAB6/script/20261123T104813Z_08-listener-inc2.script.log" "$EVID_LAB6/script/20261123T104846Z_08-listener-inc2.script.log"
{ bash scripts/ops/cabecera.sh 08-intervencion-inc2
  printf "ALTER SESSION SET CONTAINER = FREEPDB1;\nEXEC DBMS_SERVICE.START_SERVICE('academia_app')\nALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE;\n" | docker exec -i oralab-26ai sqlplus -s / as sysdba
} | tee "$EVID_LAB6/script/$(ts)_08-intervencion-inc2.script.log"
{ bash scripts/ops/cabecera.sh 08-validacion-inc2-listener; docker exec oralab-26ai lsnrctl status | grep -A1 'Service "academia_app"'; } | tee "$EVID_LAB6/script/$(ts)_08-validacion-inc2-listener.script.log"
bash scripts/ops/app.sh scripts/lab6/06-app-sigue.sql | tee "$EVID_LAB6/script/$(ts)_08-validacion-inc2-app.script.log"
# INC-603
bash scripts/lab6/08-guardia.sh incidente 3 | tee "$EVID_LAB6/script/$(ts)_08-incidente3-ticket.script.log"
bash scripts/ops/app.sh scripts/lab6/06-app-sigue.sql | tee "$EVID_LAB6/script/$(ts)_08-sintoma-inc3.script.log"
bash scripts/ops/ro.sh scripts/lab6/08-diagnostico.sql | tee "$EVID_LAB6/script/$(ts)_08-diagnostico-inc3.script.log"
{ bash scripts/ops/cabecera.sh 08-intervencion-inc3
  printf "ALTER SESSION SET CONTAINER = FREEPDB1;\nALTER USER app_academia ACCOUNT UNLOCK;\n" | docker exec -i oralab-26ai sqlplus -s / as sysdba
} | tee "$EVID_LAB6/script/$(ts)_08-intervencion-inc3.script.log"
bash scripts/ops/app.sh scripts/lab6/06-app-sigue.sql | tee "$EVID_LAB6/script/$(ts)_08-validacion-inc3-app.script.log"
bash scripts/ops/ro.sh scripts/lab6/08-diagnostico.sql | tee "$EVID_LAB6/script/$(ts)_08-validacion-inc3.script.log"
git add scripts/lab6/08-* "$EVID_LAB6"
git commit -m "docs(ops): on-call drill with three incidents and postmortems

Refs #14"
```
- **Dónde lo usé (parte, script o pregunta):** Parte I (guardia: diagnóstico, intervención y validación de INC-601, INC-602 e INC-603; pregunta 20)
- **Propósito (para qué lo necesitaba):** resolver los tres incidentes de la guardia con diagnóstico, la intervención más pequeña posible y validación, todo con evidencia.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** en cada incidente, `08-guardia.sh incidente N` provoca la avería y guarda el ticket, y `08-diagnostico.sql`, de solo lectura con C##OPS_RO, guarda quién espera y por quién, la fila, los bloqueos, el undo, ASH, los servicios y las cuentas bloqueadas. `cabecera.sh` pone mi cabecera en las evidencias que no salen de un script del kit. INC-601: el KILL SESSION termina la sesión bloqueadora 175 y la consulta comprueba que el alumno 101 queda en ACTIVO. INC-602: `turno.sql` y `lsnrctl status` demuestran que la base está bien pero el listener no anuncia academia_app; el `rm` borra las dos salidas de lsnrctl que se guardaron sin cabecera; START_SERVICE y SAVE STATE arrancan el servicio y lo dejan guardado, y `lsnrctl` y `app.sh` validan que vuelve a conectar. INC-603: `app.sh` reproduce el ORA-28000, ACCOUNT UNLOCK desbloquea APP_ACADEMIA sin cambiar la contraseña, y `app.sh` y `08-diagnostico.sql` validan. `git add` y `git commit` hacen el commit de la Parte I.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** docs/bitacora/lab6/evidencia/script/20261123T104723Z_08-intervencion-inc1.script.log · docs/bitacora/lab6/evidencia/script/20261123T104914Z_08-intervencion-inc2.script.log · docs/bitacora/lab6/evidencia/script/20261123T105145Z_08-intervencion-inc3.script.log (y los `08-diagnostico-incN` y `08-validacion-incN` de cada incidente)

## Entrada 15
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
vale, he reiniciado el portatil, dime que ir haciendo paso a paso de lo que nos queda
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cd ~/oracle-database-lab
source scripts/deployment/env/00-config.sh
docker start oralab-26ai
bash scripts/ops/esperar-healthy.sh
bash scripts/ops/ro.sh scripts/ops/validar-arranque.sql | tee "$EVID_LAB6/script/$(ts)_08-validacion-inc2-tras-reinicio.script.log"
[ -e docs/bitacora/lab6-respuestas.md ] || cat > docs/bitacora/lab6-respuestas.md <<'EOF'
(estructura de docs/bitacora/lab6-respuestas.md: título, los enunciados de las 20 preguntas de la sección 9 del PDF y los huecos S1-S22)
EOF
[ -e docs/bitacora/lab6-guardia.md ] || cat > docs/bitacora/lab6-guardia.md <<'EOF'
(estructura de docs/bitacora/lab6-guardia.md: la plantilla de postmortem del apartado I.5 del PDF para INC-601, INC-602 e INC-603)
EOF
```
- **Dónde lo usé (parte, script o pregunta):** Parte J (plantillas de las respuestas y de los postmortems) y validación tras reinicio del INC-602
- **Propósito (para qué lo necesitaba):** retomar el trabajo después de reiniciar el portátil y preparar los dos archivos que quedaban por escribir.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** `docker start` y `esperar-healthy.sh` arrancan la base. `validar-arranque.sql` comprueba, después de un reinicio real, que academia_app vuelve a estar arrancado sin hacer nada, lo que valida la acción preventiva del INC-602. Los dos `cat > ... <<'EOF'` crean lab6-respuestas.md y lab6-guardia.md con los enunciados y la plantilla, solo si no existían.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** docs/bitacora/lab6/evidencia/script/20261124T082845Z_08-validacion-inc2-tras-reinicio.script.log

## Entrada 16
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
okay, vamos paso a paso viendo que hay que arreglar
arreglamelo tu
[le envié las frases de las preguntas 9, 13 y de la cascada, redactadas con Claude en claude.ai (entrada 19), para que las revisara]
nom si asi puede pasar, dejemoslo
vale, hazlo tu
[le envié los tres postmortems, redactados con Claude en claude.ai (entrada 20), para que los revisara]
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):** no aplica (revisó las respuestas y los postmortems y señaló errores de concepto en las preguntas 9, 13, 16 y 17, en la S11 y en el INC-602; las correcciones se redactaron con Claude en claude.ai (entradas 19 y 20). Claude Code pegó en docs/bitacora/lab6-respuestas.md el párrafo de la cascada, cambiando «dio» por «recibió» y quitando una errata, y pegó los tres postmortems en docs/bitacora/lab6-guardia.md sin cambiar el texto)
- **Dónde lo usé (parte, script o pregunta):** Parte J (docs/bitacora/lab6-respuestas.md y docs/bitacora/lab6-guardia.md)
- **Propósito (para qué lo necesitaba):** que revisara las respuestas y los postmortems y me señalara los errores de concepto antes de entregar.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** comparó las respuestas y los postmortems con mis evidencias y me dijo qué fallaba: que Ana no solo tenía lectura (pregunta 16), que la función cae en cascada a través de la vista (17), que las horas del alert log no estaban en mi evidencia (13), que V$CON_SYSMETRIC sale en 04-deltas (S11) y que en el INC-602 afirmaba algo del estado guardado que no podía demostrar. Después pegó en los archivos los textos corregidos.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** no aplica

## Entrada 17
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
de la manera que estamos trabajando, puedo llegar al 10?
antes de hacer lo que nos queda, revisa todo y dime que nota me darías en base a lo que llevamos
crea un .md de la conversacion en el escritorio
donde esta lab6-ia.md?
revisa todo lo que llevamos de trabajo y puntualo
que hay en lab6-guardia?
revisa todo lo que hay que preparar para la entrega y ver si esta todo ya listo
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):** no aplica
- **Dónde lo usé (parte, script o pregunta):** Organización del laboratorio: estimación de la nota según la rúbrica, revisión del estado de la entrega y resumen de la conversación (fuera del repositorio)
- **Propósito (para qué lo necesitaba):** saber cómo iba el trabajo, qué nota podía sacar y qué me faltaba para entregar.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** me explicó la fórmula de la nota (rúbrica menos descuentos, por el factor de autoría), estimó mi nota con lo que llevaba, me dijo dónde estaban lab6-ia.md y lab6-guardia.md y qué tenían, revisó qué faltaba para la entrega y guardó un resumen de la conversación en mi escritorio, fuera del repositorio.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** no aplica

## Entrada 18
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
revisa el trabajo de oracle database, el enunciado esta en descvargas de calidad, revisa que tal todo
entonces que nota me das
Entonces arreglarias Lab6-ia?
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):** no aplica (revisó el repositorio contra el enunciado y ejecutó en solo lectura `scripts/ops/autoria.py` y `scripts/lab6/09-verificacion-final.sh`, sin guardar evidencia; añadió esta entrada con los prompts literales)
- **Dónde lo usé (parte, script o pregunta):** Parte J (revisión de lab6-ia.md, lab6-respuestas.md, lab6-guardia.md y evidencias antes del commit final; estimación de la nota)
- **Propósito (para qué lo necesitaba):** revisar todo el trabajo contra el enunciado antes del commit final y saber qué nota tenía.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** comparó mi repositorio con el enunciado, ejecutó en solo lectura el comprobador de autoría y la verificación final para ver qué fallaba, me estimó la nota y completó esta declaración con las entradas que faltaban.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** no aplica

## Entrada 19
- **Herramienta:** Claude (claude.ai, chat)
- **Prompt (literal, copiado tal cual):**
```text
[subí lab6-respuestas.md y la conversación del otro chat]
Hay que responder el lab6-respuestas, ves diciendome que poner linea a linea que se vea que soy estudiante y no profesional
el profesor ha dicho que al final si nos deja usar la IA
dame las respuestas para rellenar el documento
Si deja redactar el pdf, al final ha dicho que usemos la IA para todo
dame todo el texto modo estudiante
[subí el PDF del enunciado v1.2]
pero que luego en clase el dijo que si deja
el pdf es antiguo
Claude, hable hace una hora con el profesor en persona, no voy a pedirle que me responda un correo para que me des las respuestas cuando me acaba de decir que si, me va a decir si soy tonto
[pegué las correcciones del otro chat de las preguntas 9, 13, 16 y 17, de la S11 y de la cascada de privilegios]
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):** el texto de las preguntas 1 a 20 y del simulacro S1 a S22 en docs/bitacora/lab6-respuestas.md, incluidos los párrafos corregidos de las preguntas 9, 13, 16 y 17, la S11 y el párrafo de la cascada
- **Dónde lo usé (parte, script o pregunta):** Parte J, docs/bitacora/lab6-respuestas.md (preguntas 1 a 20 y simulacro)
- **Propósito (para qué lo necesitaba):** redactar las respuestas y el simulacro con mis cifras, porque el profesor nos dijo en clase que podíamos usar la IA también para esto, y me lo confirmó en persona el 24/11/2026
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** es el texto de las respuestas: en cada pregunta junta la cifra de mi evidencia (archivo y apartado) con la explicación del concepto, y en el simulacro da la letra y la Parte donde lo comprobé. Después se corrigió con las revisiones del otro chat.
- **Evidencia de ejecución:** no aplica

## Entrada 20
- **Herramienta:** Claude (claude.ai, chat)
- **Prompt (literal, copiado tal cual):**
```text
[pegué el mensaje del otro chat con los 7 campos del postmortem del INC-601]
[subí la tabla de datos del INC-601]
[subí la revisión del INC-601 y la tabla de datos del INC-602]
[subí la revisión del INC-602 y la tabla de datos del INC-603]
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):** el texto de los tres postmortems (INC-601, INC-602 e INC-603) en docs/bitacora/lab6-guardia.md, incluidas las dos frases corregidas del INC-602
- **Dónde lo usé (parte, script o pregunta):** Parte I, docs/bitacora/lab6-guardia.md
- **Propósito (para qué lo necesitaba):** redactar los postmortems de la guardia a partir de los datos de mis evidencias del 08, con el mismo permiso del profesor que en la entrada 19
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** para cada incidente rellena los 7 campos de la plantilla del I.5 (detección, impacto, diagnóstico, causa raíz, intervención, validación y acción preventiva) con las horas, los SID y las sentencias de mis evidencias.
- **Evidencia de ejecución:** no aplica

## Entrada 21
- **Herramienta:** Claude (claude.ai, chat)
- **Prompt (literal, copiado tal cual):**
```text
[subí docs/bitacora/lab6-ia.md]
del siguiente texto, quita todo lo que evidencie uso de ia o tema comentado de profesor me ha dejado usar ia:
[subí otra versión de docs/bitacora/lab6-ia.md]
dame el texto que te he pasado completo para terminar el trabajo
respondeme, esta permitido
hazlo si deja
okay pon en la primera linea del texto que se ha usado claude para esto
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):** el texto de «Propósito» y «Qué hace» de las entradas 3 a 18, las entradas 19 a 21 y la nota que va debajo de la primera línea de este archivo
- **Dónde lo usé (parte, script o pregunta):** Parte J, docs/bitacora/lab6-ia.md
- **Propósito (para qué lo necesitaba):** completar los campos que me faltaban en esta declaración antes de entregar.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** rellena, en cada entrada, para qué usé lo que me dio la IA y qué hace cada bloque de comandos, y vuelve a poner las entradas que declaran el uso de claude.ai en las respuestas y en los postmortems.
- **Evidencia de ejecución:** no aplica
