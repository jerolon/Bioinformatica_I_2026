# Las figuras del curso

Casi todas las figuras del sitio se **calculan**: cada SVG sale de un script de
Python o de R versionado junto al resultado. **El script es la fuente de
verdad; el SVG es lo que Quarto embebe.** El render del libro nunca ejecuta
estos scripts (por eso `freeze: auto`, y por eso el sitio compila en CI sin R
ni Python): se versionan los dos, el script y el `.svg`.

La regla de correspondencia es simple: **el SVG se llama como su script**.
`svg/blast_mapq.svg` sale de `blast_mapq.R`; `svg/fig02_nw_matriz.svg` sale de
`fig02_nw_matriz.py`.

## El mapa

| Carpeta | Figuras de |
|---|---|
| raíz (`*.py`, `*.R`) | Sesiones 7–9 (algoritmos, BLAST, MSA) y el ecosistema NCBI; salida en `svg/` y `ncbi/` |
| `sesion01/` | Sesión 1 — Qué es la bioinformática |
| `sesion02/` | Sesiones 2–3 — Tipos de secuencias |
| `sesion03/` | Sesión 3 — Código genético |
| `sesion04/` | Sesión 4 — Matrices de sustitución |
| `sesion05/` | Sesión 5 — Formatos de secuencia: FASTA |
| `sesion06/` | Sesión 6 — Alineamiento por pares |
| `sesion07/` | Sesión 7 — Algoritmos: NW y SW |
| `sesion11/` | Sesión 11 — Bases de datos (unidad 4) |
| `unidad6/` | Unidad 6 — Introducción a R |
| `svg/`, `ncbi/` | Los SVG generados; se versionan |

Cada carpeta de sesión trae su `FIGURAS.md`, que documenta qué es cada figura
y de dónde salen sus números, y su `_tema.R` con la paleta. Los scripts de la
raíz usan `estilo.py` / `estilo.R`: la misma paleta, los mismos hex, en los
dos lenguajes.

## Regenerar

**Python** (numpy y matplotlib, las únicas dependencias):

```bash
python -m venv .venv
# Windows:
.venv/Scripts/python -m pip install numpy matplotlib
# Linux/Mac:
# .venv/bin/pip install numpy matplotlib
```

Después, cada figura se regenera corriendo su script desde esta carpeta:

```bash
cd figuras
../.venv/Scripts/python fig02_nw_matriz.py     # escribe svg/fig02_nw_matriz.svg
```

O todas de una:

```bash
cd figuras
for f in fig0*_*.py; do ../.venv/Scripts/python "$f"; done
```

**R** (ggplot2, svglite, systemfonts y scales, de CRAN): cada script se corre
desde la raíz del repo y encuentra solo su tema y su carpeta de salida:

```bash
Rscript figuras/blast_mapq.R                   # escribe svg/blast_mapq.svg
```

**Los datos no viven en git** (el patrón `datos/` está en el `.gitignore` del
repo). Las carpetas cuyas figuras usan datos reales traen un
`00_descarga_datos.sh` que los baja con su accession y deja el registro de
procedencia al lado; hay que correrlo antes que los scripts de figuras. Si a
un script le faltan sus datos, se detiene con un error que dice exactamente
qué falta: está prohibido inventar datos sintéticos para una figura del libro.

## Reglas (para que los SVG no ensucien el diff de git)

Las imponen `estilo.py` en Python y `estilo.R` en R; no hay que hacer nada
especial, sólo no romperlas:

- **Texto como texto.** `svg.fonttype = 'none'` en matplotlib y svglite en R:
  las etiquetas quedan como texto seleccionable, editable en CorelDRAW.
  (Verifícalo abriendo un SVG: debe poder seleccionarse una etiqueta.)
- **Salida determinista.** En Python, `guardar()` usa `metadata={'Date': None}`
  (sin `<dc:date>`) y un `svg.hashsalt` fijo. En R, svglite no escribe fecha ni
  IDs aleatorios, y `fix_text_size = FALSE` evita los `textLength`. Regenerar
  sin cambiar el script da un SVG byte a byte idéntico.
- **Una sola paleta.** Todos los colores viven en `estilo.py` / `estilo.R`.
  Ningún script teclea un hex suelto.
- **Números calculados, no tecleados.** Las matrices de las figs. 2, 2b y 3 salen
  de `nw_sw.py`. Corre `python nw_sw.py` para ver la verificación de las cifras.
  Lo único tecleado es la matriz de sustitución `TRANSICIONES`, que es la tabla
  del §3 de `algoritmos.qmd`. Las figuras que son esquemas conceptuales lo
  declaran en su encabezado.

## Los archivos de la raíz

### Capítulo 7 — Algoritmos (`algoritmos.qmd`)

| Archivo | Qué hace |
|---------|----------|
| `estilo.py` | Paleta del curso, rcParams, `guardar()` y helpers de rejilla. |
| `estilo.R`  | El gemelo de `estilo.py` para las figuras en R: misma paleta, `tema_lgc()`, `guardar()`. |
| `nw_sw.py`  | Needleman–Wunsch y Smith–Waterman, con `match`/`mismatch` o con matriz de sustitución (`sub=`). Compartido por figs. 2, 2b y 3. |
| `matriz.py` | `dibujar_matriz()`: la retícula llena con flechas y traceback. Compartido por figs. 2, 2b y 3. |
| `fig01_reticula.py`  | La retícula y los tres movimientos. |
| `fig02_nw_matriz.py` | Matriz de NW llena con traceback (GCATGCG/GATTACA, 3 óptimos). |
| `fig02b_nw_matriz_transiciones.py` | El mismo par con el esquema transición/transversión: la matriz `Diagonal` entera dibujada sobre las aristas (score −0.262, 2 óptimos). |
| `fig03_nw_vs_sw.py`  | NW vs SW sobre GCGATTAG/TTGATTACA (bloque GATTA; NW 1, SW 5). |
| `fig04_gap_costos.py`| Curvas de penalización de gap (lineal, afín, afín 2 piezas). |
| `fig05_wavefront.py` | Wavefront (WFA) vs matriz completa. |
| `fig06_variantes.py` | Traceback por variante (global, semi-global, overlap, fitting). |
| `fig07_gotoh.py`     | Las tres matrices de Gotoh (M, Ix, Iy) y sus dependencias. |
| `svg/`               | Los SVG que embebe el `.qmd`. Se versionan. |

### Capítulos 8 y 9 — BLAST (`blast.qmd`) y alineamiento múltiple (`alineamiento-multiple.qmd`)

Vienen del plan A10 del research. Los nombres son descriptivos (no numerados)
porque Quarto numera las figuras por orden de aparición en cada capítulo.

| Archivo | Qué hace | Capítulo |
|---------|----------|----------|
| `blast_seed_extend.py`  | Seed-and-extend con score real de BLOSUM62 (semilla, X-drop, HSP). | BLAST |
| `blast_dos_hits.py`     | La heurística de dos hits, en sus cuatro casos. | BLAST |
| `blast_evd.py`          | EVD (Gumbel) vs normal, en escala log (la cola). | BLAST |
| `blast_evalue_base.py`  | El E-value del mismo alineamiento crece con la base. | BLAST |
| `blast_velocidad.py`    | Espacio velocidad/sensibilidad (esquema conceptual). | BLAST |
| `blast_indexado.R`      | Qué se indexa y qué se recorre: BLAST contra BLAT (esquema). | BLAST |
| `blast_mapq.R`          | Sorpresa contra unicidad: E-value contra MAPQ (esquema). | BLAST |
| `blast_tres.R`          | Las tres preguntas: BLAST, BLAT, BWA (opcional, sin referenciar). | BLAST |
| `msa_progresivo.py`     | Árbol guía y "once a gap, always a gap". | MSA |
| `fig_msa_escalamiento.R`| Costo de la PD exacta (L^N) vs progresivo (N²·L²), escala log. | MSA |
| `fig_msa_desacuerdo.R`  | Acuerdo por columna entre Clustal Omega y MAFFT sobre las globinas de la práctica (datos reales; se detiene si faltan). | MSA |

Las de score (`blast_seed_extend`, `blast_evd`, `blast_evalue_base`) calculan sus
números; las demás de BLAST son esquemas. `blast_velocidad` es explícitamente
conceptual: las posiciones son aproximadas, no valores medidos.

### Unidad 4 — el ecosistema NCBI (`ncbi.qmd` y vecinos)

Su salida va a `ncbi/`, no a `svg/`.

| Archivo | Qué hace |
|---------|----------|
| `ncbi_ecosistema.py`   | Entrez al centro y las bases del NCBI alrededor (esquema). |
| `ncbi_escala.py`       | Escala aproximada de algunas bases del NCBI (la única con datos del capítulo). |
| `anatomia_acceso.py`   | Anatomía de un número de acceso, parte por parte. |
| `edirect_pipeline.py`  | Cuatro comandos de EDirect unidos por tuberías (esquema). |
| `genbank_refseq.py`    | GenBank/INSDC (archivo redundante) contra RefSeq (curado) (esquema). |

## Fig. 8 (BLOSUM62 vs RBLOSUM64): pendiente por licencia

No se incluye. Requiere los valores de **RBLOSUM64**, cuya fuente original es
Styczynski et al. 2008 (*Nature Biotechnology*, no abierto). Hess et al. 2016
(*BMC Bioinformatics*, CC BY 4.0) los publica en
`http://www.cbs.tu-darmstadt.de/CorBLOSUM`, pero esa URL de laboratorio de 2016
no se pudo verificar como fuente viva y con licencia clara dentro del margen que
el plan fija para esta figura ("si no está a la mano en veinte minutos, se
descarta"). Para retomarla hace falta un archivo de RBLOSUM64 con licencia
confirmada; entonces el script leería ese archivo y BLOSUM62 (de dominio público)
y dibujaría el heatmap de la diferencia.
