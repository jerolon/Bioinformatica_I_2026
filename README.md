# Bioinformática I — LCG 2026

Material de referencia del curso **Bioinformática I**, 3er semestre, Licenciatura en Ciencias
Genómicas. Viernes 10:00–15:00, del 14 de agosto al 26 de noviembre de 2026.

Sitio: <https://jerolon.github.io/Bioinformatica_I_2026/>

Este repositorio es la **fuente única del material escrito**. Las presentaciones de cada quien
pueden vivir donde cada quien prefiera (revealjs, PDF, lo que sea) y se enlazan desde aquí, pero el
contenido de referencia — el que los alumnos consultan y el que hereda el próximo semestre — vive
en `contenido/`.

## Cómo está organizado

El material está por **tema**, no por sesión. El calendario cambia; el material no.

| Carpeta | Qué hay |
|---------|---------|
| `contenido/01-fundamentos/` | Qué es la bioinformática, terminal, Markdown, git, buenas prácticas |
| `contenido/02-secuencias/` | Tipos de secuencia, código genético, matrices de sustitución, FASTA |
| `contenido/03-alineamientos/` | Needleman–Wunsch, Smith–Waterman, BLAST, CLUSTAL, homología |
| `contenido/04-bases-datos/` | NCBI, INSDC, UniProt, accesiones |
| `contenido/05-browsers/` | Ensamblados, UCSC, Ensembl, formatos de anotación, IGV |
| `contenido/06-introduccion-r/` | Introducción a R |
| `practicas/` | Prácticas de terminal de cada sesión |
| `recursos/` | Bibliografía |
| `assets/prologue/` | Plantilla Prologue de HTML5 UP, sin modificar (CCA 3.0) |
| `assets/css/` | Nuestro tema teal, encima de Prologue |

Este repo es **público**. Dos carpetas viven sólo en el disco de Jero (OneDrive) y están en
`.gitignore` — no están aquí:

- `planeacion/` — notas de planeación, acuerdos entre profesores, decisiones pendientes.
- `research/` — material de investigación en bruto para escribir capítulos.

La portada (`index.html`) es Prologue puro y Quarto **no** la renderiza: se copia tal cual. Todo lo
demás son `.qmd` que Quarto renderiza con el tema de `assets/css/quarto-lgc.scss`.

## Editar el material

Ver **[CONTRIBUIR.md](CONTRIBUIR.md)**. La versión corta: cada página del sitio tiene un enlace
"Editar esta página" que lleva directo al archivo en GitHub. Para un typo, eso basta y no hace
falta instalar nada.

## Render local

Quarto viene incluido con RStudio, así que si tienes RStudio ya lo tienes.

```bash
quarto preview      # servidor local con recarga automática
quarto render       # genera _site/
```

En Windows, si `quarto` no está en el PATH, el que trae RStudio está en:

```
C:\Program Files\RStudio\resources\app\bin\quarto\bin\quarto.exe
```

## Publicación

El workflow de `.github/workflows/publish.yml` renderiza y publica en GitHub Pages en cada push a
`main`. Hay que habilitarlo una vez: **Settings → Pages → Source: GitHub Actions**.

## Licencias

Contenido bajo [CC BY-NC-SA 4.0](LICENSE). Plantilla [Prologue](https://html5up.net/prologue) por
HTML5 UP bajo [CCA 3.0](https://html5up.net/license). Deriva del material de Evelia Coss y Heladia
Salgado, ambos CC BY-NC-SA 4.0. Detalle completo en [ATRIBUCIONES.md](ATRIBUCIONES.md).
