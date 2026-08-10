#!/usr/bin/env bash
# Deja en figuras/sesion05/datos/ los seis genomas que usan las figuras de la
# Sesión 5. Correr desde la raíz del repo:
#
#     bash figuras/sesion05/00_datos.sh
#
# Idempotente: si el archivo ya está y no está vacío, no hace nada.
#
# ---------------------------------------------------------------------------
# POR QUÉ COPIA ANTES DE BAJAR
#
# Son los MISMOS seis accessions que ya baja figuras/sesion01/00_descarga_datos.sh
# a datos/ en la raíz del repo. Si están ahí, se copian y no se toca el NCBI.
#
# No es una optimización: es el mismo principio que el capítulo predica en el
# callout del inicio de la práctica. El NCBI limita a tres peticiones por
# segundo y por IP, y volver a bajar seis archivos que ya están en disco para
# generar una figura es exactamente la clase de descarga que ahí se pide evitar.
# Sólo se baja lo que de verdad falta, y con el sleep de cortesía.
# ---------------------------------------------------------------------------
set -euo pipefail

DESTINO="figuras/sesion05/datos"
ORIGEN_LOCAL="datos"        # lo que dejó la sesión 01, si existe

ACCESSIONS=(
  NC_001422.1   # fago phiX174               5 386 pb
  NC_045512.2   # SARS-CoV-2                29 903 pb
  NC_001416.1   # fago lambda               48 502 pb
  NC_001133.9   # levadura, cromosoma I    230 218 pb
  NC_000908.2   # Mycoplasmoides genitalium 580 076 pb
  NC_000913.3   # E. coli K-12            4 641 652 pb
)

mkdir -p "$DESTINO"

bajar() {
  local acc="$1" salida="$2"
  if command -v efetch >/dev/null 2>&1; then
    efetch -db nuccore -id "$acc" -format fasta > "$salida"
  else
    curl -sS --fail --retry 3 --retry-delay 2 \
      "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${acc}&rettype=fasta&retmode=text" \
      -o "$salida"
  fi
}

n_copiados=0; n_bajados=0
for acc in "${ACCESSIONS[@]}"; do
  destino="${DESTINO}/${acc}.fa"
  [ -s "$destino" ] && { echo "ya está  $acc"; continue; }

  if [ -s "${ORIGEN_LOCAL}/${acc}.fasta" ]; then
    cp "${ORIGEN_LOCAL}/${acc}.fasta" "$destino"
    echo "copiado  $acc  (de ${ORIGEN_LOCAL}/, sin tocar el NCBI)"
    n_copiados=$((n_copiados + 1))
  else
    echo "bajando  $acc ..."
    bajar "$acc" "$destino"
    if ! head -n1 "$destino" | grep -q "^>"; then
      echo "ERROR: $destino no empieza con '>'. Se borra." >&2
      rm -f "$destino"; exit 1
    fi
    n_bajados=$((n_bajados + 1))
    sleep 1   # cortesía con el NCBI
  fi
done

echo
echo "Listo: $n_copiados copiados, $n_bajados bajados del NCBI."
echo
printf "  %-14s %10s %10s %8s %7s  %s\n" accession bytes bases líneas ancho encabezado
for acc in "${ACCESSIONS[@]}"; do
  f="${DESTINO}/${acc}.fa"
  awk -v acc="$acc" -v bytes="$(wc -c < "$f" | tr -d ' ')" '
    /^>/{enc=substr($0,2,42); next}
    NF{bases+=length($0); n[length($0)]++}
    END{
      max=0; for (w in n) if (n[w]>max) {max=n[w]; ancho=w}
      printf "  %-14s %10d %10d %8d %7d  %s\n", acc, bytes, bases, NR, ancho, enc
    }' "$f"
done
