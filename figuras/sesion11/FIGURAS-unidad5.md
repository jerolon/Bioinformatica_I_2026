# Figuras de la Unidad 5 — Browsers (Sesión 11)

Cinco figuras para los cinco capítulos de `contenido/05-browsers/`. Comparten
carpeta, `_tema.R` y script de datos con las de la Unidad 4: las dos unidades
son **la misma sesión de cinco horas**.

Reglas de siempre: R con ggplot2 y **svglite**, `source("_tema.R")`, sin título
dentro del SVG (el caption vive en el `.qmd`), `svg.fonttype = "none"`, fondo
transparente.

## Regenerar

```bash
for f in figuras/sesion11/0[6-9]_*.R figuras/sesion11/10_*.R; do Rscript "$f"; done
```

| Script | Salida | En el `.qmd` |
|---|---|---|
| `06_tres_ensamblados.R` | `tp53-tres-ensamblados.svg` + `.tsv` | `@fig-tres-ensamblados`, en `ensamblados.qmd` |
| `07_nomenclatura.R` | `nomenclatura.svg` | `@fig-nomenclatura`, en `ensamblados.qmd` |
| `08_liftover.R` | `liftover.svg` | `@fig-liftover`, en `ensamblados.qmd` |
| `09_tracks.R` | `tracks.svg` | `@fig-tracks`, en `ucsc.qmd` |
| `10_ucsc_vs_ensembl.R` | `ucsc-vs-ensembl.svg` + `.tsv` | `@fig-ucsc-ensembl`, en `ensembl.qmd` |

Hay una sexta referencia que **no genera figura nueva**:
`formatos-de-anotacion.qmd` reusa `figuras/sesion02/coordenadas.svg` como
`@fig-coordenadas`, tal como pedía la especificación. La sesión 2 ya enseñó la
trampa de 0-based contra 1-based con figura y ejercicio; acá sólo se recuerda.

## De dónde salen los números

Sólo `@fig-tres-ensamblados` afirma cantidades. Las otras cuatro son esquemas.

Las tres coordenadas de TP53 se **verificaron el 2026-08-07** y las tres
coinciden con la tabla de `ensamblados.qmd`:

| Ensamblado | Coordenadas | Fuente de la verificación |
|---|---|---|
| GRCh37 / hg19 | 7,571,739 - 7,590,808 | API de UCSC, `ncbiRefSeqCurated` sobre hg19 |
| GRCh38 / hg38 | 7,668,421 - 7,687,490 | NCBI Datasets, gene 7157 |
| T2T-CHM13v2.0 | 7,572,544 - 7,591,594 | NCBI Datasets, gene 7157 |

El dato de hg19 sale de tomar el mínimo `txStart` y el máximo `txEnd` de los 26
transcritos de TP53, que da `7571738-7590808` en BED 0-based, o sea
`7,571,739-7,590,808` en 1-based. De paso eso **confirma el ejemplo de
`ucsc.qmd`**, donde la API pide `start=7668420` para un gen que empieza en
7,668,421.

**Ojo con Ensembl.** `ENSG00000141510` da un tramo distinto: en GRCh38,
`17:7,661,779-7,687,546`. No es un error de nadie: son dos modelos de genes
sobre el mismo genoma, y RefSeq y Ensembl no coinciden. El capítulo de Ensembl
lo dice; la figura usa el modelo de RefSeq porque la tabla del capítulo cita
accessions `NC_`, que son del NCBI.

El script comprueba que el gen mida ~19 kb en los tres ensamblados y que el
salto hg19 → hg38 pase de 90 kb. Si alguien teclea mal una coordenada, truena.

## Decisiones que se ven raras y no lo son

**Las tres barras de `@fig-tres-ensamblados` son la misma ventana y la misma
escala.** Es lo único que hace que la figura signifique algo: si cada barra
fuera su propio ensamblado reescalado, TP53 saldría en el mismo sitio en las
tres y la figura diría "es el mismo gen", que ya se sabe. Compartiendo ventana,
el gen sale **desplazado**, y las líneas punteadas que lo unen salen
inclinadas. Si salieran verticales, algo estaría mal — y hay un `stopifnot` que
lo comprueba.

**La caja de resultado de `@fig-nomenclatura` está vacía, sin X ni símbolo de
error.** Es el punto entero: un error que grita se corrige solo, y éste no
grita. Los dos archivos llevan además **las mismas coordenadas** (7668420 en
BED 0-based, 7668421 en GTF 1-based: la misma base); lo único que cambia es el
nombre del cromosoma. Si las coordenadas fueran distintas se podría pensar que
por eso no cruzan.

**`@fig-liftover` dibuja "mapea limpio" como primer destino, no un cuarto modo
de falla.** El caption del capítulo dice "solo el primero es el que la gente
espera", así que el primero tiene que ser el caso bueno. La prosa del capítulo,
en cambio, enumera cuatro *formas de perder* (no mapea, se parte, mapea a
varios lugares, se invierte). No es contradicción: la prosa cuenta pérdidas y
la figura cuenta destinos. **"Mapea a varios lugares" quedó fuera del dibujo
por espacio** y sólo vive en la prosa; si se quiere una quinta fila, cabe.

**Los datos de `@fig-tracks` son inventados y el eje no lleva números
absolutos.** Es un esquema de qué es un track, no una vista de TP53, y no debe
poder leerse como si lo fuera. Los valores de la señal están **fijos**, no
generados al azar, porque `estilo.R` garantiza que dos corridas den bytes
idénticos y un `runif()` rompería esa garantía.

**`@fig-ucsc-ensembl` no lleva capturas de pantalla.** Por licencia (no son
nuestras para redistribuir en un sitio público) y por vida útil (las interfaces
cambian cada año). Los iconos se dibujan con geometría en vez de con emoji o
una fuente de iconos: las dos alternativas se renderizan distinto en cada
máquina.

## Lo que atraparon los `stopifnot`, y lo que no

Tres defectos volvieron a escaparse a las comprobaciones y se vieron sólo en
el PNG. Es la misma moraleja que dejó la Unidad 4 — **medir el ancho y olvidar
lo demás** — con una variante nueva:

1. En `@fig-tres-ensamblados`, la barra de escala arrancaba en el borde
   izquierdo y se montaba encima del rótulo "misma ventana en las tres: …". El
   `stopifnot` medía que la escala no se saliera de la barra, no que no pisara
   el texto. Ahora la escala va pegada al extremo derecho y hay comprobación de
   los tres elementos del renglón.
2. En `@fig-liftover`, la rama de "se parte" que iba al segundo bloque lo hacía
   en línea recta y **atravesaba el primero**: se leía como una flecha clavada
   en una caja, no como una bifurcación. Ahora arquea por encima, y un
   `stopifnot` comprueba que todos los puntos de la curva que caen sobre el
   ancho del primer bloque estén por encima de él.
3. En `@fig-tracks`, las flechas de hebra estaban repartidas a ciegas por todo
   el gen y caían encima de los exones. Ahora se calculan sólo en los huecos
   entre exón y exón, que es donde las pone un browser de verdad, y hay
   comprobación de que ninguna cae dentro de una caja.

El defecto 2 además obligó a **sacar la geometría de dentro de `construir()`**:
estaba definida en el cuerpo de la función y los `stopifnot` no podían verla.
Las cinco figuras de esta unidad la declaran a nivel de módulo.

## Pendiente

- **`@fig-liftover` no dibuja el caso "mapea a varios lugares"**, que la prosa
  sí menciona. Cabe como quinta fila si se quiere cerrar la simetría.
- La práctica `contenido/05-browsers/sesion11-practica.qmd` **no se corrió de principio a fin**:
  necesita `bedtools`, `tabix`, `bgzip` y `liftOver`, que no están en esta
  máquina, y los datos genómicos pesados. Ver el reporte de verificaciones.
