# Lab 2 - Preguntas de comprobación

Autor: Pablo Vicente Juan
Revisor: Julio Checa (jcheca-main)
Repo: oracle-database-lab
Fecha: septiembre 2026

## 1. ¿Por qué un Issue sin criterios de aceptación es un problema, aunque la descripción parezca clara?

Porque cada uno entiende lo "claro" de una forma distinta. Si solo pones "mejorar la documentación" no sabes cuando has terminado ni el revisor sabe que comprobar. En el lab lo vimos con el Issue #2, la checklist (que exista CONTRIBUTING.md, que explique branches, que explique commits, que esté enlazado) es lo que nos permitió decir si estaba hecho o no sin tener que preguntar.

## 2. Diferencia entre Refs #N y Closes #N

Refs solo enlaza. Lo usé en el commit `docs: add contribution guidelines` con `Refs #2` y en el Issue apareció el commit referenciado pero el Issue siguió en Open.

Closes es la palabra que cierra. La puse en la descripción del PR (`Closes #2`) y solo cuando se hizo merge a main GitHub cerró el Issue solo. Si pones Closes en una rama que aún no está fusionada no se cierra hasta el merge.

## 3. ¿Qué pasa si haces push directo a main protegida? ¿Es fallo del sistema?

Te lo rechaza con algo como `GH006: Protected branch update failed` y `Changes must be made through a pull request`. No es un fallo, es que la protección está funcionando. Me pasó en la prueba de la parte H. La solución no es forzar, es crear rama y abrir PR. Al principio pensé que me había equivocado en el remote pero luego vi que era lo esperado.

## 4. "Apruebo sin mirar, me fío" ¿Qué riesgo tiene?

Que el review no sirve para nada. Si no miras Files changed se te cuelan errores, secretos, o cosas que no cumplen los criterios del Issue. Además luego el merge queda registrado con tu aprobación y si rompe main la culpa también es tuya por aprobar sin revisar. Revisar es comprobar, no confiar.

## 5. Si el reviewer pide cambios, ¿hay que abrir otro PR?

No. Esa fue una de las cosas que más me costó entender. El PR va ligado a la rama, no a los commits. Si haces otro commit y push en la misma rama `docs/2-contribution-guidelines`, el mismo PR #3 se actualiza solo con el nuevo diff. Abrir otro PR rompería el hilo y se perdería la conversación anterior.

## 6. Merge commit vs Squash vs Rebase

- Merge commit guarda todos los commits de la rama tal cual y añade un commit de merge. Se queda todo el historial.
- Squash junta todos los commits en uno solo antes de meterlo a main. Deja main más limpio.
- Rebase recoloca los commits uno a uno encima de main, sin commit de merge, queda una línea recta.

Para una rama con `wip`, `fix`, `fix2`, `ok ya` usaría Squash, porque esos mensajes no aportan nada en main. Eso hicimos en el lab para dejar un solo commit limpio.

## 7. ¿Por qué borrar la rama no borra el trabajo?

Porque la rama solo es un puntero. Cuando haces merge los cambios ya están en main (según la estrategia que elijas). Borrar la rama solo quita el puntero, no los commits que ya están integrados. Por eso después del merge borramos `docs/2-contribution-guidelines` en remoto y en local y el CONTRIBUTING.md siguió en main.

## 8. ¿Qué tiene que tener como mínimo la descripción de un PR?

Lo que usamos en la plantilla: que hace (Summary), que ha cambiado (Changes), como se ha probado (Testing) y a que Issue cierra (Related Issue con Closes #N). Sin eso el revisor tiene que adivinar leyendo todo el diff. En nuestro PR #3 eso ayudó a Julio a saber que revisar.

## 9. Un comentario que solo dice "esto está mal" ¿Qué le falta?

Le falta todo: que dice que está mal, por qué está mal y que propone en su lugar. Así solo genera discusión y el autor no sabe que hacer.

Yo lo cambiaría por algo así: `issue (blocking): en esta función si la lista viene vacía peta, lo probé pasando [] y da error. Propongo comprobar al inicio si está vacía y devolver 0`.

## 10. Diferencia entre main protegida y "acuerdo de no hacer push"

El acuerdo depende de que la gente se acuerde y no se equivoque. La protección lo impide de verdad. Aunque seas el dueño del repo, si intentas push directo GitHub te lo bloquea. Una es una norma y la otra es una norma que el servidor hace cumplir.

## 11. Ejemplo propio de issue (blocking) y nitpick (if-minor)

- `issue (blocking): falta validar que el email no esté vacío antes de guardar, si llega vacío ahora mismo se guarda igual y luego falla el login.`
  Este bloquea porque es un bug real, no se puede aprobar sin arreglarlo.

- `nitpick (if-minor): hay un espacio de más en el comentario de la línea 12, si quieres lo quitas.`
  Este es solo estilo, no bloquea. Si el autor no lo cambia no pasa nada.

La diferencia es la gravedad, y con el label ya sabes si tienes que corregirlo sí o sí o si es opcional.

## 12. Si haces `feat!: cambia la firma de la función principal` ¿Qué versión se dispara?

Se dispara una MAJOR, por ejemplo de 2.1.0 a 3.0.0. El `!` o el `BREAKING CHANGE` significa que rompe compatibilidad, el código que usaba la función anterior ya no va a funcionar. Los `feat` normales son MINOR y los `fix` son PATCH.

## 13. ¿Por qué abrir un Draft PR pronto ahorra tiempo aunque parezca más lento?

Porque te dicen si vas mal antes de que hagas todo el trabajo. Si esperas a terminarlo todo y luego te dicen que el enfoque estaba mal, tienes que tirar horas a la basura y encima te da rabia cambiarlo. Con el Draft enseñas el esqueleto al principio, te corrigen la idea en 10 minutos y luego ya programas sobre seguro. Al final pierdes un rato al inicio pero ganas mucho después.
