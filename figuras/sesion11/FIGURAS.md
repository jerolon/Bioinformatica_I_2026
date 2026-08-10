# Figuras de la Unidad 4 — Bases de datos (Sesión 11)

Cinco figuras para los cuatro capítulos de `contenido/04-bases-datos/`.
Reglas de siempre: R con ggplot2 y **svglite**, `source("_tema.R")`, sin título
dentro del SVG (el caption vive en el `.qmd`), `svg.fonttype = "none"`, fondo
transparente.

Las unidades 4 y 5 son **la misma sesión de cinco horas**, así que las figuras
de browsers viven en esta misma carpeta, numeradas `06_` a `10_`. Están
documentadas aparte, en `FIGURAS-unidad5.md`.

## Regenerar

```bash
bash figuras/sesion11/00_descarga_datos.sh          # una vez: TP53 y p53
for f in figuras/sesion11/0[1-5]_*.R; do Rscript "$f"; done
```

Los datos no se versionan (`datos/` está en `.gitignore`); sí los scripts, los
SVG y los `.tsv`. El `PROCEDENCIA.md` vive junto a los datos y lo reescribe el
script de descarga, igual que en las sesiones 3, 5 y 6.

| Script | Salida | En el `.qmd` |
|---|---|---|
| `01_flatfile.R` | `flatfile-anotado.svg` + `.tsv` | `@fig-flatfile`, en `ncbi.qmd` |
| `02_insdc_triangulo.R` | `insdc-triangulo.svg` | `@fig-insdc`, en `insdc.qmd` |
| `03_archivo_vs_curado.R` | `archivo-vs-curado.svg` | `@fig-archivo-curado`, en `insdc.qmd` |
| `04_niveles_pe.R` | `niveles-pe.svg` + `.tsv` | `@fig-pe`, en `uniprot.qmd` |
| `05_decodificador.R` | `decodificador.svg` + `.tsv` | `@fig-decodificador`, en `accesiones.qmd` |

## De dónde salen los números

Dos de las cinco afirman cantidades. Las otras tres son esquemas y no afirman
ninguna.

**`@fig-flatfile`** lee `datos/tp53.gb`, el registro real de `NM_000546.6`, y
no trae una sola línea transcrita. El script localiza las secciones por las
reglas del formato (palabras clave en la columna 1, qualifiers a 21 espacios),
no por número de línea, así que sobrevive a que el registro crezca. Si el NCBI
sube la versión, el `stopifnot` truena en vez de dibujar otra cosa en silencio.

El registro trae 705 líneas y a la figura entran 22: los dos cortes se marcan
con `⋮` y **dicen cuántas líneas se saltaron**, para que no parezca que el
registro es corto.

**`@fig-pe`** lleva la distribución de niveles PE en Swiss-Prot. La
especificación traía los cinco números con un `# VERIFICAR`; se verificaron
contra la API REST el **2026-08-07** y los cinco coinciden:

| | en el script | en la API |
|---|---|---|
| PE1 | 121,117 | 121,117 |
| PE2 | 54,492 | 54,492 |
| PE3 | 385,493 | 385,493 |
| PE4 | 12,672 | 12,672 |
| PE5 | 1,729 | 1,729 |
| **suma** | **575,503** | **575,503** (`reviewed:true`) |

Release `2026_02`, del 10 de junio de 2026. El script **comprueba que los cinco
sumen el total del release**: es lo que atrapa el error típico de actualizar
cuatro números y olvidar el quinto. También comprueba que PE3 redondee a 67 % y
PE1 a 21 %, que es lo que `uniprot.qmd` afirma en prosa — si los datos dejan de
sostener el texto, truena en vez de contradecirlo en silencio.

Cuando salga un release nuevo:

```bash
Rscript figuras/sesion11/04_niveles_pe.R --verificar
```

Sin la bandera no sale a internet, para que el render no dependa de la red.

## Decisiones que se ven raras y no lo son

**La pila de `@fig-archivo-curado` está desalineada a propósito.** Un archivo
primario no es "muchos registros", es muchos registros *ligeramente distintos*
del mismo objeto. Dibujados en una pila perfecta se leería "el archivo es
grande", que es la lectura equivocada; despatarrados se lee "el archivo es
redundante", que es la buena. Los desfases están **fijos, no son aleatorios**:
`estilo.R` garantiza que dos corridas den bytes idénticos y un `runif()`
rompería esa garantía y ensuciaría el diff al regenerar.

**La mitad de abajo de `@fig-insdc` ocupa casi tanto como el triángulo.** El
mito que el capítulo viene a matar ("RefSeq es parte del INSDC") no se corrige
dibujando bonito el triángulo, sino dándole a la excepción el mismo peso
visual que a la regla. El triángulo chico de dbGaP/EGA/JGA usa la misma
geometría que el grande a escala 0.30: son un espejo de acceso controlado, y la
figura lo dice con la forma antes que con el texto.

**Dos filas de `@fig-decodificador` van sin versión** (`X02469` y `P04637`),
tal como las lista la especificación. No es un olvido: es el contraste que hace
visible el naranja de las otras dos. Un accession de INSDC sí tiene versión
(`X02469.1`); acá se muestra la forma corta, que es la que van a encontrar
citada, y el capítulo se encarga de decir que citarla así es insuficiente.

## Lo que atraparon los `stopifnot`, y lo que no

Cada script comprueba su geometría antes de escribir: que nada se salga del
panel, que las columnas no se encimen, que los despieces rearmen el original.
`05_decodificador.R` además verifica **las reglas que enseña el capítulo**: que
sólo las filas de RefSeq lleven guión bajo, y que sean exactamente esas las que
traen versión.

Tres cosas se escaparon a los `stopifnot` de la primera versión y se vieron
sólo al mirar los PNG. Vale la pena anotarlas porque las tres eran del mismo
tipo — **comprobar el ancho y olvidar el alto**:

1. En `@fig-flatfile`, los rótulos de LOCUS, DEFINITION, ACCESSION y VERSION se
   encimaban: cada uno marca **una** línea del registro (3.5 mm) pero ocupa
   **dos** de texto (~6 mm). Ahora hay un paso de anti-colisión que los empuja
   hacia abajo y dibuja un conector punteado cuando se movieron, más una
   comprobación de solapamiento vertical.
2. En `@fig-archivo-curado`, el rótulo de la segunda fila caía encima de la
   línea de la proporción. Los `stopifnot` medían las pilas, no los rótulos.
3. En `@fig-pe`, la etiqueta de la barra del PE3 salía cortada
   (`385,493  (67.0 %` sin cerrar el paréntesis) porque `expansion(mult = e)`
   **no es una fracción del panel sino del rango de datos**. El aire correcto
   es `e >= L / (ANCHO_PANEL - L)`; con la fórmula mala daba 0.22 y hacen falta
   0.40. Ahora se calcula y se comprueba.

Moraleja para la siguiente sesión de figuras: un `stopifnot` de ancho no
sustituye a mirar el PNG, y conviene añadir la comprobación de alto en cuanto
una figura lleve rótulos de varias líneas.

## Pendiente

- ~~Las figuras de la **Unidad 5**~~ ya están: `06_` a `10_`, documentadas en
  `FIGURAS-unidad5.md`.
- `ncbi.qmd` cita **GenBank release 269.0** (dic 2025). El release vigente al
  2026-08-07 es el **272.0** (jun 2026), con 6,255,423,204 secuencias y
  50,068,290,456,326 bases en los registros WGS/TSA/TLS — o sea ~50.07 billones
  de bases, no 49.73. No se cambió la prosa porque las instrucciones pedían
  reportarlo, no reescribirlo; queda como decisión del capítulo.
