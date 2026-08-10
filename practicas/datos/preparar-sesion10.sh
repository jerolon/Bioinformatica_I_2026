#!/usr/bin/env bash
#
# Prepara los datos de la práctica de la sesión 10 (reciprocal best hits).
#
# Baja los proteomas de referencia de UniProt para S. cerevisiae y S. pombe,
# los recorta a N proteínas con un muestreo reproducible y los deja en el
# directorio compartido del curso junto con un PROCEDENCIA.md.
#
# Se corre UNA vez, desde una cuenta con permiso de escritura en el destino.
# Los alumnos sólo hacen `cp` de lo que este script deja.
#
# Requiere: curl, seqkit (https://bioinf.shenwei.me/seqkit/).
#
# Uso:
#   ./preparar-sesion10.sh [directorio_destino]
#
# Variables de entorno que se pueden sobreescribir:
#   N        número de proteínas por proteoma (default 500)
#   SEMILLA  semilla del muestreo (default 42)

set -euo pipefail

DESTINO="${1:-/datos/cursos/bioinfo1/sesion10}"
N="${N:-500}"
SEMILLA="${SEMILLA:-42}"

# Proteomas de referencia de UniProt.
PROTEOMA_CEREVISIAE="UP000002311"   # Saccharomyces cerevisiae S288C
PROTEOMA_POMBE="UP000002485"        # Schizosaccharomyces pombe 972h-

BASE_URL="https://rest.uniprot.org/uniprotkb/stream"

for prog in curl seqkit; do
  command -v "$prog" >/dev/null 2>&1 || { echo "Falta $prog en el PATH." >&2; exit 1; }
done

mkdir -p "$DESTINO"
TRABAJO="$(mktemp -d)"
trap 'rm -rf "$TRABAJO"' EXIT

FECHA="$(date +%Y-%m-%d)"

# El recorte tiene que ser reproducible y de tamaño exacto. `seqkit sample -n`
# no garantiza el número exacto en una sola pasada; `shuffle` con semilla fija
# seguido de `head` sí, y es igual de reproducible.
#
# Ojo con encadenarlos por tubería: `seqkit head` cierra la tubería al llegar a
# N y `seqkit shuffle` muere con SIGPIPE, lo que bajo `pipefail` aborta el
# script a mitad de camino. Por eso van en dos pasos, con un archivo temporal.
recortar () {   # recortar <id_proteoma> <nombre_salida>
  local proteoma="$1" salida="$2"
  local url="${BASE_URL}?query=proteome:${proteoma}&format=fasta"

  echo "  bajando ${proteoma} ..."
  curl -sSfL --retry 3 --max-time 600 -o "${TRABAJO}/${salida}.full.fasta" "$url"

  local total
  total=$(grep -c '^>' "${TRABAJO}/${salida}.full.fasta")
  echo "  ${proteoma}: ${total} proteínas en el proteoma completo"

  seqkit shuffle -s "$SEMILLA" "${TRABAJO}/${salida}.full.fasta" \
                 -o "${TRABAJO}/${salida}.shuf.fasta" 2>/dev/null
  seqkit head -n "$N" "${TRABAJO}/${salida}.shuf.fasta" \
              -o "${DESTINO}/${salida}.fasta" 2>/dev/null

  local recortado
  recortado=$(grep -c '^>' "${DESTINO}/${salida}.fasta")
  echo "  ${salida}.fasta: ${recortado} proteínas"
  [ "$recortado" -eq "$N" ] || { echo "  ERROR: se esperaban ${N}." >&2; exit 1; }

  # Se devuelve el total para el PROCEDENCIA.md.
  echo "$total" > "${TRABAJO}/${salida}.total"
}

echo "Preparando datos de la sesión 10 en ${DESTINO}"
recortar "$PROTEOMA_CEREVISIAE" cerevisiae
recortar "$PROTEOMA_POMBE"      pombe

TOTAL_CEREVISIAE="$(cat "${TRABAJO}/cerevisiae.total")"
TOTAL_POMBE="$(cat "${TRABAJO}/pombe.total")"
VERSION_SEQKIT="$(seqkit version 2>&1 | tr -d '\r' | tr '\n' ' ')"

cat > "${DESTINO}/PROCEDENCIA.md" <<EOF
# Procedencia de los datos — sesión 10 (reciprocal best hits)

Generado por \`practicas/datos/preparar-sesion10.sh\` el **${FECHA}**.

## Origen

| Archivo | Proteoma UniProt | Organismo | Proteínas en el proteoma completo |
|---|---|---|---|
| \`cerevisiae.fasta\` | [${PROTEOMA_CEREVISIAE}](https://www.uniprot.org/proteomes/${PROTEOMA_CEREVISIAE}) | *Saccharomyces cerevisiae* S288C | ${TOTAL_CEREVISIAE} |
| \`pombe.fasta\` | [${PROTEOMA_POMBE}](https://www.uniprot.org/proteomes/${PROTEOMA_POMBE}) | *Schizosaccharomyces pombe* 972h- | ${TOTAL_POMBE} |

URL de descarga (una por proteoma):

\`\`\`
${BASE_URL}?query=proteome:<ID>&format=fasta
\`\`\`

UniProt se distribuye bajo CC BY 4.0.

## Recorte

Cada proteoma se recortó a **${N} proteínas** con un muestreo reproducible
(semilla fija \`${SEMILLA}\`):

\`\`\`bash
seqkit shuffle -s ${SEMILLA} <proteoma>.full.fasta -o <proteoma>.shuf.fasta
seqkit head   -n ${N}        <proteoma>.shuf.fasta -o <salida>.fasta
\`\`\`

Con la misma semilla y la misma versión del proteoma el recorte es idéntico.
Ojo: UniProt actualiza los proteomas de referencia, así que un mismo comando
en otra fecha puede dar otro conjunto. Por eso la fecha va anotada arriba.

## Versiones

\`\`\`
${VERSION_SEQKIT}
\`\`\`
EOF

echo
echo "Listo. En ${DESTINO}:"
ls -lh "${DESTINO}"
