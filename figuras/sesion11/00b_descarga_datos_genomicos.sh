#!/usr/bin/env bash
# Datos GENÓMICOS de la Sesión 11 (Unidad 5, browsers y práctica TP53).
#
#   bash figuras/sesion11/00b_descarga_datos_genomicos.sh
#
# Va aparte de 00_descarga_datos.sh porque esto **tarda y pesa**: se bajan
# ~330 MB comprimidos para dejar ~90 MB útiles. Los accessions sueltos del
# hilo (TP53, p53, UniProt) los baja el 00_, que corre en segundos.
#
# ---------------------------------------------------------------------------
# TODO SE RECORTA AL CROMOSOMA 17 ANTES DE GUARDARSE
#
# La práctica sólo mira TP53. Guardar el genoma completo en un servidor
# compartido con treinta cuentas es tirar disco a la basura, así que cada
# archivo se filtra en el momento de bajarlo:
#
#   GENCODE   ~119 MB gz  ->  awk por cromosoma  ->  ~8 MB
#   ClinVar   ~184 MB gz  ->  tabix a la región  ->  ~200 KB
#   chr17     ~25 MB gz   ->  se queda entero    ->  ~83 MB sin comprimir
#
# El cromosoma 17 no se recorta porque IGV necesita el FASTA completo con su
# índice para navegar; recortarlo obligaría a reescribir las coordenadas y ése
# es justo el error que enseña el capítulo.
#
#   DESTINO EN EL SERVIDOR:  /datos/cursos/bioinfo1/sesion11/
#   DESTINO=/datos/cursos/bioinfo1/sesion11  bash 00b_descarga_datos_genomicos.sh
# ---------------------------------------------------------------------------

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESTINO="${DESTINO:-$AQUI/datos}"
mkdir -p "$DESTINO"
cd "$DESTINO"

# --- Herramientas. Se comprueban ANTES de bajar 300 MB. --------------------
FALTAN=()
for t in curl awk gzip; do
  command -v "$t" >/dev/null 2>&1 || FALTAN+=("$t")
done
for t in bgzip tabix samtools; do
  command -v "$t" >/dev/null 2>&1 || FALTAN+=("$t")
done
if [[ ${#FALTAN[@]} -gt 0 ]]; then
  echo "Faltan herramientas: ${FALTAN[*]}" >&2
  echo "En ken deberían estar; localmente:  conda install -c bioconda samtools htslib" >&2
  exit 1
fi

# --- Fuentes. Verificadas el 2026-08-07 (todas HTTP 200). ------------------
UCSC="https://hgdownload.soe.ucsc.edu/goldenPath"
GENCODE="https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/latest_release"
CLINVAR="https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38"

# GENCODE va por número de release, no por un alias "latest": el alias no
# existe como archivo. Al 2026-08-07 la vigente es la v50. Si sube, cámbialo
# acá y el script avisa solo (falla el curl -f).
GENCODE_V="${GENCODE_V:-50}"

CROM="chr17"
REGION="17:7,560,000-7,700,000"     # TP53 con holgura, para el recorte de ClinVar

# --- 1. Cadena para liftOver (1.2 MB) --------------------------------------
if [[ ! -s hg38ToHg19.over.chain.gz ]]; then
  echo "[1/4] Cadena hg38 -> hg19..."
  curl -fsSL "${UCSC}/hg38/liftOver/hg38ToHg19.over.chain.gz" \
    -o hg38ToHg19.over.chain.gz
else
  echo "[1/4] Cadena ya está, se salta."
fi

# --- 2. Cromosoma 17 con su índice (25 MB gz -> 83 MB) ---------------------
if [[ ! -s chr17.fa.fai ]]; then
  echo "[2/4] Cromosoma 17 de hg38 (25 MB comprimidos)..."
  curl -fsSL "${UCSC}/hg38/chromosomes/${CROM}.fa.gz" -o chr17.fa.gz
  gzip -dc chr17.fa.gz > chr17.fa
  rm -f chr17.fa.gz
  samtools faidx chr17.fa
else
  echo "[2/4] chr17.fa ya está indexado, se salta."
fi

# --- 3. GENCODE recortado al cromosoma 17 (119 MB -> ~8 MB) ----------------
if [[ ! -s gencode_chr17.gtf ]]; then
  echo "[3/4] GENCODE v${GENCODE_V}, recortando a ${CROM} sobre la marcha..."
  # Se filtra EN EL PIPE: nunca toca el disco el GTF completo.
  curl -fsSL "${GENCODE}/gencode.v${GENCODE_V}.annotation.gtf.gz" \
    | gzip -dc \
    | awk -v c="${CROM}" 'BEGIN{FS=OFS="\t"} /^#/ {print; next} $1==c {print}' \
    > gencode_chr17.gtf
else
  echo "[3/4] gencode_chr17.gtf ya está, se salta."
fi

# --- 4. ClinVar recortado a la región de TP53 (184 MB -> ~200 KB) ----------
if [[ ! -s clinvar_chr17.vcf.gz.tbi ]]; then
  echo "[4/4] ClinVar GRCh38, recortando a ${REGION}..."
  curl -fsSL "${CLINVAR}/clinvar.vcf.gz"     -o .clinvar_full.vcf.gz
  curl -fsSL "${CLINVAR}/clinvar.vcf.gz.tbi" -o .clinvar_full.vcf.gz.tbi
  # ClinVar viene con cromosomas SIN prefijo chr (estilo Ensembl/GRC). Es el
  # tema de @fig-nomenclatura, así que acá se respeta y se deja documentado:
  # este VCF usa "17", no "chr17".
  tabix -h .clinvar_full.vcf.gz "${REGION//,/}" | bgzip -c > clinvar_chr17.vcf.gz
  tabix -p vcf clinvar_chr17.vcf.gz
  rm -f .clinvar_full.vcf.gz .clinvar_full.vcf.gz.tbi
else
  echo "[4/4] clinvar_chr17.vcf.gz ya está indexado, se salta."
fi

# --- Verificación -----------------------------------------------------------
for f in hg38ToHg19.over.chain.gz chr17.fa chr17.fa.fai gencode_chr17.gtf \
         clinvar_chr17.vcf.gz clinvar_chr17.vcf.gz.tbi; do
  test -s "$f" || { echo "$f vacío o ausente" >&2; exit 1; }
done

N_GTF="$(grep -vc '^#' gencode_chr17.gtf)"
N_TP53="$(awk -F'\t' '$3=="gene" && /gene_name "TP53"/' gencode_chr17.gtf | wc -l)"
N_VAR="$(tabix clinvar_chr17.vcf.gz "${REGION//,/}" | wc -l)"
LARGO17="$(cut -f2 chr17.fa.fai)"

test "$N_TP53" -ge 1 || { echo "el GTF recortado no trae el gen TP53" >&2; exit 1; }
test "$N_VAR"  -ge 1 || { echo "el VCF recortado no trae variantes"  >&2; exit 1; }

HOY="$(date +%F)"
cat > PROCEDENCIA-genomicos.md <<EOF
Generado por \`figuras/sesion11/00b_descarga_datos_genomicos.sh\` el ${HOY}.

| Archivo | Fuente | Recorte | Bajado |
|---|---|---|---|
| \`chr17.fa\` + \`.fai\` | UCSC goldenPath hg38 | cromosoma completo | ${HOY} |
| \`gencode_chr17.gtf\` | GENCODE v${GENCODE_V} | sólo \`${CROM}\` | ${HOY} |
| \`clinvar_chr17.vcf.gz\` + \`.tbi\` | ClinVar GRCh38 | ${REGION} | ${HOY} |
| \`hg38ToHg19.over.chain.gz\` | UCSC liftOver | — | ${HOY} |

- Cromosoma 17: ${LARGO17} bp.
- GTF recortado: ${N_GTF} líneas de anotación, ${N_TP53} registro(s) de gen TP53.
- ClinVar en la ventana de TP53: ${N_VAR} variantes.

**Nomenclatura, ojo.** \`chr17.fa\` y el GTF de GENCODE usan \`chr17\` (estilo
UCSC). El VCF de ClinVar usa \`17\` (estilo GRC/Ensembl). Es deliberado: es
exactamente el choque que enseña \`@fig-nomenclatura\`, y la práctica lo
aprovecha en vez de esconderlo.
EOF

echo ""
echo "Listo en ${DESTINO}:"
ls -lh hg38ToHg19.over.chain.gz chr17.fa chr17.fa.fai gencode_chr17.gtf \
       clinvar_chr17.vcf.gz clinvar_chr17.vcf.gz.tbi PROCEDENCIA-genomicos.md
echo ""
echo "  chr17: ${LARGO17} bp"
echo "  GTF (${CROM}): ${N_GTF} líneas, ${N_TP53} gen TP53"
echo "  ClinVar en ${REGION}: ${N_VAR} variantes"
echo ""
echo "  OJO: el GTF usa 'chr17' y el VCF usa '17'. Es a propósito."
