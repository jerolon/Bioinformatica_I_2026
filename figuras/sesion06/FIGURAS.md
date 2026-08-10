# Figuras de la Sesión 6 — Alineamiento de secuencias por pares

Cinco figuras para `contenido/03-alineamientos/alineamiento-por-pares.qmd`.
Reglas de siempre: R con ggplot2 y **svglite**, sin título dentro del SVG,
texto como texto (`svg.fonttype = "none"`), fondo transparente.

## Aviso de licencia

Las **ideas** de este capítulo (Hamming, la LCS, el turista de Manhattan, el
grafo de alineamiento) vienen de Compeau y Pevzner, *Bioinformatics
Algorithms*, que es *All Rights Reserved*. Las ideas se reusan citando; **sus
figuras no**.

Las cinco figuras de esta carpeta se dibujan desde cero, con datos y
geometrías propias:

- los pesos de la cuadrícula de Manhattan se diseñaron acá y se verifican acá
  (`02_manhattan.R` calcula la ruta voraz y la óptima y truena si la voraz no
  pierde por al menos 30 %);
- el camino de `@fig-grafo` es uno elegido acá, sobre secuencias elegidas acá,
  y el alineamiento de abajo se **deriva** del camino en el script;
- la curva de `@fig-explosion` se calcula con `lgamma`.

Nada está calcado ni "basado visualmente" en sus diapositivas. Si algún día se
rehace una figura, esa regla se mantiene.

## Regenerar

```bash
for f in figuras/sesion06/0[1-5]_*.R; do Rscript "$f"; done
bash figuras/sesion06/06_preparar_datos.sh          # datos de la práctica
```

Los `.fa`/`.fasta` no se versionan (`datos/` está en `.gitignore`); sí los
scripts, los SVG y los `.tsv`. El `PROCEDENCIA.md` vive junto a los datos y lo
reescribe el script, igual que en las sesiones 3 y 5.

| Script | Salida | En el `.qmd` |
|---|---|---|
| `01_hamming.R` | `hamming.svg` | `@fig-hamming`, ya estaba referenciada |
| `02_manhattan.R` | `manhattan.svg` + `.tsv` | `@fig-manhattan`, ya estaba |
| `03_grafo_alineamiento.R` | `grafo-alineamiento.svg` | `@fig-grafo`, ya estaba |
| `04_explosion.R` | `explosion.svg` + `.tsv` | `@fig-explosion`, ya estaba |
| `05_tipos.R` | `tipos-alineamiento.svg` | `@fig-tipos`, **insertada** en "Global, local, semiglobal" |
| `06_preparar_datos.sh` | siete FASTA + `PROCEDENCIA.md` | la práctica |

## Los números que la figura afirma

### Figura 2 — la voraz sí pierde, por 56.5 %

Pesos propios, elegidos para que la voraz pierda y **verificados por código**
(`02_manhattan.R` no publica sin comprobarlo):

| | movimientos | total |
|---|---|---|
| ruta voraz | `ESSSEE` | **23** |
| ruta óptima | `SSSEEE` | **36** |

Diferencia: **56.5 %**, muy por encima del 30 % que pedía la especificación. El
óptimo es **único** y el segundo mejor de los 20 caminos da 26, así que el 36
no es un empate afortunado. No hay empates en ninguna decisión voraz, o sea que
la ruta voraz no depende de cómo se desempate.

La historia: en `(0,0)` la voraz ve una cuadra de 6 al este contra una de 3 al
sur, se lleva la de 6 y cae en una columna pobre. Es exactamente lo que dice el
capítulo ("la voraz gana el primer paso y pierde el total").

Las dos rutas **comparten dos aristas** (el tramo final de la fila 3). Ahí se
dibujan separadas 1 mm, desplazando los vértices y no los segmentos, para que
la polilínea no quede con saltos. Los pesos, las dos rutas y sus totales están
en `manhattan.tsv`.

### Figura 4 — n = 11 da 705,432, y el renglón de n = 100 estaba mal

Con `log10 C(2n,n) = (lgamma(2n+1) - 2*lgamma(n+1)) / log(10)`:

| n | C(2n,n) | log10 | tabla del capítulo |
|---|---|---|---|
| 11 | **705,432** | 5.8485 | 705,432 — **cuadra** |
| 100 | 9.05 × 10⁵⁸ | 58.9569 | decía "más de 10⁶⁰" — **no cuadraba** |
| 300 | ≈ 10¹⁷⁹ | 179.1307 | 10¹⁷⁹ — **cuadra** |

El renglón de n = 100 se corrigió en el `.qmd` a "cerca de 10⁵⁹", porque la
figura anota ese punto y lo habría contradicho en la misma página. El argumento
no cambia: 10⁵⁹ sigue estando veinte órdenes de magnitud arriba de los átomos
del universo observable.

La curva pasa los 10⁸⁰ en **n = 136** (en n = 135 va en 10⁷⁹·⁹⁶).

**Segunda nota, que NO se tocó.** El capítulo dice que C(2n,n) cuenta "los
alineamientos donde los huecos nunca se emparejan con huecos". Esa cuenta no es
C(2n,n): son los números centrales de Delannoy, que para n = 11 dan
**45,046,719**, no 705,432. C(2n,n) es la cuenta clásica de los libros de texto
(la que da el 705,432 que el capítulo cita) y las dos explotan igual de rápido,
así que la moraleja se sostiene; pero la frase y el número no salen de la misma
fórmula. Se dejó como está: cambiar la exposición es decisión del autor.

## Decisiones que conviene no "limpiar"

**Las guías de la figura 3 salen inclinadas a propósito.** Conectan cada paso
del camino con su columna del alineamiento. Las columnas van a paso fijo porque
un alineamiento monoespaciado sólo se lee si son parejas, y los pasos del
camino no están igual de separados. La inclinación es la consecuencia, no un
error de colocación.

**La figura 1 marca las columnas con `|` y `×`, no con colores solamente.** El
contraste gris/verde es el argumento y tiene que verse desde el fondo del
salón, pero quien no distinga bien los colores todavía lee la marca.

**La figura 5 usa 400 y 50 residuos, no 422 y 60.** Es un esquema y sus
números son los de la prosa de esa sección del capítulo ("un dominio conservado
de 50 aminoácidos contra una proteína de 400"). Los archivos de la práctica sí
miden 422 y 60; son cosas distintas y no tienen por qué coincidir.

## Datos de la práctica

`06_preparar_datos.sh` los baja, los verifica y escribe el `PROCEDENCIA.md`.
Por omisión los deja en `figuras/sesion06/datos`; en `ken` se le pasa el destino:

```bash
bash figuras/sesion06/06_preparar_datos.sh /datos/cursos/bioinfo1/sesion06
```

| Archivo | Accession | Largo | Recorte |
|---|---|---|---|
| `protA.fasta` | P69905 HBA_HUMAN | 142 aa | completa |
| `protB.fasta` | Q6VN46 MYG_DANRE | 147 aa | completa |
| `larga.fasta` | P26367 PAX6_HUMAN | 422 aa | completa |
| `dominio.fasta` | O18381 PAX6_DROME | 60 aa | residuos 430-489 (Homeobox, UniProt) |
| `genomica.fasta` | NG_007084.2 APOE | 4,598 pb | posiciones 4515-9112 |
| `cdna.fasta` | NM_000041.4 APOE | 1,166 pb | completa |
| `repetida.fasta` | P07476 INVO_HUMAN | 585 aa | completa |

### El par de proteínas: dos requisitos, no uno

El requisito obvio era **~28 % de identidad** (zona crepuscular). El que costó
encontrar es el otro: que los **tres** esquemas del Ejercicio 3 den
alineamientos **distintos**. Casi ningún par de globinas al 28 % lo cumple —
BLOSUM45 devuelve exactamente el mismo alineamiento que BLOSUM62 y el ejercicio
se queda sin nada que comparar. Se barrieron 60 × 200 pares de globinas
revisadas de UniProt con `needle` hasta dar con uno.

Hemoglobina alfa humana contra mioglobina de pez cebra, medido con `needle`:

| esquema | largo | identidad | similitud | huecos | score |
|---|---|---|---|---|---|
| BLOSUM62, gapopen 10, gapextend 0.5 | 158 | **27.8 %** | 39.9 % | 17.1 % | 125.5 |
| BLOSUM45, gapopen 10, gapextend 0.5 | 156 | 28.2 % | 41.0 % | 14.7 % | 187.5 |
| BLOSUM62, gapopen 20, gapextend 1 | 153 | 26.1 % | 37.9 % | 11.1 % | 93.0 |

Los tres alineamientos son distintos entre sí (comparando los dos renglones
alineados, **no** la salida completa: la línea de consenso cambia sola al
cambiar de matriz y haría pasar por distintos a dos alineamientos idénticos).
Los huecos bajan 17.1 → 14.7 → 11.1 %, que es justo lo que el Ejercicio 3 pide
contar.

**Un desfase con la solución del `.qmd`.** Decía que BLOSUM45 "produce
alineamientos más largos con menos huecos". Con menos huecos el alineamiento es
más **corto**, no más largo (156 contra 158), así que la frase se contradecía
sola. Se cambió a "más compactos, con menos huecos".

### Ejercicio 4: el dominio sí está contenido

| programa | largo | identidad | huecos |
|---|---|---|---|
| `needle` | 422 | 12.8 % | 85.8 % |
| `water` | 60 | 90.0 % | 0.0 % |

El contraste que quiere el ejercicio, redondo. El dominio no se recorta de
`larga.fasta`: viene del ortólogo de *Drosophila*, con las coordenadas que
anota UniProt, así que la identidad es alta (90 %) pero no del 100 %.

Mide **60 aa**, no 50: es el largo canónico de un homeodominio y no tiene caso
mutilarlo. Se ajustaron las dos menciones de "unos 50" en el Ejercicio 4.

### Ejercicio 5: por qué APOE y no SOD1

`dottup` dibuja una caja con la proporción de las dos longitudes. El
RefSeqGene completo de APOE (10.6 kb contra 1.2 kb de cDNA) sale como una tira
de 12 a 1 con las cuatro diagonales apiñadas en el tercio central. Recortado al
gen con 500 pb de margen queda una caja de 4 a 1 donde los cuatro exones se
leen. Se probó también SOD1, que tiene cinco exones: su gen mide 9.3 kb contra
895 pb de cDNA y ni recortado baja de 11 a 1.

El script comprueba contra el GenBank que sean cuatro exones y que los cuatro
caigan dentro de la ventana del recorte.

**Otro desfase con la solución.** Decía "diagonales separadas por saltos
horizontales". `dottup` pone la `-asequence` (la genómica) en el eje **y**, así
que los intrones son saltos **verticales**. Comprobado sobre la imagen. Se
corrigió la palabra y se dijo de qué eje se trata.

### Ejercicio 6: el barajado separa bien

Con `shuffleseq -shuffle 100` sobre `protB` y `water` contra `protA`:

- los 100 scores nulos van de **24.0 a 70.5**;
- el score real es **132.0**.

Casi el doble del máximo de la distribución nula. Es el resultado que el
ejercicio necesita: "si de mil barajadas ninguna se le acerca, el resultado es
improbable por azar".
