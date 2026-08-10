#!/usr/bin/env bash
# Fabrica los cinco archivos rotos del Ejercicio 5 a partir del FASTA de lambda,
# y el multi.fa del Ejercicio 6. Correr desde la raíz del repo:
#
#     bash figuras/sesion05/06_fabricar_rotos.sh
#
# Requiere haber corrido antes 00_datos.sh.
#
# ---------------------------------------------------------------------------
# PRIMERO HAY QUE LIMPIAR EL ORIGINAL
#
# El FASTA que devuelve `efetch` TERMINA CON UNA LÍNEA EN BLANCO. Eso rompía dos
# de los cinco archivos rotos:
#
#   roto3  tenía que llevar UNA línea en blanco a media secuencia, y salía con
#          dos. Peor: `grep -n '^$'` también daba positivo sobre el archivo
#          intacto, así que el diagnóstico del capítulo no distinguía nada.
#   roto4  tenía que quedarse SIN salto de línea final, y la línea que se
#          truncaba era justamente la blanca: el archivo quedaba bien formado.
#
# Así que todo se deriva de `lambda.fa`, una copia con las líneas en blanco
# finales quitadas. Ése es también el archivo que deben usar los ejercicios 1
# a 4: es el "sano" contra el que se comparan los rotos.
#
# EL CRITERIO de los cinco sigue siendo el mismo: cada uno tiene que abrirse sin
# problema y verse normal en un `head`. El archivo se ve bien y da números mal.
# ---------------------------------------------------------------------------
set -euo pipefail

DIR="figuras/sesion05/datos"
ROTOS="${DIR}/rotos"
CRUDO="${DIR}/NC_001416.1.fa"
LAMBDA="${DIR}/lambda.fa"

[ -s "$CRUDO" ] || { echo "Falta $CRUDO. Corre antes 00_datos.sh" >&2; exit 1; }
mkdir -p "$ROTOS"

# --- El sano: sin líneas en blanco al final ---------------------------------
# awk acumula y sólo imprime cuando llega algo no vacío, así que las blancas
# intermedias se conservan (no hay) y las finales desaparecen.
awk 'NF{for(i=0;i<n;i++) print ""; n=0; print; next}{n++}' "$CRUDO" > "$LAMBDA"

echo "sano: $(basename "$LAMBDA")  $(wc -l < "$LAMBDA" | tr -d ' ') líneas, \
$(wc -c < "$LAMBDA" | tr -d ' ') bytes, \
$(grep -c '^$' "$LAMBDA" || true) líneas en blanco"
echo

# --- Los cinco rotos ---------------------------------------------------------
# 1. Finales de línea CRLF (Windows).
sed 's/$/\r/' "$LAMBDA" > "${ROTOS}/roto1.fa"

# 2. Multi-FASTA con dos registros de identificador IDÉNTICO. Las secuencias
#    son tramos distintos: el problema es el nombre repetido, no el contenido.
{
  head -n 1 "$LAMBDA"
  grep -v "^>" "$LAMBDA" | head -n 20
  head -n 1 "$LAMBDA"
  grep -v "^>" "$LAMBDA" | sed -n '100,119p'
} > "${ROTOS}/roto2.fa"

# 3. UNA línea en blanco a media secuencia.
awk 'NR==15{print ""} {print}' "$LAMBDA" > "${ROTOS}/roto3.fa"

# 4. Sin salto de línea final. printf '%s' no agrega el \n que sí agrega print.
{
  head -n -1 "$LAMBDA"
  printf '%s' "$(tail -n 1 "$LAMBDA")"
} > "${ROTOS}/roto4.fa"

# 5. Soft-masked: 30 líneas de 70 = 2100 bases en minúsculas.
awk 'NR>=10 && NR<=39 && !/^>/{ $0 = tolower($0) } {print}' "$LAMBDA" \
  > "${ROTOS}/roto5.fa"

# El multi.fa del Ejercicio 6: tres genomas reales, identificadores distintos.
# No está roto; es el insumo del ejercicio de linealizar.
cat "${DIR}/NC_001422.1.fa" "${DIR}/NC_045512.2.fa" "${LAMBDA}" \
  > "${DIR}/multi.fa"

echo "Fabricados en ${ROTOS}/ : $(ls -1 "$ROTOS" | tr '\n' ' ')"
echo "y ${DIR}/multi.fa"
echo

# --- Verificación: los diagnósticos del capítulo -----------------------------
# Nota de plataforma: en Git Bash sobre Windows, `grep` trata \r\n como fin de
# línea y se come el \r, así que el conteo de bases de roto1 NO se infla acá.
# En Linux (ken, que es donde corren los alumnos) sí se infla. Por eso el conteo
# de bytes crudos de abajo se hace con `od`, que no interpreta nada.
diag() {
  local f="$1" n; n=$(basename "$f")
  echo "--- $n ---"
  printf '  %-30s %s\n' "wc -l" "$(wc -l < "$f" | tr -d ' ')"
  printf '  %-30s %s\n' "wc -c" "$(wc -c < "$f" | tr -d ' ')"
  printf '  %-30s %s\n' "grep -c '^>'" "$(grep -c '^>' "$f" || true)"
  printf '  %-30s %s\n' "file" "$(file -b "$f")"
  printf '  %-30s %s\n' "líneas en blanco" "$(grep -c '^$' "$f" || true)"
  printf '  %-30s %s\n' "ids duplicados" \
    "$({ grep '^>' "$f" | sort | uniq -d | head -n1 | cut -c1-38; } || true)"
  printf '  %-30s %s\n' "último byte" "$(tail -c 1 "$f" | od -An -tx1 | tr -d ' ')"
  printf '  %-30s %s\n' "CR (0d) en el archivo" \
    "$(od -An -tx1 -v "$f" | tr ' ' '\n' | grep -c '^0d$' || true)"
  printf '  %-30s %s\n' "minúsculas acgt" \
    "$(grep -v '^>' "$f" | tr -cd 'acgt' | wc -c | tr -d ' ')"
  local ok mal tot
  ok=$(grep -v '^>' "$f"  | tr -d '\r\n' | tr -cd 'GCgc' | wc -c | tr -d ' ')
  mal=$(grep -v '^>' "$f" | tr -d '\r\n' | tr -cd 'GC'   | wc -c | tr -d ' ')
  tot=$(grep -v '^>' "$f" | tr -d '\r\n' | wc -c | tr -d ' ')
  awk -v a="$ok" -v b="$mal" -v t="$tot" 'BEGIN{
    printf "  %-30s %s\n", "bases", t
    printf "  %-30s %.2f %%  (sólo mayúsculas: %.2f %%)\n", "GC", 100*a/t, 100*b/t}'
  echo
}

echo "==================================================================="
echo " DIAGNÓSTICO (las herramientas del Ejercicio 5)"
echo "==================================================================="
diag "$LAMBDA"
for f in "${ROTOS}"/roto*.fa; do diag "$f"; done
