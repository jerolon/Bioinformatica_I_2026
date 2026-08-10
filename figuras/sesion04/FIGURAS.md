# Figuras de la Sesión 4 — Matrices de sustitución

Cuatro figuras para `contenido/02-secuencias/matrices-de-sustitucion.qmd`.
Mismas reglas de siempre: R con ggplot2 y **svglite**, sin título dentro del SVG,
texto como texto, fondo transparente.

**Los 400 números de BLOSUM62 no se transcriben.** Salen de `data(BLOSUM62)` de
Biostrings. `_tema.R` sourcea `figuras/sesion03/_codigo.R` (no `estilo.R`
directamente) para reutilizar `clases_aa` y `colores_clase`, y sólo reapunta la
salida a `sesion04/`.

## Regenerar

```bash
for f in figuras/sesion04/0[1-4]_*.R; do Rscript "$f"; done
```

Dependencia nueva: el paquete **`grantham`** de CRAN, que instala sin problema
(`install.packages("grantham")`). Trae la tabla original de Grantham 1974 en
`grantham_distances_matrix`, así que **no hizo falta bajar ninguna tabla ni
guardar nada en `datos/`**.

Los cuatro SVG salen byte a byte idénticos al regenerar.

## Las cuatro

| Script | Salida | Qué es | En el `.qmd` |
|---|---|---|---|
| `01_blosum_grantham.R` | `blosum-grantham.svg` + `.tsv` | BLOSUM62 contra distancia de Grantham, 190 pares. | `@fig-grantham`, ya estaba |
| `02_blosum_heatmap.R` | `blosum62-heatmap.svg` | La matriz completa ordenada por química. | `@fig-matriz`, **insertada** |
| `03_direccion.R` | `direccion-numeracion.svg` | PAM y BLOSUM numeran al revés. | `@fig-direccion`, **insertada** |
| `04_entropia.R` | `entropia-matrices.svg` + `.tsv` | Entropía relativa y longitud mínima. | `@fig-entropia`, **insertada** |

## La trampa de la J

`setdiff(rownames(BLOSUM62), c("B","Z","X","*"))` **no da 20, da 21.** La matriz
de Biostrings incluye además **J** (Xle, "Leu o Ile"), que es un código de
ambigüedad como B y Z, no un aminoácido. Si se cuela:

- los "190 pares" pasan a ser 210 y la correlación cambia;
- la diagonal deja de ir de +4 a +11, porque J/J vale +3, y el capítulo (y el
  Ejercicio 5) dirían algo falso.

`_tema.R` define `AMBIGUOS <- c("B","Z","X","J","*")` y `aminoacidos_canonicos()`
para que no vuelva a pasar; los `stopifnot` de las figuras 1 y 2 lo comprueban.

## Decisiones que conviene no "limpiar"

**Figura 1, 190 pares y no 210.** Se excluye la diagonal. Una identidad no es
una sustitución, y Grantham vale 0 para las veinte, así que incluirlas mete un
grumo de puntos en x = 0 con y alta que infla la correlación sin agregar
información. Ahí está buena parte de la diferencia con el −0.72 que citaba el
capítulo (ver abajo).

**Figura 2, dos agrupaciones que no coinciden.** El ORDEN de filas y columnas es
el estructural que pedía la especificación (`I V L F M W Y C | A G P S T | N Q H
| K R | D E`), que es el que hace salir los bloques. La FRANJA DE COLOR de los
márgenes usa `clases_aa` de la sesión 3, también como pedía la especificación.
No son la misma agrupación: Y es "polar" en la sesión 3 y cae en el bloque
alifático-aromático; C y G son "especiales" y quedan repartidos; H es "básico" y
cae con N y Q. Se dejó así porque la discrepancia es real e informativa —qué tan
parecidos son dos aminoácidos depende de qué propiedad se mire— y los bloques
salen igual.

**Figura 3, escala cualitativa.** Las cuatro posiciones están repartidas parejo,
no espaciadas por valor de PAM ni por entropía: las equivalencias entre las dos
series son aproximadas y espaciarlas fingiría precisión. Las dos flechas
naranjas en sentidos opuestos **son** la figura; si alguien las pone en el mismo
sentido, deja de decir lo único que tiene que decir.

**Figura 4, entropías publicadas y no recalculadas.** Ver abajo.

## Los números

### Figura 1 — la correlación

**Pearson r = −0.6614** sobre los 190 pares distintos (Spearman −0.6889,
R² = 0.44). El capítulo decía −0.72.

La especificación pedía parar si no salía cerca de −0.7. Sale −0.66, que
redondea a −0.7 pero no es −0.72, así que se investigó de dónde puede venir esa
cifra:

| convención | r |
|---|---|
| **190 pares distintos, BLOSUM62** (lo que pedía la especificación) | **−0.6614** |
| incluyendo las 20 identidades (210 pares) | −0.7456 |
| 171 pares, quitando cisteína | −0.7434 |
| 190 pares, contra BLOSUM50 | −0.7170 |
| 190 pares, contra PAM250 | −0.7198 |

O sea que −0.72 es plausible con varias convenciones, pero no con la que define
la figura. Se corrigió el capítulo a −0.66 y se le agregó un párrafo con esta
tabla en corto, porque la lección —el coeficiente depende de qué se cuente, y
hay que decir qué se contó— es mejor que el número.

El script aborta si la correlación se sale de (−0.80, −0.55), para que un cambio
en Biostrings o en el paquete `grantham` no pase inadvertido.

### Figura 4 — por qué las entropías no se recalculan

Son los valores del NCBI (parámetros de `blastp`), los mismos que cita la tabla
del capítulo. Recalcularlas desde la matriz es posible pero da peor:

La entropía relativa es `H = Σ q_ij S_ij`, y las `q_ij` no vienen con la matriz.
Se pueden reconstruir resolviendo λ en `Σ p_i p_j exp(λ S_ij) = 1` y poniendo
`q_ij = p_i p_j exp(λ S_ij)`, pero eso exige elegir un vector de fondo `p_i` y
usar los scores **ya redondeados a enteros**. Con las frecuencias de Robinson &
Robinson (1991) que usa BLAST:

| matriz | λ reconstruido | λ NCBI | H reconstruida | H NCBI |
|---|---|---|---|---|
| BLOSUM45 | 0.2291 | 0.2291 | 0.363 | 0.3795 |
| BLOSUM62 | 0.3176 | 0.3176 | 0.579 | 0.6979 |
| BLOSUM80 | 0.3430 | 0.3430 | 0.948 | 0.9868 |

**λ cae exacto en las tres**, o sea que el montaje de Karlin & Altschul está bien
implementado; la H se queda corta entre 0.02 y 0.12 bits porque el redondeo y el
vector de fondo no son los originales de los Henikoff. Publicar esa H sería dar
una peor estimación de la misma cantidad. Así que se usan las cifras del NCBI y
la reconstrucción de λ queda como **verificación que corre en cada
regeneración** (`lambda_verificado()`), con un `stopifnot` que exige que cuadre
a menos de 0.005.

Biostrings no trae BLOSUM90, así que ésa no se puede verificar.

## Cotejo contra el capítulo

| Afirmación | Real | ¿Cuadra? |
|---|---|---|
| L/I = +2, L/D = −4, W/W = +11 (Ejercicio 5) | +2, −4, +11 | sí |
| L/L = +4, S/T = +1, P/P = +7, A/E = −1, D/E = +2, K/K = +5 | idénticos | sí |
| Ejercicio 2: total **+18** | +18 | sí |
| K/E = +1, A/L = −1 (tabla de Eddy) | +1, −1 | sí |
| "la diagonal va de +4 a +11" | +4 (A,I,L,S,V) a +11 (W) | sí |
| "de los 190 pares, solo 75 se alcanzan con una mutación; el 39%" | 75/190 = 39.5% | sí |
| BLOSUM45 → "al menos 130 residuos" para 50 bits | 131.8 | sí |
| Entropías 1.2 / 0.99 / 0.70 / 0.38 | 1.1806 / 0.9868 / 0.6979 / 0.3795 | sí |
| r ≈ **−0.72** | −0.6614 sobre 190 pares | **no, se corrigió** |

Los once valores de BLOSUM62 que cita el texto están todos bien. El único número
que no cuadraba era la correlación.
