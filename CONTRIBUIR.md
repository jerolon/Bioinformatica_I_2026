# Cómo editar el material

## Un typo, una frase, un enlace roto

Cada página del sitio tiene abajo un enlace **"Editar esta página"**. Te lleva al archivo en GitHub,
lo editas en el navegador, le das *Commit changes*, y el sitio se reconstruye solo. No necesitas
instalar nada ni clonar el repo.

## Escribir un capítulo completo

```bash
git clone https://github.com/jerolon/Bioinformatica_I_2026.git
cd Bioinformatica_I_2026
quarto preview
```

`quarto preview` abre el sitio en el navegador y lo recarga cada vez que guardas. Quarto viene con
RStudio; si no lo tienes en el PATH, ver el README.

Los capítulos son archivos `.qmd`: Markdown normal, más un encabezado YAML. Un capítulo vacío se ve
así:

```markdown
---
title: "BLAST"
subtitle: "Unidad 3 · Sesión 8"
author: "Jero"
---

::: {.pendiente}
Capítulo por escribir.
:::

## Idea central

## Desarrollo

## Práctica

## Fuentes {.unnumbered}
```

Cuando empieces a escribirlo, **borra el bloque `::: {.pendiente}`** — es sólo el aviso de que está
vacío.

## Reglas de la casa

**Un capítulo, un tema.** Si un capítulo cubre dos cosas, son dos capítulos. Es material de
consulta: la gente llega buscando una cosa.

**El material está por tema, no por sesión.** El campo `subtitle` dice a qué sesión corresponde hoy,
pero el capítulo tiene que sostenerse solo. Si el calendario cambia — y va a cambiar — sólo se toca
el `subtitle`.

**Siempre citar la fuente.** Todo lo que viene de otro material va en `## Fuentes` con enlace. La
atribución no es cortesía. Y ojo: **no todas las fuentes se pueden adaptar igual.** Antes de reusar
algo, mira de quién es:

| Fuente | Qué se puede hacer |
|--------|--------------------|
| **Evelia Coss** | Adaptar con atribución. Su material es CC BY-NC-SA 4.0 y además dio permiso explícito. Cítala en `## Fuentes` y, si adaptaste, dilo. |
| **Heladia Salgado** | **Sólo citar y enlazar.** Su licencia no está confirmada; hasta nuevo aviso se trata como todos los derechos reservados. **No** adaptes ni copies su texto, ejercicios, datasets, figuras ni sus pares de secuencias de ejemplo. Sirve para saber qué temas van y en qué orden. Si un capítulo parece necesitar algo de ella, **pregúntale a Jero antes de escribir.** |
| **Compeau & Pevzner** | Citar y enlazar como bibliografía. **No** adaptes su marco pedagógico (el Manhattan Tourist Problem) hasta que respondan la solicitud de licencia. |
| **Figuras de papers** | Cita la fuente en el pie. Si la figura no es tuya y no tiene licencia compatible, no la copies: rehazla con datos propios. |

Cuando la licencia de una fuente cambie, se actualiza [ATRIBUCIONES.md](ATRIBUCIONES.md) y esta tabla.

**Las imágenes van en `images/`,** con nombres descriptivos (`blast-seed-extend.png`, no
`imagen1.png`). Si la imagen no es tuya, la fuente va en el pie.

## Agregar un capítulo nuevo

Dos pasos:

1. Crea el `.qmd` en la carpeta de la unidad que le toca.
2. Agrégalo a la barra lateral en `_quarto.yml`, en la sección `website: sidebar: contents:`.

Si te saltas el paso 2 la página se renderiza, pero nadie la encuentra.

## Clases de estilo disponibles

Las mismas de las presentaciones del curso, para poder pegar material sin retocar nada:

| Clase | Para qué |
|-------|----------|
| `.callout-box` | Caja teal — nota al margen, dato curioso |
| `.ventaja` | Caja verde |
| `.desventaja` | Caja ámbar |
| `.pendiente` | Aviso de "esto falta". Se borra al escribir |
| `.ref` | Cita o referencia, letra chica y gris |
| `.small`, `.medium` | Texto más chico |

Se usan así:

```markdown
::: {.callout-box}
El E-value depende del tamaño de la base de datos. El mismo hit cambia de E-value
si cambias de base.
:::
```

## Presentaciones

El repo guarda el **material de referencia**. Las presentaciones pueden vivir donde cada quien
quiera; sólo hace falta enlazarlas desde el capítulo que les toca. Si quieres que las diapositivas
vivan aquí, ponlas en `presentaciones/` — el tema teal ya coincide con el `custom.scss` de revealjs
del curso.

Dos recordatorios de revealjs que ya nos costaron caro antes:

- `embed-resources: true` y `chalkboard: true` son **incompatibles**. De ahí que haya dos versiones
  del YAML: una de aula (con pizarra) y una web (autocontenida).
- Siempre `---` antes de un `## {background-color="..."}` o Pandoc lo ignora.

## Material interno

**Este repositorio es público.** Todo lo que se commitea es visible para cualquiera, incluyendo a
los alumnos — aunque no salga en el sitio.

Dos carpetas viven sólo en el disco de Jero y están en `.gitignore`:

- `planeacion/` — notas de planeación, acuerdos entre profesores, decisiones pendientes.
- `research/` — material de investigación en bruto para escribir capítulos.

Están excluidas por partida doble: de `.gitignore` (no entran al repo) y de `_quarto.yml` (no se
renderizan aunque las tengas en local). Si algo de ahí ya está decidido y es para los alumnos,
muévelo a `contenido/` — ahí sí se publica.

Antes de commitear algo que no sea material de clase, pregúntate si te importaría que un alumno lo
leyera.
