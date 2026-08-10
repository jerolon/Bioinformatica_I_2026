#!/usr/bin/env bash
# Baja los CDS de los tres genomas que usa la figura 4 de la Sesión 3
# (uso de codones y GC). Correr desde la raíz del repo:
#
#     bash figuras/sesion03/00_descarga_datos.sh
#
# Idempotente: si el archivo ya está y no está vacío, no lo vuelve a bajar.
#
# ---------------------------------------------------------------------------
# POR QUÉ REFSEQ Y NO UNA TABLA DE USO DE CODONES YA CALCULADA
#
# La especificación de la figura pedía CoCoPUTs o HIVE-CUTs, y explícitamente NO
# Kazusa (que el capítulo critica por nombre: congelada en 2007). Al 5 de agosto
# de 2026 CoCoPUTs y HIVE-CUTs son el mismo servicio y está caído:
# dnahive.fda.gov resuelve (150.148.26.122) pero no acepta conexiones HTTPS, y
# hive.biochemistry.gwu.edu/review/codon2 sólo redirige ahí.
#
# Así que el RSCU se calcula de cero a partir de los CDS de RefSeq. Sale mejor
# que cualquier tabla precalculada para lo que el capítulo quiere enseñar: queda
# anclado a un accession y una fecha exactos, y se puede volver a correr. La
# queja del capítulo contra Kazusa es justamente que no dice cuándo se actualizó.
#
# Los .fna.gz NO se versionan (datos/ está en .gitignore). Lo que se versiona es
# este script, el .R y el .tsv de resultados.
# ---------------------------------------------------------------------------
set -euo pipefail

DESTINO="figuras/sesion03/datos"
BASE="https://ftp.ncbi.nlm.nih.gov/genomes/all"

# organismo|ruta del ensamblaje en el FTP|nombre corto
GENOMAS=(
  "Plasmodium falciparum 3D7|GCF/000/002/765/GCF_000002765.6_GCA_000002765|plasmodium"
  "Escherichia coli K-12 MG1655|GCF/000/005/845/GCF_000005845.2_ASM584v2|ecoli"
  "Streptomyces coelicolor A3(2)|GCF/000/203/835/GCF_000203835.1_ASM20383v1|streptomyces"
)

mkdir -p "$DESTINO"

for g in "${GENOMAS[@]}"; do
  IFS='|' read -r nombre ruta corto <<< "$g"
  base_archivo="${ruta##*/}"
  url="${BASE}/${ruta}/${base_archivo}_cds_from_genomic.fna.gz"
  destino="${DESTINO}/${corto}_cds.fna.gz"

  if [ ! -s "$destino" ]; then
    echo "bajando  ${nombre} ..."
    curl -sS --fail --retry 3 --retry-delay 2 "$url" -o "$destino"
    # Chequeo mínimo: que sea gzip de verdad y no una página de error del NCBI.
    if ! gzip -t "$destino" 2>/dev/null; then
      echo "ERROR: $destino no es un gzip válido. Se borra." >&2
      rm -f "$destino"
      exit 1
    fi
    sleep 1   # cortesía con el NCBI
  else
    echo "ya está ${nombre}"
  fi
done

# Se deja constancia de QUÉ se bajó y CUÁNDO, al lado de los datos. Es el dato
# que el capítulo reclama que Kazusa no da. El .R lo lee y lo copia al .tsv.
{
  echo -e "organismo\tarchivo\tassembly\tfecha_descarga\tfuente"
  hoy=$(date -u +%Y-%m-%d)
  for g in "${GENOMAS[@]}"; do
    IFS='|' read -r nombre ruta corto <<< "$g"
    # El directorio se llama GCF_000002765.6_GCA_000002765: el accession son los
    # DOS primeros campos, no el primero (con `${asm%%_*}` salía "GCF" a secas).
    asm=$(echo "${ruta##*/}" | cut -d_ -f1,2)
    echo -e "${nombre}\t${corto}_cds.fna.gz\t${asm}\t${hoy}\tNCBI RefSeq (ftp.ncbi.nlm.nih.gov/genomes/all/${ruta})"
  done
} > "${DESTINO}/PROCEDENCIA.tsv"

echo
echo "Listo. Resumen:"
for g in "${GENOMAS[@]}"; do
  IFS='|' read -r nombre ruta corto <<< "$g"
  f="${DESTINO}/${corto}_cds.fna.gz"
  n=$(gzip -dc "$f" | grep -c "^>")
  mb=$(du -m "$f" | cut -f1)
  printf "  %-32s %7d CDS   %3d MB\n" "$nombre" "$n" "$mb"
done
echo
echo "Procedencia en ${DESTINO}/PROCEDENCIA.tsv"
