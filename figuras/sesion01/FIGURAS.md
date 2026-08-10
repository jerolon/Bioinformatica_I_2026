# Figuras de la Sesión 01

**Diez figuras, en tres grupos.** Cada una es un script de **R (ggplot2 +
svglite)** que computa (si aplica) y renderiza un SVG. Script y SVG se comitean
a git, los dos, no solo el SVG.

| Grupo | Figuras | Van en |
|---|---|---|
| **A. Capítulo** | `@fig-costos`, `@fig-crecimiento`, `@fig-brecha`, `@fig-linea-tiempo` | `contenido/01-fundamentos/que-es-la-bioinformatica.qmd` |
| **B. Práctica del genoma** | `@fig-fasta`, `@fig-pipe`, `@fig-gc-ventanas`, `@fig-composicion`, `@fig-gc-genomas` | **huérfanas**, ver abajo |
| **C. Práctica de git** | `@fig-zonas` | `contenido/01-fundamentos/sesion01-practica.qmd` |

Las cuatro del grupo A son de datos secundarios (NHGRI, GenBank, UniProt) y sus
números van declarados como constantes con su fuente. Las cinco del grupo B se
calculan de FASTA que se bajan del NCBI: **antes de regenerarlas hay que correr
`figuras/sesion01/00_descarga_datos.sh`**. La del grupo C es un esquema y no
lee nada.

## Las cinco del grupo B están huérfanas

La práctica de la sesión 1 cambió: `sesion01-practica.qmd` ya no es "la terminal
y un genoma" sino "git para científicos", y `terminal.qmd` se borró. **Ningún
`.qmd` referencia hoy a las cinco figuras del grupo B**, comprobado con un grep
sobre `contenido/`.

No se borraron, y no se movieron a otra carpeta, porque la práctica del genoma
va a reubicarse en otra sesión y todavía no está decidido en cuál. Cuando se
decida, estas cinco (más `00_descarga_datos.sh`, `_tema.R` y los `.tsv`) se
mueven a `figuras/<esa-sesión>/` y se actualiza la ruta de los `![](...)` del
capítulo que las reciba. Mientras tanto siguen acá, regenerables y verificadas,
y este párrafo existe para que nadie las dé por muertas ni las borre por
inventario.

Lo que se queda en esta carpeta pase lo que pase: el grupo A (es del capítulo
teórico, que no se mueve) y el grupo C (es de la práctica de git).

Regenerar todas, desde la raíz del repo:

```bash
bash figuras/sesion01/00_descarga_datos.sh     # sólo hace falta para el grupo B
for f in figuras/sesion01/*.R; do Rscript "$f"; done
```

`_tema.R` empieza con guión bajo a propósito: no es una figura, es el adaptador
que usan los scripts del grupo B. El glob de arriba lo incluye, pero correrlo
suelto no hace nada más que cargar `estilo.R`.

Cada script trae al final un bloque de comprobaciones (`stopifnot`) sobre sus
anclas: si una fuente cambió de formato o alguien pegó mal una serie, el script
truena en vez de dibujar una figura silenciosamente equivocada.

## Por qué R y no Python

El curso enseña R y el resto del libro se compila con el motor knitr, así que
las figuras de esta sesión se hacen en R para que un alumno pueda abrir el
script y entenderlo con lo que ya vio en clase. Los capítulos viejos (BLAST,
alineamientos, NCBI) siguen en matplotlib: **`figuras/estilo.py` se queda**, lo
usan 19 scripts. Los dos módulos de estilo comparten la misma paleta, así que
las figuras combinan aunque vengan de motores distintos.

svglite además resuelve mejor el requisito de CorelDRAW que el device `svg()`
de base R, que vectoriza el texto: svglite escribe `<text>` de verdad.

## Reglas comunes

Las impone `figuras/estilo.R`, gemelo de `estilo.py`. Los scripts hacen
`source()` de él y no repiten configuración; el bootstrap que llevan arriba es
para que `Rscript figuras/sesion01/<script>.R` corra desde la raíz sin
instalar nada ni depender del working directory.

- Paquetes: `ggplot2`, `svglite`, `scales`, `systemfonts`. Nada más.
- Salida por `guardar(p, nombre, subdir = "sesion01")`, que llama a `svglite()`
  con `bg = "transparent"`.
- `fix_text_size = FALSE`: sin atributos `textLength`. Con `textLength` puesto,
  editar una etiqueta en CorelDRAW la estira o la aplasta para respetar el
  ancho original; sin él, el texto se comporta como texto normal.
- Texto editable: los cuatro SVG traen elementos `<text>`, ninguno vectorizado.
- **Diff limpio:** svglite no escribe fecha ni IDs aleatorios (sus ids de clip
  salen de las coordenadas). Comprobado corriendo los cuatro scripts dos veces
  y comparando SHA-256: los cuatro archivos salen **idénticos byte a byte**.
- Sin título dentro del SVG. El caption de Quarto ya está escrito en el .qmd.
  La nota de fuente sí va dentro de la figura, vía `labs(caption = ...)`.
- Etiquetas de ejes y anotaciones en español.
- Tipografía: `guardar()` reescribe el `font-family` que resuelve svglite (una
  sola familia, la que haya en la máquina) por el stack completo del libro
  (`"Source Sans Pro", "Segoe UI", …`), para que la figura combine con el
  cuerpo del sitio aunque Source Sans Pro no esté instalada. En esta máquina no
  lo está: svglite resuelve a Arial y el post-proceso lo corrige.
- Tamaño: 6.3 × 3.9 pulgadas (~16 × 10 cm) en las tres figuras de datos. La
  línea del tiempo usa 7.6 × 4.4: son 61 años y doce etiquetas, y a 6.3 no
  caben sin encimarse.
- Todos los datos numéricos van declarados como variables al inicio del
  script, con comentario de fuente y fecha de consulta.

### Paleta

La especificación traía valores tentativos (`AZUL #1f4e79`, `NARANJA #e07b39`)
con la nota de ajustarlos al tema real del libro. Se ajustaron: `estilo.R` usa
las mismas constantes que `estilo.py`, que son las del sitio
(`assets/css/quarto-lgc.scss`). El mapeo es:

| Rol en la especificación | Constante | Hex | Uso |
|---|---|---|---|
| AZUL (datos principales) | `TEAL` | `#1a7a8a` | trazo primario |
| NARANJA (contraste/referencia) | `AMBAR` | `#d98c00` | Moore, WGS, hitos fundacionales |
| GRIS | `GRIS` | `#666666` | ejes, texto secundario, guías |
| VERDE | `VERDE` | `#2e7d32` | acento terciario (Swiss-Prot) |

Nadie teclea un hex suelto: si el tema cambia, se cambian `estilo.R` y
`estilo.py` y las figuras del libro entero siguen combinando.

### Dos trampas de R que ya están resueltas

Vale la pena conocerlas antes de tocar los scripts:

- **`geom_col` no sirve en escala logarítmica.** Arranca la barra en cero y
  `log10(0)` es `-Inf`. En la figura 3 se dibujan rectángulos explícitos
  (`geom_rect`) de `BASE_BARRA` al valor.
- **`nudge_x` opera en espacio ya transformado.** Sobre un eje log10, un
  `nudge_x = 0.13` es un factor de 1.35, no un desplazamiento de 0.13 unidades.
  En cambio `annotate(x = ...)` sí va en unidades de dato. Es fácil equivocarse
  y mezclar los dos.

====================================================================
# Grupo A — Figuras del capítulo

--------------------------------------------------------------------
## Figura 1. `@fig-costos`

Archivo: `figuras/sesion01/costo-secuenciacion.svg`
Script:  `figuras/sesion01/costo-secuenciacion.R`

Costo por genoma contra una línea hipotética tipo ley de Moore, eje Y
logarítmico, para que se vea el quiebre de 2008.

**Fuente.** NHGRI, "DNA Sequencing Costs: Data", serie *Cost per Genome*.
Archivo oficial `Sequencing_Cost_Data_Table_May2022.xls`, descargado y leído
el 2026-08-03. Se grafica **la serie completa publicada**: 78 puntos, de
sep-2001 a may-2022, no un muestreo.

Anclas verificadas contra el .xls (las que el script comprueba con
`stopifnot`):

| Ancla | Valor en la especificación | Valor real en el .xls | |
|---|---|---|---|
| sep-2001 | 95 263 072 | 95 263 071.92 | ✅ |
| ene-2008 | 3 000 000 | 3 063 819.99 | ✅ (era "~3 M") |
| 2015 | 4 000 | 3 969.84 (ene-2015) | ✅ |
| may-2022 | 525 | 524.62 | ✅ |
| "oct-2008" | 750 000 | 752 079.90 es **jul**-2008; oct-2008 fue 342 502 | ⚠️ mes mal etiquetado en la especificación |

El último dato publicado por el NHGRI es may-2022; el umbral de ~200 USD de
Illumina (2023) es de otra fuente y se cita solo en la prosa, no se grafica.

Línea de Moore: parte del costo de 2001 y se divide a la mitad cada 2 años.
Trazo ámbar punteado. Guía vertical gris en 2008 con "2008: llega NGS". Eje Y
log10 con etiquetas `$100`, `$1K`, … `$100M`. Leyenda dentro del panel, arriba
a la derecha. Nota al pie: "Fuente: NHGRI, 2001-2022. Escala logarítmica."

--------------------------------------------------------------------
## Figura 2. `@fig-crecimiento`

Archivo: `figuras/sesion01/crecimiento-genbank.svg`
Script:  `figuras/sesion01/crecimiento-genbank.R`

Crecimiento de GenBank en número de bases, eje Y logarítmico.

**Fuente.** NCBI, GenBank release notes § 2.2.8 "Growth of GenBank"
(`ftp.ncbi.nlm.nih.gov/genbank/gbrel.txt`) y las release notes archivadas por
versión en `ftp.ncbi.nlm.nih.gov/genbank/release.notes/`. Leídas el
2026-08-03, cuando la versión vigente era la **272.0 (15-jun-2026)**.

**Van dos series, y no es capricho.** La especificación pedía un solo trazo
que incluyera la porción tradicional más WGS. No se puede hacer honestamente
en todo el rango: las release notes solo reportan el agregado set-based
(WGS/TSA/TLS) **a partir de la versión 235 (dic 2019)**. Antes de esa versión
las notas dicen explícitamente que los datos WGS "no están representados aquí"
porque se distribuían por separado. Un trazo único desde 1982 dibujaría un
salto en 2019 que es un artefacto de cómo se reporta, no crecimiento real.
Entonces:

- **GenBank tradicional, 1982-2026** (teal, 45 puntos, uno por año: la última
  versión de cada año, tomada de la tabla oficial de 236 versiones). Es la
  serie a la que NCBI le atribuye lo de duplicarse cada ~18 meses.
- **Total incluyendo WGS, 2019-2026** (ámbar, 8 puntos). Es la serie que
  corresponde al número que cita el capítulo, así que tiene que estar.

Comprobado: versión 269.0 (dic 2025) = 6 651 459 875 408 bases tradicionales +
43 082 971 215 013 de WGS = **49 734 431 090 421**, o sea los 49.73 billones
del capítulo. Cuadra exacto.

Ese punto lleva un anillo gris además de la guía: la versión 269.0 y la 272.0
quedan pegadas en el eje y una guía sola apuntaría ambiguamente a las dos.

Eje Y log10 con etiquetas en Mb / Gb / Tb. Nota al pie: "Fuente: NCBI GenBank,
versión 269.0 (diciembre 2025). El total se duplica cada ~18 meses."

> ⚠️ Sobre ese "~18 meses": es literalmente lo que dice NCBI en sus propias
> release notes, y por eso se cita así. Pero su propia tabla no lo sostiene en
> todo el rango. Ajuste log-lineal a la serie tradicional: **17.6 meses** para
> 1982-2000, **21.6** para 1995-2010, **30.1** para 2010-2026, **24.7** en el
> rango completo 1982-2026. La frase de NCBI parece heredada de los noventa.
> El script imprime este número al correr. Ver la nota en el .qmd.

--------------------------------------------------------------------
## Figura 3. `@fig-brecha`

Archivo: `figuras/sesion01/brecha-anotacion.svg`
Script:  `figuras/sesion01/brecha-anotacion.R`

La brecha de anotación. Barras horizontales en escala log10 comparando
entradas revisadas (Swiss-Prot) contra no revisadas (TrEMBL) en UniProtKB.
El punto pedagógico es la diferencia de ~260x.

**Fuente.** UniProt release 2026_02 (10-jun-2026), nota de release en
`ftp.uniprot.org/pub/databases/uniprot/current_release/relnotes.txt`,
verificada el 2026-08-03. Swiss-Prot cotejado además contra
`web.expasy.org/docs/relnotes/relstat.html`.

Los tres números vienen publicados explícitamente, así que TrEMBL **no** se
deriva por resta:

    UNIPROTKB_TOTAL <- 149810139
    SWISSPROT       <-    575503   # revisadas, curadas a mano
    TREMBL          <- 149234636   # no revisadas

Los tres valores de la especificación resultaron exactos. El script comprueba
que las partes sumen el total. Razón: 259.3 : 1; revisadas = 0.38 % del total.
La etiqueta de la figura redondea a la decena ("≈ 260×") para decir lo mismo
que el cuerpo del capítulo y no invitar a leer un 259 como si fuera exacto.

Recordatorio que va en el script: UniProtKB se reorganizó en 2026_02 (se
removieron ~141 M entradas redundantes de TrEMBL). Antes de esa limpieza
TrEMBL rondaba ~250 M. Al actualizar, tomar la cifra viva de la versión que
toque, no escalar ésta.

Dos barras: "Revisadas a mano (Swiss-Prot)" en verde, "Anotadas
automáticamente (TrEMBL)" en gris. Eje X log10 (10 K … 1 G). Valor anotado
sobre cada barra y el texto de la razón al centro. Nota al pie: "Fuente:
UniProt 2026_02 (junio 2026). Escala logarítmica. Cifras sujetas a cambio en
cada versión."

--------------------------------------------------------------------
## Figura 4. `@fig-linea-tiempo`

Archivo: `figuras/sesion01/linea-tiempo.svg`
Script:  `figuras/sesion01/linea-tiempo.R`

Línea del tiempo horizontal de la disciplina, 1965-2026. Es esquemática
(posiciones proporcionales al año), no una figura de datos cuantitativos.
Eje horizontal = año; hitos como puntos sobre la línea con etiqueta y año.
Sin eje Y (`theme_void`). Fechas: ver la sección Fuentes del capítulo.

Doce hitos: 1965 Dayhoff · 1970 Needleman-Wunsch y el término
"bioinformática" · 1977 Sanger y phi-X174 · 1981 Smith-Waterman · 1982
GenBank y EMBL · 1990 BLAST · 1995 *H. influenzae* · 2001 borrador del genoma
humano · 2005 NGS · 2008 quiebre del costo · 2021 AlphaFold2 · 2024 AlphaFold3
y Nobel.

**Cómo se evita que se encimen.** No basta alternar arriba/abajo: 1981 y 1982
quedan a un año. Las etiquetas se reparten en **cuatro** niveles ciclados por
índice (arriba cerca, abajo cerca, arriba lejos, abajo lejos), así dos hitos
vecinos nunca comparten nivel. Con este juego de fechas la separación mínima
entre dos hitos del mismo nivel es de **17 años**, de sobra. El script lo
comprueba al final: si alguien agrega o mueve un hito y la separación baja de
12 años, truena y avisa en vez de dibujar encimado. (Se resuelve a mano y no
con `ggrepel` a propósito: repel da posiciones distintas entre corridas y
rompería el diff limpio.)

Línea base y guías en gris, puntos en teal con halo blanco. Los tres hitos
fundacionales (1965, 1970, 1982) van en ámbar, **punto y etiqueta**: el caption
del capítulo dice "los tres marcados en naranja", y marcar solo el texto se
leía débil. Marcas de década bajo la línea. Márgenes de 6 años a cada lado
para que 1965 y 2024 no se corten.


====================================================================
# Grupo B — Figuras de la práctica del genoma

> ⚠️ **Huérfanas.** Se escribieron para la versión anterior de
> `sesion01-practica.qmd` ("la terminal y un genoma"), que se reemplazó por la
> práctica de git. Ningún capítulo las referencia hoy. Ver *Las cinco del grupo
> B están huérfanas*, arriba. Todo lo que sigue en esta sección sigue siendo
> exacto: los scripts corren, los números están verificados y las figuras se
> regeneran idénticas. Lo único pendiente es a qué sesión se mudan.

Cinco figuras. Dos son esquemas (anatomía de un FASTA, un pipeline) y tres son
de datos calculados en el momento a partir de los genomas que baja
`00_descarga_datos.sh`.

## Reglas del grupo B

Se suman a las **Reglas comunes** de arriba, no las reemplazan.

- Cada script escribe, además del SVG, un **`.tsv` con los números que graficó**.
  Es el chequeo de que la figura y el texto del capítulo dicen lo mismo: si
  alguien edita la prosa y no la figura, el `.tsv` lo delata.
- **Ningún número se teclea si se puede calcular del FASTA.** Los `stopifnot`
  del final comprueban las anclas contra la verdad medida.
- Los scripts **leen** los genomas de `datos/`, nunca los vuelven a descargar.
- Dependencias: `ggplot2`, `svglite`, `systemfonts`, `scales`. Nada de
  Bioconductor: los genomas son chicos y se leen bien con base R.
- GC siempre a **una** cifra decimal.

## `_tema.R` es un adaptador, no un módulo de estilo

La especificación de estas cinco figuras pedía un `_tema.R` autónomo, con su
propia paleta declarada a mano:

```r
AZUL <- "#1f4e79" ; NARANJA <- "#e07b39" ; GRIS <- "#6c6c6c" ; VERDE <- "#2e7d5b"
```

Son **exactamente los mismos valores tentativos** que traía la especificación
del grupo A, y que ya se habían descartado por la razón que está escrita arriba
en la sección *Paleta*: no son los colores del libro, y en este repo nadie
teclea un hex suelto. El problema es concreto, no estético: estas cinco figuras
aparecen en la misma sesión que las otras cuatro, dibujadas en `#1a7a8a`. Con
dos azules distintos no combinan.

Entonces `_tema.R` conserva los **nombres** que pedía la especificación y los
cablea a `figuras/estilo.R`:

| Nombre en la especificación | Apunta a | Hex |
|---|---|---|
| `AZUL` | `TEAL` | `#1a7a8a` |
| `NARANJA` | `AMBAR` | `#d98c00` |
| `GRIS` | `GRIS` | `#666666` |
| `VERDE` | `VERDE` | `#2e7d32` |
| `tema_libro(base_size = 10)` | `tema_lgc(base_size = 10)` | — |
| `guardar(p, nombre, w, h)` | `guardar(..., subdir = "sesion01")` | w, h en **cm** |

Los scripts se escriben tal como los describía la especificación; lo que cambia
es a qué apuntan los nombres. `guardar()` traduce de centímetros a pulgadas y
delega en el de `estilo.R`, así que estas figuras heredan gratis el
post-proceso del `font-family` y el diff determinista.

Dato cómodo: **16 × 10 cm son 6.3 × 3.9 pulgadas**, que es el tamaño estándar
del libro. Los dos criterios coinciden y no hubo que elegir.

`_tema.R` agrega además `leer_fasta()`, `ruta_datos()` y `escribir_tsv()`. Ver
el encabezado del archivo.

## Una trampa que costó encontrar: `guardar()` se comía la monoespaciada

Las dos figuras de esquema dibujan texto que **es código** (el contenido de un
FASTA, nombres de comando) y lo colocan en una retícula de ancho fijo. Para eso
piden `familia_mono()`, que en esta máquina resuelve a Consolas.

`guardar()` hacía, en `figuras/estilo.R`:

```r
txt <- gsub('font-family: "[^"]+";', paste0("font-family: ", STACK_SANS, ";"), txt, perl = TRUE)
```

Ese `[^"]+` es cualquier familia, así que **también se llevaba la
monoespaciada**. Resultado: la retícula se calculaba con los avances de
Consolas y el navegador la rellenaba con glifos proporcionales. En
`fasta-anatomia` las letras del header se encimaban justo donde el alumno tiene
que leer (la `m` de "lambda", las de "complete genome").

Lo insidioso es que **no se ve desde R**: el device dibuja bien y el destrozo
ocurre en el post-proceso, después de que el script terminó. Sólo aparece al
abrir el SVG. Un `grep` de `font-family` sobre el archivo devolvía una sola
familia —el stack sans— y eso se lee como "correcto" si uno esperaba
exactamente eso.

El arreglo va en `estilo.R`, no en las figuras: se agregó `STACK_MONO` y
`guardar()` ahora marca las familias monoespaciadas antes del reemplazo y las
restituye después. Se agregó también `familia_mono()`, gemela de
`familia_base()`, para que la familia que elige R al dibujar y el stack que
queda en el archivo sean **la misma decisión**.

`estilo.R` lo comparten las nueve figuras, así que el cambio se verificó por
regresión: se regeneraron las cuatro del grupo A y salen **byte a byte
idénticas** (mismo SHA-256) que antes del cambio. Sólo usan sans, así que el
paso nuevo es un no-op para ellas.

## `00_descarga_datos.sh`

Baja los seis genomas a `datos/` y deja `datos/lambda.fasta` como alias de
`NC_001416.1.fasta`. Es idempotente.

Usa `efetch` (EDirect) si está instalado, que es lo que corren los alumnos en
ken; si no, cae a `curl` contra el mismo endpoint de E-utilities. `efetch` no es
más que un wrapper de esa URL, así que el FASTA que llega es idéntico y el
script también corre en la máquina de quien edita el libro sin instalar EDirect.
El alias se intenta como symlink y cae a copia (Git Bash sobre Windows suele
tener los symlinks deshabilitados; son 48 kb).

### Los seis genomas, medidos

Descargados y verificados el **2026-08-03**. Ninguno trae `N` ni minúsculas de
soft-masking, así que todos los conteos son directos.

| Organismo | Accession | Longitud (pb) | GC |
|---|---|---:|---:|
| Fago lambda | NC_001416.1 | 48 502 | 49.9 % |
| Fago phiX174 | NC_001422.1 | 5 386 | 44.8 % |
| SARS-CoV-2 | NC_045512.2 | 29 903 | 38.0 % |
| *Mycoplasmoides genitalium* G37 | NC_000908.2 | 580 076 | 31.7 % |
| *E. coli* K-12 MG1655 | NC_000913.3 | 4 641 652 | 50.8 % |
| Levadura, cromosoma I | NC_001133.9 | 230 218 | 39.3 % |

Composición de lambda: **A 12 334 · C 11 362 · G 12 820 · T 11 986**.

> **Corregido.** El borrador de la práctica decía 24198 bases G+C. El valor real
> es **24182**: C + G = 11 362 + 12 820, o sea 49.86 %, que redondeado sigue
> siendo el 49.9 % que dice el texto. El error de 16 bases venía heredado del
> borrador viejo de `que-es-la-bioinformatica.qmd`. Importaba porque
> `04_composicion.R` grafica 11 362 y 12 820: un alumno que sumara las dos
> barras obtenía 24 182 y no lo que decía el texto. Ya cuadran los dos.
>
> Por la misma razón se corrigió el header del ejercicio 2, que decía
> `>NC_001416.1 Escherichia phage Lambda, complete genome`. El real, y el que
> dibuja `01_fasta_anatomia.R` leyéndolo del archivo, es
> `>NC_001416.1 Enterobacteria phage lambda, complete genome`.

## Nombre del género de *M. genitalium*

El NCBI ya entrega `NC_000908.2` como ***Mycoplasmoides* genitalium G37**: el
género se reasignó. El capítulo y la etiqueta de la figura dicen *Mycoplasma
genitalium*, que es el nombre con el que los alumnos lo van a encontrar en
cualquier libro. Se deja así a propósito, con el comentario correspondiente en
`05_gc_genomas.R`.

--------------------------------------------------------------------
## Figura 5. `@fig-fasta` — anatomía de un registro FASTA (esquema)

Archivo: `figuras/sesion01/fasta-anatomia.svg`
Script:  `figuras/sesion01/01_fasta_anatomia.R`

Esquema, no datos: ggplot sobre `theme_void()` con `geom_rect`, `geom_text`
(familia monoespaciada) y llamadas.

Muestra las primeras **3 líneas reales** del FASTA de lambda —leídas del
archivo, no tecleadas— en una caja. Anotaciones:

- El `>` que abre el header → "marca de inicio de registro".
- `NC_001416.1` → "accession con versión".
- El resto del header → "descripción libre".
- El final de la primera línea de secuencia, con una marca visible en el salto
  de línea → "salto de línea: es un carácter del archivo, NO una base".
- Una llave abarcando las líneas de secuencia → "70 caracteres por línea".

La anotación del salto de línea va en NARANJA y es **el punto de la figura**;
todo lo demás en AZUL y GRIS. 16 × 7 cm.

`fasta-anatomia.tsv`: número de línea, tipo (header/secuencia) y número de
caracteres de cada una de las tres.

--------------------------------------------------------------------
## Figura 6. `@fig-pipe` — un pipeline (esquema)

Archivo: `figuras/sesion01/pipeline.svg`
Script:  `figuras/sesion01/02_pipeline.R`

`geom_rect` + `geom_segment` con flechas + `geom_text`, `theme_void()`. Cuatro
cajas en fila conectadas por flechas etiquetadas con `|`:

`datos/lambda.fasta` → `grep -v "^>"` → `tr -d '\n'` → `wc -c` → `48502`

Debajo de cada caja de comando, una glosa chica en GRIS: "quita el header",
"quita los saltos de línea", "cuenta caracteres".

El archivo de entrada y el resultado final van en cajas de **borde punteado**
(son datos, no programas); los tres comandos en cajas sólidas AZUL. Sobre las
flechas, en NARANJA chiquito, "stdout". 16 × 6 cm.

El `48502` se calcula del FASTA, no se teclea.

--------------------------------------------------------------------
## Figura 7. `@fig-gc-ventanas` — GC en ventanas a lo largo de lambda

Archivo: `figuras/sesion01/gc-ventanas-lambda.svg`
Script:  `figuras/sesion01/03_gc_ventanas.R`

**Es la figura importante del capítulo.** Muestra el punto de cambio: primera
mitad rica en GC, segunda rica en AT.

Ventanas de **500 pb no traslapadas**. Línea del GC por ventana en AZUL,
`geom_hline` punteada en NARANJA con el promedio global y su etiqueta.
Eje X en kb. 16 × 8 cm.

Medido: **primera mitad 54.9 % GC, segunda mitad 44.8 %**. La afirmación del
capítulo se sostiene y el script la comprueba (`stopifnot` de que la diferencia
entre mitades supere 5 puntos porcentuales).

48 502 no es múltiplo de 500: la última ventana parcial se descarta, quedan
**97 ventanas** y sobran 2 pb. Dicho en un comentario del script.

`gc-ventanas-lambda.tsv`: una fila por ventana (`pos`, `gc`).

--------------------------------------------------------------------
## Figura 8. `@fig-composicion` — composición de bases de lambda

Archivo: `figuras/sesion01/composicion-lambda.svg`
Script:  `figuras/sesion01/04_composicion.R`

Barras verticales con el conteo de A, C, G, T, en ese orden, calculado con
`table()`. A y T en GRIS, C y G en AZUL: la idea visual es que se vea de un
golpe que GC y AT están casi empatados. Etiqueta encima de cada barra con
conteo y porcentaje (`12334 (25.4%)`). Eje Y en miles. 12 × 8 cm.

Si aparece cualquier carácter distinto de A, C, G, T **se grafica también** y el
script avisa con `warning()`. En lambda no aparece ninguno.

`composicion-lambda.tsv`: base, conteo, porcentaje.

--------------------------------------------------------------------
## Figura 9. `@fig-gc-genomas` — GC entre organismos

Archivo: `figuras/sesion01/gc-genomas.svg`
Script:  `figuras/sesion01/05_gc_genomas.R`

Barras horizontales con el GC de cada FASTA de `datos/`, ordenadas de menor a
mayor. Barra de lambda en NARANJA (es el genoma del capítulo), las demás en
AZUL. Etiqueta al final de cada barra con el GC a una cifra decimal. En el eje
Y, junto al nombre, el tamaño entre paréntesis formateado en kb o Mb, no en pb
crudos. 16 × 9 cm.

`gc-genomas.tsv`: nombre, accession, longitud, GC.

El rango va de 31.7 % (*M. genitalium*) a 50.8 % (*E. coli*), que es lo que
afirma el ejercicio 6 del capítulo ("de alrededor de 32 % … a más de 50 %").


====================================================================
# Grupo C — Figuras de la práctica de git

Una figura para `contenido/01-fundamentos/sesion01-practica.qmd`. Es la única
del archivo que no depende de `00_descarga_datos.sh`: no lee nada de `datos/`.

--------------------------------------------------------------------
## Figura 10. `@fig-zonas` — las tres zonas de git (esquema)

Archivo: `figuras/sesion01/git-tres-zonas.svg`
Script:  `figuras/sesion01/06_git_zonas.R`

Esquema sobre `theme_void()`, mismas reglas que las demás (svglite, texto como
`<text>`, sin título interno, fondo transparente). 16 × 9 cm.

Tres cajas en fila, azules y con relleno transparente, con su nombre arriba y su
glosa adentro:

`Directorio de trabajo` → `Staging area` → `Repositorio (.git)`

Flechas de avance en NARANJA con el comando que hace el movimiento (`git add`,
`git commit`). Flechas de regreso más delgadas y en GRIS, con su glosa chica
debajo: `git reset` ("saca del staging") y `git checkout --` ("restaura desde el
último commit"). Y una cuarta caja más chica de borde punteado, arriba a la
derecha, `GitHub (remoto)`, a la que llega una flecha naranja etiquetada
`git push`. Dentro de la caja del repositorio, tres círculos encadenados que
sugieren la secuencia de commits, con el último en naranja.

**Nada se calcula, pero la geometría sí se deriva.** No hay datos que leer, así
que lo que el script evita teclear a ojo son las posiciones: el ancho de las
cajas, el largo de cada flecha y la separación de las etiquetas salen de las
cadenas de texto. Los `stopifnot` del final comprueban lo mismo que en las otras
figuras, sólo que sobre el dibujo en vez de sobre los números: que los cinco
comandos sean los cinco esperados, que ninguna etiqueta se salga del panel, que
`git commit` quepa en el hueco entre cajas, que la cadena de commits quepa
dentro de su caja, y dos que costaron un ajuste cada uno:

- **La flecha del `push` no cruza el nombre de la caja 3.** Sale del borde
  superior cerca de la esquina derecha justamente por eso. Con la holgura actual
  (2.4 mm) el chequeo truena si alguien alarga "Repositorio (.git)".
- **Cada etiqueta de regreso está más cerca de su propia línea que de la otra.**
  Con las dos rutas anidadas a 10 mm, `git reset` quedaba a media distancia de
  las dos flechas y no se sabía a cuál pertenecía. Ahora van a 12.5 mm.

### `git reset` está en la figura pero no en los ejercicios

La práctica llega hasta `git checkout --`; `git reset` no se ejercita. Está
dibujado a propósito: el modelo de tres zonas se entiende mal si el staging
parece una calle de un solo sentido. Dicho también en un comentario del script,
para que nadie lo "corrija" después.

### `git-tres-zonas.tsv`

El `.tsv` de esta figura no lleva números medidos, porque no hay ninguno que
medir: lleva las cinco transiciones (origen, destino, comando, sentido, glosa).
Sirve para lo mismo que los otros del archivo —cotejar la figura contra la prosa
del capítulo— sólo que acá lo que tiene que cuadrar son los comandos.

**Fuente.** El modelo de las tres zonas es el del capítulo 2 de *Pro Git*
(Chacon & Straub), que es una de las lecturas de la práctica; los comandos son
los que se tecleen en los ejercicios. Va dicho en la nota al pie de la figura.
