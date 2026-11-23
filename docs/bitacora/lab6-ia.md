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
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql

```
- **Dónde lo usé (parte, script o pregunta):** En claude app para la parte B continuar
- **Propósito (para qué lo necesitaba):** Arreglar errores
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** 
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** 

## Entrada 2
- **Herramienta:** Claude
- **Prompt (literal, copiado tal cual):**
```text
Dime que poner en la terminal para poder abrir otra vez una nueva ventana y continuar por el paso que me había quedado.
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql

```
- **Dónde lo usé (parte, script o pregunta):** En claude app para la parte B continuar
- **Propósito (para qué lo necesitaba):** continuar la práctica
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** 
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** 

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
- **Propósito (para qué lo necesitaba):** 
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** 
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** 

## Entrada 4
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
Cual es mi codigo de la lista de clase para el paso A.3?
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):** no aplica
- **Dónde lo usé (parte, script o pregunta):** Parte A.3
- **Propósito (para qué lo necesitaba):** 
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** 
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** no aplica

## Entrada 5
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
ya esta, vamos al siguiente paso
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cd ~/oracle-database-lab
nano config/.env
git check-ignore config/.env && echo "config/.env está fuera de Git"
bash scripts/ops/alumno.sh
source config/.env
cp docs/plantillas/IA.md docs/bitacora/lab6-ia.md
sed -i "s/E0NN/$ESTUDIANTE/" docs/bitacora/lab6-ia.md
ls -d .claude CLAUDE.md AGENTS.md .cursor 2>/dev/null && echo "ATENCIÓN: archivos de agente" || echo "Sin archivos de agente"
nano docs/bitacora/lab6-ia.md
```
- **Dónde lo usé (parte, script o pregunta):** Parte A.3 y A.4
- **Propósito (para qué lo necesitaba):** 
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** 
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** 

## Entrada 6
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
- **Propósito (para qué lo necesitaba):** 
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** 
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** 

## Entrada 7
- **Herramienta:** Claude Code
- **Prompt (literal, copiado tal cual):**
```text
corrigelo tu
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):** no aplica (Claude Code editó directamente este archivo, docs/bitacora/lab6-ia.md)
- **Dónde lo usé (parte, script o pregunta):** Parte A.4 (docs/bitacora/lab6-ia.md)
- **Propósito (para qué lo necesitaba):** 
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** 
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):** no aplica
