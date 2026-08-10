# Figuras de la Sesión 7 — Algoritmos: Needleman–Wunsch y Smith–Waterman

Para `contenido/03-alineamientos/algoritmos.qmd`. Reglas de siempre: R con
ggplot2 y **svglite**, texto como texto, fondo transparente, y el caption de la
figura en el `.qmd`, no dentro del SVG.

Las otras figuras de este capítulo (`fig01_reticula` … `fig07_gotoh`) son las
viejas, en Python, y viven en `figuras/svg/`. Las dos paletas son la misma
(`estilo.py` y `estilo.R` comparten hex), así que conviven sin desentonar.

## Aviso de licencia

La **idea** del turista de Manhattan viene de Compeau y Pevzner,
*Bioinformatics Algorithms*, que es *All Rights Reserved*. Las ideas se reusan
citando; **sus figuras no**. Esta se dibuja desde cero: pesos propios,
geometría propia, y los números que anota los calcula el script.

## Regenerar

```bash
Rscript figuras/sesion07/01_manhattan_tourist.R
```

| Script | Salida | En el `.qmd` |
|---|---|---|
| `01_manhattan_tourist.R` | `manhattan-tourist.svg` + `.tsv` | `@fig-manhattan-dp`, **insertada** en "Cómo encontrar la longitud del camino más largo en Manhattan con programación dinámica" |

## Los números que la figura afirma

La cuadrícula es de **3 × 4 cuadras** a propósito, no cuadrada como la de la
sesión 6: el punto de la figura es que `Derecha` (4 × 4), `Abajo` (3 × 5) y
`s` (4 × 5) tienen dimensiones **distintas entre sí**, que es justo donde se
atoran al programarlo.

Con esos pesos:

| | |
|---|---|
| caminos de (0,0) a (3,4) | C(7,3) = **35** |
| camino más largo | **29** atracciones |
| movimientos | `AADDDAD` (A abajo, D derecha) |

`s[i,j]` completa:

|       | j=0 | j=1 | j=2 | j=3 | j=4 |
|-------|----:|----:|----:|----:|----:|
| **i=0** | 0 | 3 | 3 | 5 | 9 |
| **i=1** | 2 | 7 | 10 | 11 | 13 |
| **i=2** | 8 | 10 | 16 | 20 | 20 |
| **i=3** | 11 | 12 | 16 | 26 | 29 |

**Cómo se comprueba.** El script llena `s` con la recurrencia y **además** la
recalcula por fuerza bruta, celda por celda, tomando el máximo sobre todos los
caminos que llegan a cada nodo. Un `stopifnot` exige que las dos tablas sean
iguales, que el camino dibujado sea legal (sólo pasos al sur y al este, de
(0,0) a (n,m)) y que su peso dé exactamente `s[n,m]`. Si alguien cambia un
peso, el script truena en vez de publicar una figura que afirme algo falso.
Misma regla que `02_manhattan.R` de la sesión 6.

Los pesos, la tabla y el camino quedan en `manhattan-tourist.tsv`.

## Decisiones que conviene no "limpiar"

**Los títulos A/B/C/D sí van dentro del SVG.** La regla del repo es que el
título de la *figura* vive en el `.qmd`; estas son etiquetas de panel, y el
caption las cita ("**A**, la cuadrícula…"). Sacarlas dejaría cuatro dibujos
sueltos sin manera de referirse a ellos.

**Las aristas se acortan `RE` antes de cada nodo.** Si llegan hasta el centro,
la punta de flecha queda debajo del círculo blanco, que se dibuja encima, y la
figura pierde justo lo que quiere decir: que el turista sólo camina en dos
direcciones.

**El camino del panel D es una polilínea, no segmentos sueltos.** Partido en
aristas se ve entrecortado en cada nodo, y lo que se resalta es que es un solo
recorrido.

**El camino óptimo no es único de dibujar.** `camino_optimo()` reconstruye
hacia atrás desde (n,m) y en los empates se queda con el paso a la derecha. Da
igual cuál elija: el `stopifnot` comprueba que pese `s[n,m]`, que es lo que la
figura afirma.
