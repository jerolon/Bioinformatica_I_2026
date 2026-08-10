#!/usr/bin/env bash
# Baja los seis genomas que usan las figuras de la práctica de la Sesión 01.
# Correr desde la raíz del repo:   bash figuras/sesion01/00_descarga_datos.sh
#
# Idempotente: si el FASTA ya está y no está vacío, no lo vuelve a bajar.
#
# Usa efetch (EDirect) si está instalado, que es lo que corren los alumnos en
# ken. Si no está, cae a curl contra el mismo endpoint de E-utilities: efetch no
# es más que un wrapper de esa URL, y así el script también corre en la máquina
# de quien edita el libro sin instalar EDirect. El FASTA que llega es idéntico.
set -euo pipefail

DESTINO="datos"
ACCESSIONS=(
  NC_001416.1   # fago lambda            48 502 pb
  NC_001422.1   # fago phiX174            5 386 pb
  NC_045512.2   # SARS-CoV-2             29 903 pb
  NC_000908.2   # Mycoplasmoides genitalium G37   580 076 pb
  NC_000913.3   # E. coli K-12 MG1655  4 641 652 pb
  NC_001133.9   # levadura, cromosoma I  230 218 pb
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

for acc in "${ACCESSIONS[@]}"; do
  destino="${DESTINO}/${acc}.fasta"
  if [ ! -s "$destino" ]; then
    echo "bajando $acc ..."
    bajar "$acc" "$destino"
    # Chequeo mínimo: que sea un FASTA y no una página de error del NCBI.
    if ! head -n1 "$destino" | grep -q "^>"; then
      echo "ERROR: $destino no empieza con '>'. Se borra." >&2
      rm -f "$destino"
      exit 1
    fi
    sleep 1   # cortesía con el NCBI
  else
    echo "ya está  $acc"
  fi
done

# Alias corto para lambda, que es el genoma del capítulo.
# El symlink es lo correcto en Linux/macOS; en Git Bash sobre Windows los
# symlinks suelen estar deshabilitados, así que se cae a copiar. Son 48 kb.
if ! ln -sf "NC_001416.1.fasta" "${DESTINO}/lambda.fasta" 2>/dev/null; then
  cp -f "${DESTINO}/NC_001416.1.fasta" "${DESTINO}/lambda.fasta"
fi

echo
echo "Listo. Resumen:"
for acc in "${ACCESSIONS[@]}"; do
  f="${DESTINO}/${acc}.fasta"
  n=$(grep -v "^>" "$f" | tr -d '\r\n' | wc -c)
  gc=$(grep -v "^>" "$f" | tr -d '\r\n' | tr -cd 'GCgc' | wc -c)
  awk -v a="$acc" -v n="$n" -v g="$gc" \
    'BEGIN{printf "  %-14s %10d pb   GC %5.2f%%\n", a, n, 100*g/n}'
done
