# Figuras de la Sesión 3 — Código genético

Cinco figuras para `contenido/02-secuencias/codigo-genetico.qmd`. Mismas reglas
que las sesiones anteriores: R con ggplot2 y **svglite**, sin título dentro del
SVG (el caption vive en el `.qmd`), texto como texto para poder editarlo en
CorelDRAW, fondo transparente, etiquetas en español.

**La tabla de codones no está tecleada en ninguna parte.** Sale de
`Biostrings::getGeneticCode()`, que a su vez viene de las tablas del NCBI.
`_codigo.R` la envuelve y le pega las clases químicas, que sí son una decisión
pedagógica y por eso sí están escritas a mano. `_tema.R` es el adaptador de
paleta, gemelo del de `sesion02/`.

## Regenerar

```bash
bash figuras/sesion03/00_descarga_datos.sh    # sólo para la figura 4
for f in figuras/sesion03/0[1-5]_*.R; do Rscript "$f"; done
```

Los cinco SVG salen **byte a byte idénticos** al regenerar (comprobado). La
figura 5 remuestrea 20 000 códigos barajados, y por eso lleva `set.seed()`: sin
semilla fija el pie cambiaría de decimal en cada corrida y ensuciaría el diff.

## Las cinco

| Script | Salida | Qué es | Datos |
|---|---|---|---|
| `01_tabla_codones.R` | `tabla-codones.svg` + `.tsv` | Los 64 codones coloreados por clase química. | tabla 1 del NCBI |
| `02_degeneracion.R` | `degeneracion.svg` + `.tsv` | Codones por aminoácido. | tabla 1 |
| `03_estandar_vs_mito.R` | `estandar-vs-mito.svg` + `.tsv` | Tabla 1 contra tabla 2, las cuatro casillas que cambian. | tablas 1 y 2 |
| `04_uso_codones.R` | `uso-codones.svg` + `.tsv` | RSCU en tres genomas de GC contrastante. | RefSeq (ver abajo) |
| `05_grafo_mutaciones.R` | `grafo-mutaciones.svg` + `.tsv` | Aminoácidos a una mutación de distancia. | tabla 1 |

Todas se dibujan en **milímetros** con `theme_void()` salvo la 2, que es una
gráfica de barras normal: 1 unidad = 1 mm, igual que el `size` de `geom_text`,
así que los anchos de texto se comparan contra los huecos. Cada script cierra
con `stopifnot()` que comprueba lo que la figura afirma y que nada se encima ni
se sale del panel.

## Decisiones de diseño que conviene no "limpiar"

**Figura 1, disposición.** La especificación pedía probar `facet_wrap(~ b3)` o
sub-columnas. Se probaron las dos. `facet_wrap` parte la tabla en cuatro paneles
de 4×4 y rompe el bloque de color justo en la dirección en que hay que leerlo.
Queda la disposición clásica: 16 filas (primera base afuera, tercera adentro) ×
4 columnas (segunda base). Con eso la columna de la U mide 16 celdas y se ve de
un golpe que es 100 % hidrofóbica.

**Figura 3, sin líneas guía.** Tres de las cuatro casillas que cambian viven en
la última columna y su guía sale corta; AUA está en la primera y la suya cruza
la tabla entera en diagonal. Con guías en tres de cuatro la figura se ve
inconsistente, con las cuatro se ve sucia, y no hacen falta: cuatro casillas
naranjas contra sesenta grises no cuestan trabajo de encontrar.

**Figura 5, sectores y no Fruchterman-Reingold.** Se probó `fr` y da una maraña,
y hay una razón medible: el grafo tiene 75 de 190 aristas posibles (39 % de
densidad) y la modularidad de las clases químicas sobre él es 0.064, o sea casi
nula. Con sectores por clase, las aristas intra-clase son cuerdas cortas pegadas
al borde y las inter-clase cruzan el centro, así que la proporción se lee sola.
`ggraph` no está instalado y no se agregó: igraph construye el grafo y mide, y
el dibujo va en ggplot2 sobre coordenadas en milímetros.

**`MORADO` es nuevo en la paleta.** La escala por clase química necesita seis
niveles y con los cuatro colores del libro el par ácido/básico —que es el
contraste que importa— quedaba en el mismo tono. Se agregó a `figuras/estilo.R`
y a `figuras/estilo.py` (su gemelo), con la nota correspondiente.

## Los datos de la figura 4

La especificación pedía **CoCoPUTs o HIVE-CUTs**, y explícitamente **no Kazusa**
(que el capítulo critica por nombre en un callout entero: congelada en 2007).

Al 5 de agosto de 2026 **CoCoPUTs y HIVE-CUTs son el mismo servicio y está
caído**: `dnahive.fda.gov` resuelve (150.148.26.122) pero no acepta conexiones
HTTPS, y `hive.biochemistry.gwu.edu/review/codon2` sólo redirige ahí. Consultado
con el autor, se optó por **calcular el RSCU de cero a partir de los CDS de
RefSeq**, que para lo que el capítulo enseña sale mejor que cualquier tabla
precalculada: queda anclado a un accession y una fecha, y se regenera con un
comando. La queja contra Kazusa es justamente que no dice cuándo se actualizó.

| Organismo | Assembly | CDS usados | GC (CDS) | GC en 3ª posición |
|---|---|---|---|---|
| *Plasmodium falciparum* 3D7 | `GCF_000002765.6` | 5,185 de 5,354 | 23.7 % | 17.4 % |
| *Escherichia coli* K-12 MG1655 | `GCF_000005845.2` | 3,796 de 4,318 | 52.0 % | 56.3 % |
| *Streptomyces coelicolor* A3(2) | `GCF_000203835.1` | 7,447 de 8,188 | 72.4 % | 93.3 % |

Descargados el 2026-08-05. Filtro: largo múltiplo de 3, ≥ 300 nt, sin códigos de
ambigüedad. Correlación GC(CDS) ~ GC3: **r = 0.997**, que es el punto de la
figura.

Los `.fna.gz` **no se versionan** (`datos/` está en `.gitignore`); se versionan
el script de descarga, el `.R`, el `.tsv` de resultados y
`datos/PROCEDENCIA.tsv`.

**Ojo con el %GC anotado bajo cada columna: es el de los CDS, no el del genoma
completo.** En *P. falciparum* la diferencia es grande (los CDS son bastante
menos AT-ricos que el resto del genoma), y por eso la figura marca 24 % donde la
cifra que se cita de memoria para ese genoma es ~19 %. El pie de la figura lo
advierte.

## Cotejo contra el capítulo

Todo esto lo comprueban los `stopifnot()` de los scripts, salvo donde se indica.

| Afirmación del capítulo | Calculado | ¿Cuadra? |
|---|---|---|
| 3 aa con seis codones (Leu, Ser, Arg) | L, R, S | sí |
| 5 aa con cuatro; 1 con tres (Ile); 9 con dos; 2 con uno (Met, Trp) | idéntico | sí |
| "En ocho de las dieciséis cajas" la 3ª base da igual | 8 de 16 | sí |
| Tabla 2: cuatro codones cambian (UGA, AGA, AGG, AUA) | exactamente 4 | sí |
| P(paro) ≈ 0.047; ~21 codones entre paros | 0.0469; 21.3 | sí |
| Ejercicio 1: +1 → `MAPEWYR` y paro; +2 → `WHLNGTA` y sobran 2 bases | idéntico | sí |
| Ejercicio 2: tabla 2 → 16 residuos; tabla 1 → 15 y corta | idéntico; difieren en las posiciones 10 y 16 | sí |
| "el 6 % de ella" (15 de 261) | 5.7 % | sí |
| Ejercicio 3: vecinos de GAA | K, Q, paro / A, G, V / D, D, E | sí |
| Conexiones "preferentemente dentro de cada clase" | 29 % por arista, 34 % por camino | **no, se corrigió** |
| *E. coli*: 83 % AUG, 14 % GUG, 3 % UUG | 90.2 / 7.8 / 1.9 en `GCF_000005845.2` | **no, sin resolver** |

### Los dos que no cuadraban

**El grafo (figura 5).** "Preferentemente dentro de cada clase" se lee como *la
mayoría*, y son un tercio: el pie de la figura habría contradicho al párrafo que
tiene encima. Pero el sesgo existe y es fuerte en términos estadísticos. Contra
el nulo de Freeland & Hurst (barajar qué aminoácido va en cada bloque de
sinónimos, conservando la estructura del código, 20 000 permutaciones):

```
fracción intra-clase, código real     33.7 %   (por camino mutacional)
                                      29.3 %   (por arista única)
esperado por tamaño de las clases     22.6 %
nulo de códigos barajados             22.6 %  (DE 4.7)
P(nulo >= real) = 0.0154   ->  supera al 98.5 % de los códigos
```

El párrafo del capítulo se reescribió para decir eso, y el pie de la figura lleva
la comparación en vez del porcentaje suelto.

**Los codones de inicio de *E. coli*.** El 83/14/3 del capítulo es la cifra
clásica, de anotaciones viejas. Contando los primeros tres nucleótidos de los
4,317 CDS completos de `GCF_000005845.2` sale **90.2 % AUG, 7.8 % GUG, 1.9 %
UUG**, y entonces "uno de cada seis genes no empieza con AUG" pasa a ser uno de
cada diez. No se tocó: ninguna figura lo grafica, las dos cifras son defendibles
según de qué anotación se hable, y elegir es del autor.
