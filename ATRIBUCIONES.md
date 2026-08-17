# Atribuciones

Versión legible en el sitio: [Créditos](https://jerolon.github.io/Bioinformatica_I_2026/creditos.html)

## Contenido del curso

Material escrito por el equipo docente (capítulos, prácticas, presentaciones):
**CC BY-NC-SA 4.0** — ver [LICENSE](LICENSE).

## Material fuente

Las tres fuentes principales tienen estatus de licencia distinto. **No se adaptan igual.**

### Evelia Coss — se adapta con atribución

**Evelia Coss, PhD** — *Introducción a la Bioinformática*, LCG 2025.
<https://eveliacoss.github.io/LCG2025_IntroBioinfo_S1/>

Material **CC BY-NC-SA 4.0** declarado en su sitio, y con **permiso explícito de la autora** para
adaptarlo. Adaptamos con atribución por capítulo: buenas prácticas, Markdown, ejercicios de
anotación (FASTA, GTF, BED, awk).

### Heladia Salgado — referencia de temario, no se adapta

**Heladia Salgado** — *Introducción a la Bioinformática*, Cuernavaca.
<https://lcg-cursos.github.io/material/introbioinfo/>

**Licencia sin confirmar.** Su sitio no declara una licencia localizable y, hasta el momento, no
hemos obtenido confirmación (se escribió a la autora y no hubo respuesta). Hasta nuevo aviso tratamos
su material como **todos los derechos reservados**.

Su curso nos sirve como **referencia de qué temas cubrir y en qué orden** —shell, archivos y GenBank,
alineamientos, BLAST, homología y ciclos, análisis de genomas— y lo citamos con enlace en la sección
`## Fuentes` de cada capítulo. Pero **no adaptamos ni copiamos** su texto, sus ejercicios, sus
datasets, sus figuras ni sus pares de secuencias de ejemplo. Si un capítulo parece necesitar algo de
ahí, se consulta con Jero antes de escribir. Si se confirma la licencia, se actualiza esta sección.

## Plantilla del sitio

**Prologue** by HTML5 UP — <https://html5up.net/prologue> | [@ajlkn](https://twitter.com/ajlkn)
Free for personal and commercial use under the **CCA 3.0 license**
(<https://html5up.net/license>).

Archivos: `assets/prologue/` (CSS, JS y webfonts originales, **sin modificar**) y la estructura de
`index.html`. Copia de la licencia en `assets/prologue/LICENSE.txt`; README original del autor en
`assets/prologue/README.txt`.

### Modificaciones respecto a la plantilla original

La CCA 3.0 pide señalar los cambios cuando se distribuye una adaptación. Los nuestros:

1. **Paleta recoloreada** al tema teal del curso (`#1a7a8a` / `#2bb5c6`), en
   `assets/css/tema-lgc.css`. El CSS original de Prologue no se tocó — el tema se aplica como capa
   encima. Cambios: color del sidebar, accentos (Prologue usa `#8ebebc` y `#e27689`), botones,
   enlaces y tablas.
2. **Contenido, secciones y navegación** reescritos por completo para el curso.
3. **Imágenes de demostración no incluidas.** Las fotos de la demo original (`avatar.jpg`,
   `banner.jpg`, `pic02`–`pic08.jpg`) son de Felicia Simion
   (<http://ineedchemicalx.deviantart.com/>), y el README de la plantilla pide explícitamente que
   no se descarguen ni se reusen sin su permiso. **No se copiaron a este repositorio.** La portada
   usa un degradado en su lugar. Si algún día se agrega una imagen de portada, tiene que ser propia
   o de una fuente con licencia compatible — no la de la demo.
4. Las páginas de contenido no usan Prologue: las genera Quarto con `assets/css/quarto-lgc.scss`,
   que reusa la misma paleta y tipografía para que el sitio se lea como una sola cosa.

## Imágenes de terceros

| Archivo | Fuente | Licencia |
|---------|--------|----------|
| `images/eras-bioinformatica-truong-ritchie-2026.jpg` | Figura 1 de Truong VQ & Ritchie MD (2026), *Eras of bioinformatics technologies from command-line interfaces to artificial intelligence (AI) chatbots*, Briefings in Bioinformatics, [doi:10.1093/bib/bbag256](https://doi.org/10.1093/bib/bbag256). Sin modificar; descargada de la copia en [PMC13353838](https://pmc.ncbi.nlm.nih.gov/articles/PMC13353838/). Se usa en las diapositivas de la sesión 1. | [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) |

## Componentes de terceros

| Componente | Autor | Licencia |
|------------|-------|----------|
| [Prologue](https://html5up.net/prologue) | HTML5 UP (@ajlkn) | [CC BY 3.0](https://html5up.net/license) |
| [Font Awesome](https://fontawesome.com) (incluido en Prologue) | Fonticons, Inc. | [CC BY 4.0 / SIL OFL 1.1 / MIT](https://fontawesome.com/license/free) |
| [jQuery](https://jquery.com) | OpenJS Foundation | MIT |
| [Scrollex](https://github.com/ajlkn/jquery.scrollex) | @ajlkn | MIT |
| [Responsive Tools](https://github.com/ajlkn/responsive-tools) | @ajlkn | MIT |
| [Source Sans Pro](https://fonts.google.com/specimen/Source+Sans+Pro) | Paul D. Hunt (Adobe) | SIL OFL 1.1 |
| [Quarto](https://quarto.org) | Posit, PBC | MIT |
| [Bootstrap](https://getbootstrap.com) / [Cosmo](https://bootswatch.com/cosmo/) | Twitter, Inc. / Thomas Park | MIT |

El reset CSS que trae Prologue está basado en el de
[Eric Meyer](http://meyerweb.com/eric/tools/css/reset/) (dominio público).

## Bibliografía

Los libros y sitios que se citan como bibliografía (Compeau & Pevzner, Rosalind, EMBL-EBI Training,
NCI) son de sus respectivos autores y sólo se enlazan; no se redistribuye nada.

De **Compeau & Pevzner** (*Bioinformatics Algorithms*) se pidió licencia académica y no ha habido
respuesta. Hasta nuevo aviso lo citamos y enlazamos como bibliografía, pero **no adaptamos su marco
pedagógico** (en particular el Manhattan Tourist Problem). El capítulo de algoritmos usa un encuadre
propio —la retícula de alineamiento y los números de Delannoy— que no deriva de ese libro.
