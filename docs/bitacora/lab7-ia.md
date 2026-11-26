He leído la política de uso de IA de la asignatura.

# Declaración de uso de IA · Lab 7 · E065

<!--
CÓMO SE RELLENA (léelo y borra este comentario si quieres; el script de evaluación lo ignora)
- La PRIMERA línea es obligatoria y no se toca: «He leído la política de uso de IA de la asignatura.»
- Copia este archivo como docs/bitacora/lab7-ia.md (junto a lab7-respuestas.md) y pon tu código en el título.
  Cada laboratorio tiene el suyo: el del Lab 6 (lab6-ia.md) no se toca.
- Si NO has usado IA: deja solo la línea «No he usado IA.» y borra la entrada de ejemplo.
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
- **Herramienta:** Claude (Claude Code, modelo Opus 5.5)
- **Prompt (literal, copiado tal cual):**
```text
Ayudame a arreglar los bugs para hacer bien el lab7 porfa
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
-- Órdenes de terminal que no venían tal cual en la guía:
cp ~/Descargas/P2_Lab7_v1.0_Estudiante.zip ~/
git restore docs/bitacora/lab6-ia.md
git branch -m perf/16-optimizacion
-- Orden que ejecutó Claude con mi cuenta de GitHub (a petición mía):
gh issue create --title "Oracle Performance Tuning: Unit 6 cases, incidents and evidence on oralab-26ai" --label performance --label documentation --body "<descripción y criterios de aceptación de la guía, Parte A.6>"
-- Además, Claude ejecutó órdenes de solo lectura para comprobar cada paso
-- (git status, ls, docker ps, cat de este archivo) y escribió esta entrada con mis datos.
```
- **Dónde lo usé (parte, script o pregunta):** Parte A (A.1 a A.6): kit, instalar.sh, copia lab7-inicio, banco T6, Issue #16 y rama perf/16-optimizacion
- **Propósito (para qué lo necesitaba):** ye he usado para arreglar los bugs o errores
- **Qué hace (con mis palabras; línea a línea si es SQL corto):**
  - cp: 
  - git restore: 
  - git branch -m: 
  - gh issue create: 
- **Evidencia de ejecución (archivo de docs/bitacora/lab7/evidencia con mi cabecera):** no aplica
