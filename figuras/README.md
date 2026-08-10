# Figuras del capítulo 7 (Algoritmos: Needleman–Wunsch y Smith–Waterman)

Cada figura se **calcula** con un script de Python y se guarda como SVG. **El
script es la fuente de verdad; el SVG es lo que Quarto embebe.** El render del
libro nunca ejecuta estos scripts (por eso `freeze: auto` y las figuras
calculadas conviven sin problema): se versionan los dos, el `.py` y el `.svg`.

## Regenerar

Una vez, para tener numpy y matplotlib (las únicas dependencias):

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

## Reglas (para que los SVG no ensucien el diff de git)

Las impone `estilo.py`; no hay que hacer nada especial, sólo no romperlas:

- **Texto como texto.** `svg.fonttype = 'none'`: las etiquetas quedan como
  texto seleccionable, editable en CorelDRAW. (Verifícalo abriendo un SVG: debe
  poder seleccionarse una etiqueta.)
- **Salida determinista.** `guardar()` usa `metadata={'Date': None}` (sin
  `<dc:date>`) y un `svg.hashsalt` fijo. Regenerar sin cambiar el script da un
  SVG byte a byte idéntico.
- **Una sola paleta.** Todos los colores viven en `estilo.py`. Ningún script
  teclea un hex suelto.
- **Números calculados, no tecleados.** Las matrices de las figs. 2, 2b y 3 salen
  de `nw_sw.py`. Corre `python nw_sw.py` para ver la verificación de las cifras.
  Lo único tecleado es la matriz de sustitución `TRANSICIONES`, que es la tabla
  del §3 de `algoritmos.qmd`.

## Archivos

| Archivo | Qué hace |
|---------|----------|
| `estilo.py` | Paleta del curso, rcParams, `guardar()` y helpers de rejilla. |
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

### Capítulo 8 — BLAST (`blast.qmd`) y alineamiento múltiple (`alineamiento-multiple.qmd`)

Vienen del plan A10 del research. Los nombres son descriptivos (no numerados)
porque Quarto numera las figuras por orden de aparición en cada capítulo.

| Archivo | Qué hace | Capítulo |
|---------|----------|----------|
| `blast_seed_extend.py`  | Seed-and-extend con score real de BLOSUM62 (semilla, X-drop, HSP). | BLAST |
| `blast_dos_hits.py`     | La heurística de dos hits, en sus cuatro casos. | BLAST |
| `blast_evd.py`          | EVD (Gumbel) vs normal, en escala log (la cola). | BLAST |
| `blast_evalue_base.py`  | El E-value del mismo alineamiento crece con la base. | BLAST |
| `blast_velocidad.py`    | Espacio velocidad/sensibilidad (esquema conceptual). | BLAST |
| `msa_progresivo.py`     | Árbol guía y "once a gap, always a gap". | MSA |

Las de score (`blast_seed_extend`, `blast_evd`, `blast_evalue_base`) calculan sus
números; las otras tres son esquemas. `blast_velocidad` es explícitamente
conceptual: las posiciones son aproximadas, no valores medidos.

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
