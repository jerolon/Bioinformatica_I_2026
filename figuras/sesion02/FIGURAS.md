# Figuras de la Sesión 2-3 — Tipos de secuencias

Cinco figuras para `contenido/02-secuencias/tipos-de-secuencias.qmd`. Mismas
reglas que la Sesión 01: R con ggplot2 y **svglite**, sin título dentro del SVG
(el caption vive en el `.qmd`), texto como texto para poder editarlo en
CorelDRAW, fondo transparente, etiquetas en español.

`_tema.R` es un adaptador, no un módulo de estilo: conserva los nombres que
pedía la especificación (`AZUL`, `NARANJA`, `tema_libro`, `guardar` en
centímetros) y los cablea a `figuras/estilo.R`, que es el único lugar del repo
donde vive un hex. Ver el encabezado del archivo.

## Regenerar

Desde la raíz del repo, una figura o todas:

```bash
Rscript figuras/sesion02/01_jerarquia.R
for f in figuras/sesion02/0*_*.R; do Rscript "$f"; done
```

Los SVG salen **byte a byte idénticos** al regenerar sin tocar el script
(comprobado), así que el diff de git queda limpio. Se versionan los dos, el
`.R` y el `.svg`.

## Las cinco

| Script | Salida | Qué es | Datos |
|---|---|---|---|
| `01_jerarquia.R` | `jerarquia-gen-producto.svg` | Del locus a la proteína: cinco niveles, cuáles son moléculas y cuáles constructos. | esquema |
| `02_coordenadas.R` | `coordenadas.svg` | 1-based cerrado contra 0-based semiabierto sobre el mismo tramo. | esquema |
| `03_composicion_genoma.R` | `composicion-genoma.svg` + `.tsv` | Composición del genoma humano por clase de secuencia. | IHGSC 2001 |
| `04_biotypes.R` | `genes-por-biotype.svg` + `.tsv` | Genes humanos por biotype. | GENCODE v48 |
| `05_mapa_formatos.R` | `mapa-formatos.svg` | Los formatos ubicados sobre el flujo de un análisis. | esquema |

Las tres primeras y la quinta se dibujan en **milímetros** con `theme_void()`:
1 unidad = 1 mm, igual que el `size` de `geom_text`, así que los anchos de texto
se pueden comparar contra los huecos. Cada script termina con un bloque de
`stopifnot()` que comprueba lo que la figura afirma y que nada se encima ni se
sale del panel. Si alguien alarga una etiqueta, el script truena en vez de
producir un SVG con texto encimado.

Los tres esquemas no tienen números que medir, así que no escriben `.tsv`. Las
dos figuras con datos sí, y ese `.tsv` es el cotejo entre la figura y la prosa
del capítulo.

## Los números, y qué tan firmes son

### Figura 3 — composición del genoma

Los ocho porcentajes suman **100 exacto** (lo comprueba un `stopifnot`). Las
cinco fracciones repetitivas son de **IHGSC 2001** (*Nature* 409:860),
redondeadas: LINE 20.4 → 21, SINE 13.1 → 13, LTR 8.3 → 8, transposones de DNA
2.8 → 3; satélites y demás repeticiones en tándem se ponen en 3. Exones
codificantes (1.5), intrones (26) y resto intergénico (24.5) son las cifras
convencionales del mismo artículo, con el intergénico ajustado para cerrar en
100 (es la categoría residual, la de definición más blanda).

Verificado contra el resumen de RepeatMasker para hg38
(<https://www.repeatmasker.org/species/hg.html>):

| | figura | RepeatMasker hg38 |
|---|---|---|
| repeticiones intercaladas | 45 % | 48.49 % |
| total repetitivo | 48 % | 52.58 % |

O sea que la figura **subestima ~4.6 puntos**, casi todos en el bloque de
satélites y repeticiones simples (acá 3 %, en RepeatMasker ~4.1 %). No se
corrige porque el cuerpo del capítulo cita los mismos valores de IHGSC
(LINE ~21 %, Alu ~10 %, LTR ~8 %, DNA ~3 %). Si se actualiza el texto, hay que
actualizar la figura en la misma edición.

### Figura 4 — biotypes

Cifras de **GENCODE Release 48 (GRCh38)**, verificadas una a una contra
<https://www.gencodegenes.org/human/stats_48.html>. Coinciden exactamente con
las del capítulo.

Al 5 de agosto de 2026 el release vigente ya es el **50**. Las cifras de v50
están en el encabezado de `04_biotypes.R`, comentadas, para que actualizar sea
una edición y no una investigación. **Hay que cambiar figura y capítulo a la
vez**: el texto corrido y el Ejercicio 6 citan v48.

Un detalle que confunde y que el script deja documentado: el total de
pseudogenes de GENCODE (14,695) **no** es la suma de los tres tipos que enumera
el capítulo.

```
10,643 procesados + 3,549 no procesados + 266 unitarios = 14,458
14,695 - 14,458 = 237  =  pseudogenes de segmentos IG/TR
```

Los 237 van en un renglón aparte del release (junto a los 412 segmentos IG/TR
codificantes, ésos sí graficados) y no están en la figura. La lista del
capítulo es correcta, pero no exhaustiva: son los tres tipos que importan
conceptualmente, no las cuatro categorías del release.

Por lo mismo, las siete barras suman 77,769; con los 237 de IG/TR, 78,006. El
total del release (78,686) incluye además 680 genes de clases residuales que la
figura no desglosa.
