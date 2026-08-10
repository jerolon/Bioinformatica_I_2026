# Figuras de la Sesión 5 — Formatos de secuencia: FASTA

Cinco figuras para `contenido/02-secuencias/formatos.qmd`. Reglas de siempre: R
con ggplot2 y **svglite**, sin título dentro del SVG, texto como texto, fondo
transparente.

## Regenerar

```bash
bash figuras/sesion05/00_datos.sh          # los seis genomas
bash figuras/sesion05/06_fabricar_rotos.sh # lambda.fa limpio, rotos/ y multi.fa
for f in figuras/sesion05/0[1-5]_*.R; do Rscript "$f"; done
```

`00_datos.sh` **copia de `datos/` en la raíz si ya están** (los bajó la sesión
01, son los mismos seis accessions) y sólo va al NCBI por lo que falte. Es el
mismo principio que el callout del capítulo: no volver a bajar seis archivos que
ya están en disco.

Los `.fa` no se versionan (`datos/` está en `.gitignore`); sí los scripts, los
SVG y los `.tsv`.

| Script | Salida | En el `.qmd` |
|---|---|---|
| `01_anatomia.R` | `fasta-anatomia.svg` + `.tsv` | `@fig-anatomia`, ya estaba |
| `02_encabezados.R` | `encabezados.svg` | `@fig-encabezados`, ya estaba |
| `03_gc_genomas.R` | `gc-genomas.svg` + `.tsv` | `@fig-gc-genomas`, ya estaba |
| `04_gc_ventanas.R` | `gc-ventanas.svg` + `.tsv` | `@fig-ventanas`, ya estaba |
| `05_linealizar.R` | `linealizar.svg` | `@fig-linealizar`, **insertada** en el Ej. 6 |

## Decisiones que conviene no "limpiar"

**La figura 1 no reutiliza la de la sesión 01.** La especificación decía que
había una parecida en la sesión 2; no la hay, está en `figuras/sesion01/`
(`01_fasta_anatomia.R`). Se revisó y no sirve tal cual: marca **un** salto de
línea (el de la primera línea de secuencia), no compara bytes contra bases, y es
la anatomía "de presentación". Ésta es la auditoría: un ¶ al final de **cada**
línea y el remate `wc -c` contra bases. Las dos pueden convivir.

**La figura 2 no lleva una recta vertical.** La especificación pedía "una línea
vertical punteada que cruza los cinco encabezados marcando dónde cae el primer
espacio". Es imposible y falso: el primer espacio cae en la columna 13, 22 y 19
en tres de ellos, y **en dos no existe**.

```
>NC_001416.1 ...                  columna 13
>sp|P01013|OVAX_CHICK ...         columna 22
>gi|129295|sp|P01013|OVAX_CHICK   sin espacio
>ENST00000456328.2 cdna ...       columna 19
>mi_secuencia_favorita            sin espacio
```

Se dibuja una marca por encabezado en su propia columna, unidas por una
polilínea punteada **que se ve quebrada**: la quebradura es el mensaje. Los dos
sin espacio llevan marca discontinua y la nota "◄ sin espacio".

**El corte de la figura 4 está estimado, no puesto a ojo.** Es el que minimiza
la varianza dentro de cada mitad (un solo *change point*). Cae en **22 kb**, que
coincide con el ~22 kb que la especificación proponía. El script sólo dibuja las
bandas si la diferencia supera 5 puntos y p < 1e-4; si algún día deja de
cumplirse, las quita y avisa.

## Los números

### Los seis genomas — todos cuadran

| Organismo | Accession | Longitud | GC |
|---|---|---|---|
| *Mycoplasma genitalium* | NC_000908.2 | 580,076 | 31.69 % |
| SARS-CoV-2 | NC_045512.2 | 29,903 | 37.97 % |
| Levadura, cromosoma I | NC_001133.9 | 230,218 | 39.27 % |
| Fago phiX174 | NC_001422.1 | 5,386 | 44.76 % |
| Fago lambda | NC_001416.1 | 48,502 | 49.86 % |
| *E. coli* K-12 | NC_000913.3 | 4,641,652 | 50.79 % |

Las seis longitudes coinciden con la tabla del Ejercicio 9, y los cuatro GC que
cita la solución (31.7, 38.0, 49.9, 50.8) también. Ninguno viene soft-masked.

### El punto de cambio de lambda

Ventana 22 → **22 kb**. Izquierda 56.73 %, derecha 44.18 %: **12.55 puntos**,
t = 10.6, p = 1.2e-12, R² = 0.685. El promedio global (49.86 %) cae entre las dos
medias y no describe a ninguna, que es el argumento del Ejercicio 10.

### El ancho de plegado: 70, no 60

**El archivo que devuelve `efetch` viene a 70 caracteres por línea**, no a 60.
Eso arrastra dos números del capítulo:

| | capítulo | real (efetch, 70/línea) | sería con 60/línea |
|---|---|---|---|
| `wc -l` | ~809 | 694 | 810 |
| `wc -c` | ~49,365 | 49,253 | 49,369 |

Los del capítulo corresponden a un archivo a 60 por línea, que es lo que da la
descarga por web del NCBI ("Send to → File → FASTA"). Las bases (48,502) son las
mismas en los dos, que es justamente lo que el Ejercicio 1 quiere enseñar.

La figura 1 **mide** el ancho del archivo y lo dice en el pie, en vez de
transcribir el número, para que no pueda contradecir al archivo que tenga
enfrente. Ver también la nota de abajo.

### Otros desfases con el texto

- **Encabezado de lambda.** El real es `>NC_001416.1 Enterobacteria phage
  lambda, complete genome`; el capítulo escribe `Escherichia virus Lambda`.
- **GC de lambda en el Ejercicio 11.** El capítulo dice `24198 de 48502`. El
  conteo real es **24,182**. (Ya estaba reportado desde la sesión 01: ver la
  nota en `figuras/sesion01/04_composicion.R`.) El porcentaje, 49.9 %, sí es
  correcto.

## Los cinco archivos rotos

`06_fabricar_rotos.sh` los genera y corre los diagnósticos del Ejercicio 5.

**Primero limpia el original**: el FASTA de `efetch` **termina con una línea en
blanco**, y eso rompía dos de los cinco — roto3 salía con dos blancas en vez de
una, y roto4 truncaba justamente la blanca y quedaba bien formado. Todo se
deriva de `lambda.fa`, la copia sin blancas finales, que es también el archivo
"sano" de los ejercicios 1 a 4.

| Archivo | Qué tiene | Diagnóstico que lo delata | Confirmado |
|---|---|---|---|
| sano `lambda.fa` | nada | 694 líneas, 49,253 B, 0 blancas, termina en `0a` | referencia |
| `roto1.fa` | CRLF | `file` → *with CRLF line terminators*; 694 bytes `0d`; `wc -c` +694 | sí |
| `roto2.fa` | ids repetidos | `grep '^>' \| sort \| uniq -d` lo muestra; 2 registros | sí |
| `roto3.fa` | 1 blanca a media secuencia | `grep -c '^$'` → 1 (el sano da 0) | sí |
| `roto4.fa` | sin `\n` final | `tail -c1 \| od` → `47` (una `G`), no `0a` | sí |
| `roto5.fa` | soft-masked, 2,100 pb | `tr -cd 'acgt' \| wc -c` → 2,100 | sí |

El de roto5 es el más instructivo: **GC bien contado 49.86 %, contando sólo
mayúsculas 47.52 %**. Dos puntos y medio de error, sin ningún mensaje.

**Caveat de plataforma.** En Git Bash sobre Windows, `grep` trata `\r\n` como fin
de línea y se come el `\r`, así que el conteo de bases de roto1 **no** se infla
al verificar aquí. En Linux (`ken`, que es donde corren los alumnos) sí se
infla. Por eso el script cuenta los `0d` con `od`, que no interpreta nada. La
solución del capítulo para el archivo 1 es correcta.
