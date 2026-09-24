# Lab 2 - Preguntas de comprobación

Autor: Pablo Vicente Juan
Revisor: Julio Checa (jcheca-main)
Repo: oracle-database-lab
Fecha: septiembre 2026

## 1. ¿Por qué un Issue sin criterios de aceptación es un problema, aunque la descripción parezca clara?

Porque si no dices qué tiene que cumplirse, cada persona lo interpreta distinto. Yo pensaba que con poner “mejorar la documentación” ya valía, pero luego no sabes cuándo está realmente terminado. Con criterios de aceptación es más fácil saber qué revisar y qué falta. 

## 2. Diferencia entre Refs #N y Closes #N

Por lo que entendí, Refs solo enlaza el commit con el Issue, pero no lo cierra. En cambio Closes sí lo cierra automáticamente cuando se hace merge del PR. Antes pensaba que ambos hacían lo mismo, pero no. 

## 3. ¿Qué pasa si haces push directo a main protegida? ¿Es fallo del sistema?

No, simplemente te bloquea el push porque la rama está protegida. Yo al principio creí que era un error mío, pero es justo lo que tiene que pasar: te obliga a usar un PR. 

## 4. "Apruebo sin mirar, me fío" ¿Qué riesgo tiene?

Que puedes aprobar algo que está mal sin darte cuenta. Si no miras los cambios, se te pueden colar errores o cosas que no deberían estar. Además tu aprobación queda registrada, así que también es tu responsabilidad. 

## 5. Si el reviewer pide cambios, ¿hay que abrir otro PR?

No, los cambios se hacen en la misma rama y el PR se actualiza solo. Yo pensaba que había que abrir otro, pero no: el PR va ligado a la rama, no a cada commit. 

## 6. Merge commit vs Squash vs Rebase

- Merge commit guarda todos los commits de la rama tal cual y añade un commit de merge. Se queda todo el historial.
- Squash junta todos los commits en uno solo antes de meterlo a main. Deja main más limpio.
- Rebase recoloca los commits uno a uno encima de main, sin commit de merge, queda una línea recta.

Si la rama tiene muchos commits feos tipo “fix”, “wip”, etc., lo mejor es Squash para dejarlo limpio. 

## 7. ¿Por qué borrar la rama no borra el trabajo?

Porque la rama solo apunta a los commits. Si ya hiciste merge, los cambios están en main. Borrar la rama solo quita el puntero, no el trabajo que ya se integró. 

## 8. ¿Qué tiene que tener como mínimo la descripción de un PR?

Un resumen de lo que hace, qué cambió, cómo se probó y qué Issue cierra. Si no pones eso, el revisor tiene que adivinar todo mirando el diff. 

## 9. Un comentario que solo dice "esto está mal" ¿Qué le falta?

Le falta explicar qué está mal, por qué está mal y qué se debería hacer. Si no, el autor no sabe cómo arreglarlo. 

## 10. Diferencia entre main protegida y "acuerdo de no hacer push"

El acuerdo depende de que la gente se acuerde. La protección lo impide de verdad. Aunque seas el dueño del repo, GitHub no te deja hacer push directo. 

## 11. Ejemplo propio de issue (blocking) y nitpick (if-minor)

- `issue (blocking): falta validar que el email no esté vacío antes de guardar, si llega vacío ahora mismo se guarda igual y luego falla el login.`
  Este bloquea porque es un bug real, no se puede aprobar sin arreglarlo.

- `nitpick (if-minor): hay un espacio de más en el comentario de la línea 12, si quieres lo quitas.`
  Este es solo estilo, no bloquea. Si el autor no lo cambia no pasa nada.

La diferencia es la gravedad: uno bloquea y el otro no. 

## 12. Si haces `feat!: cambia la firma de la función principal` ¿Qué versión se dispara?

Una MAJOR, porque el ! indica que rompe compatibilidad. Los feat normales suben MINOR y los fix suben PATCH. 

## 13. ¿Por qué abrir un Draft PR pronto ahorra tiempo aunque parezca más lento?

Porque te corrigen la idea antes de que programes todo. Si esperas al final y está mal planteado, tienes que rehacerlo entero. Con el Draft te dicen rápido si vas bien o no.
