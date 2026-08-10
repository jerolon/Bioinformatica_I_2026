# Figuras de la Unidad 6

**Esta unidad es un caso distinto a las demás y conviene decirlo antes de
empezar.**

En los capítulos anteriores, las figuras eran ilustraciones que Claude
Code generaba y el alumno miraba. Acá la mayoría de las figuras **las
producen los alumnos como ejercicio**, y su código está en el cuerpo del
capítulo.

Por lo tanto: **solo hay que pre-generar cuatro figuras**, y son las que
ilustran conceptos, no resultados.

Reglas de siempre: R con ggplot2 y svglite, `source("figuras/_tema.R")`,
sin título dentro del SVG, `svg.fonttype = "none"`, fondo transparente.

> **Nota sobre esa regla.** En este repo el archivo central de estilo se
> llama `figuras/estilo.R`, y cada sesión tiene su propio `_tema.R`
> adaptador al lado de sus scripts. Se siguió esa convención, que es la
> que ya usan las sesiones 1 a 11: los scripts hacen
> `source(file.path(dirname(.ubicar()), "_tema.R"))` y ese `_tema.R`
> cablea a `estilo.R`. El resto de la regla se cumple tal cual.

--------------------------------------------------------------------
## Fig 1. `@fig-r-python` — el reparto entre R y Python (ESQUEMA)
Archivo: `figuras/unidad6/r-vs-python.svg`
Script: `figuras/unidad6/01_r_vs_python.R`
Va en: sesión 12, sección "R o Python"

Dos columnas de tareas, no dos columnas de lenguajes. El punto es que la
decisión es por tarea.

**Columna izquierda, "donde gana R"**: genómica estadística (DESeq2,
edgeR, limma), álgebra de intervalos (GenomicRanges), gráficas de
publicación (ggplot2), Bioconductor con su cifra de paquetes.

**Columna derecha, "donde gana Python"**: aprendizaje profundo, célula
única a gran escala (scanpy, scverse), orquestación de pipelines,
ingeniería de software.

**Y en medio, una franja horizontal** que cruza las dos columnas,
etiquetada "puentes: reticulate, zellkonverter, anndata", con flechas
bidireccionales.

Esa franja del medio **es** la figura. Sin ella parece una comparación;
con ella se ve que la respuesta es "los dos".

Nota al pie en GRIS: "Panorama de 2026. Este reparto cambia."

16 x 10 cm. `theme_void()`.

--------------------------------------------------------------------
## Fig 2. `@fig-bedtools-plyranges` — el mismo verbo, dos herramientas (ESQUEMA)
Archivo: `figuras/unidad6/bedtools-plyranges.svg`
Script: `figuras/unidad6/02_bedtools_plyranges.R`
Va en: sesión 14, sección "El mismo verbo, otra sintaxis"

Tabla-figura de dos columnas con la correspondencia. En monoespaciada.

````
bedtools intersect  ←→  join_overlap_inner()
bedtools merge      ←→  reduce_ranges()
bedtools sort       ←→  arrange()
bedtools subtract   ←→  setdiff_ranges()
bedtools closest    ←→  join_nearest()
bedtools slop       ←→  anchor_center() %>% stretch()
bedtools getfasta   ←→  getSeq()
````

Encabezados: "en la terminal (sesión 11)" y "en R (hoy)".

Debajo, separado por una línea, el punto que la tabla no dice sola:
en NARANJA, "el objeto GRanges sabe su genoma y su sistema de coordenadas;
un archivo BED no sabe nada".

Y al margen del renglón de `slop`, una llamada chica: "`bedtools` asume
qué extremo se fija; `plyranges` obliga a decirlo".

16 x 11 cm.

--------------------------------------------------------------------
## Fig 3. `@fig-matriz-ejemplo` — la matriz de programación dinámica (DATOS)
Archivo: `figuras/unidad6/matriz-nw-ejemplo.svg`
Va en: sesión 14, sección "La matriz de programación dinámica"
Script: `figuras/unidad6/03_matriz_nw.R`

**Esta es la figura insignia del bloque y es la única con datos.**

Es un ejemplo de lo que los alumnos van a producir, así que hay que
generarla **con el mismo código que trae el capítulo**, no con uno mejor.
Si el código del capítulo produce una figura fea, hay que arreglar el
capítulo, no la figura.

Procedimiento:

1. Copia la función `nw()` y la función `camino()` textualmente del
   capítulo de la sesión 12 y de la 14.
2. Córrelas con `nw("ATGCTA", "ATCGTA", submat, gap = -2)` y la matriz de
   sustitución simple (match 1, mismatch -1) del capítulo.
3. Genera la gráfica con el bloque de `ggplot2` del capítulo, tal cual.
4. Guárdala con svglite.

**Verifica y repórtame**: el score final que sale en la esquina, y que la
línea del traceback llegue efectivamente de la esquina inferior derecha a
la superior izquierda sin saltos.

Si el traceback se ve entrecortado, hay un error en `camino()` y hay que
avisar antes de publicar, porque los alumnos van a correr ese mismo
código.

16 x 12 cm, `coord_fixed()`.

> **Resultado de la verificación** (R 4.6.0, Bioconductor 3.23):
> score en la esquina = **2**; traceback **continuo**, 6 pasos, de la
> celda (7,7) a la (1,1), sin saltos de más de una celda. El script
> aborta con `stop()` si eso deja de cumplirse, así que la comprobación
> se repite en cada regeneración.
>
> **Pero hay algo que sí conviene decidir antes de publicar**: con
> `"ATGCTA"` contra `"ATCGTA"` el camino óptimo es una diagonal perfecta
> —seis pasos, cero huecos—. La figura queda correcta y bonita, pero
> **nunca muestra un paso "arriba" ni uno "izquierda"**, que son
> justamente las dos terceras partes de lo que el traceback enseña. Un
> par de secuencias de largo distinto (por ejemplo `"ATGCTA"` contra
> `"ATCTA"`) obligaría al camino a doblar y la figura mostraría los tres
> tipos de movimiento. Es una decisión del capítulo, no del script: si se
> cambia, hay que cambiarlo en la prosa de la sesión 14 y en la 12.

--------------------------------------------------------------------
## Fig 4. `@fig-arco` — el arco de reproducibilidad (ESQUEMA)
Archivo: `figuras/unidad6/arco-reproducibilidad.svg`
Script: `figuras/unidad6/04_arco_reproducibilidad.R`
Va en: sesión 15, sección "Por qué esto cierra el arco"

Una línea de tiempo horizontal de quince sesiones, con tres hitos
marcados y conectados por un arco:

- **Sesión 1**: "git init" y "un resultado que no puedes reproducir no es
  un resultado"
- **Sesión 5 y 11**: "procedencia: accession, versión, fecha, checksum"
- **Sesión 15**: "quarto render"

Sobre los tres, un arco que los une, etiquetado con las tres piezas:
"versionar el código", "registrar la procedencia", "regenerar los
resultados".

Las quince sesiones como marcas tenues en la línea; los tres hitos en
NARANJA y más grandes.

Es una figura de cierre y puede permitirse ser un poco ceremoniosa.

16 x 7 cm. `theme_void()`.

--------------------------------------------------------------------
## Lo que NO hay que generar

Estas aparecen en los capítulos pero **son ejercicios**, con su código en
el cuerpo del texto. No las pre-generes:

- La distribución de identidad de los hits de BLAST (ejercicio, sesión 15)
- Las ventanas de GC del fago lambda (ejercicio 3, sesión 14)
- Los cuatro conjuntos de Anscombe en facetas (ejercicio 5, sesión 14)
- El Datasaurus Dozen (mencionado, sesión 13)
- Cualquier gráfica del reporte final

Si alguna sale mal al correr el código del capítulo, **avísame en lugar
de arreglarla**: significa que el código del capítulo está mal y hay que
corregir ahí.

--------------------------------------------------------------------
## Al terminar

Reporta:
1. El score de la figura 3 y si el traceback quedó continuo.
2. Qué versión de R, ggplot2 y Bioconductor usaste.
3. Si algún bloque de código de los cuatro capítulos falló al correrlo.
4. Si `pwalign::pairwiseAlignment()` da el mismo score que la `nw()` del
   capítulo con los parámetros del ejercicio 1 de la sesión 15.

### Lo reportado (verificación del 2026-08-09, máquina de desarrollo)

1. **Score = 2. Traceback continuo**, 6 pasos, de (7,7) a (1,1). Ver la
   nota de la figura 3 sobre la diagonal perfecta.
2. R 4.6.0 (2026-04-24), Bioconductor 3.23, ggplot2 4.0.3, svglite 2.2.2,
   pwalign 1.8.0, Biostrings 2.80.1, GenomicRanges 1.63.2,
   plyranges 1.32.0, rtracklayer 1.72.0.
3. Sí, tres cosas. Están detalladas en `soluciones/README.md`, sección
   "Estado de la verificación": el `abajo_pesos` / `derecha_pesos` del
   ejercicio 2 de la sesión 12 (corregido), el `import()` de VCF de la
   sesión 14 (**sin corregir, decisión pendiente**) y el desajuste de
   columnas de `gc-ventanas.tsv`.
4. **Sí, coinciden.** Score 6 en los dos, con
   `nw("ATGCTAGCTA", "ATCGTAGCTA", submat, gap = -2)` contra
   `pairwiseAlignment(..., gapOpening = 0, gapExtension = 2,
   type = "global")`. Además, 0 discrepancias en 200 pares al azar de
   largo 3 a 12 con `gap` de -1 a -4.

**Esta verificación se corrió en Windows, no en el cluster.** Los
paquetes y las versiones son los mismos que pide el bloque, pero la
comprobación contra los datos reales de los alumnos y contra el
`/datos/cursos/bioinfo1/` del cluster está pendiente.
