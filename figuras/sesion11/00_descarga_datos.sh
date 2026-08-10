#!/usr/bin/env bash
# Datos de la Sesión 11 (Unidad 4, bases de datos).
#
# Baja el mismo TP53 humano que usan la práctica y dos de las figuras, y deja
# al lado un PROCEDENCIA.md con qué se bajó y cuándo. `datos/` está en
# .gitignore: lo que se versiona es este script y el PROCEDENCIA.
#
#   bash figuras/sesion11/00_descarga_datos.sh
#
# ---------------------------------------------------------------------------
# POR QUÉ ESTO SE CORRE UNA VEZ Y NO TREINTA
#
# El NCBI limita a 3 peticiones por segundo POR IP, y `ken` sale a internet con
# una sola IP para todo el grupo. Treinta alumnos corriendo efetch a la vez nos
# devuelven HTTP 429 a todos y se acaba la práctica. Por eso los datos se
# pre-descargan acá y se copian a la carpeta compartida; los alumnos no llaman
# al NCBI durante la clase.
#
#   DESTINO EN EL SERVIDOR:  /datos/cursos/bioinfo1/sesion11/
#
# Este script llena la copia local de figuras/. Para la del servidor, correrlo
# con  DESTINO=/datos/cursos/bioinfo1/sesion11  bash 00_descarga_datos.sh
# ---------------------------------------------------------------------------

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESTINO="${DESTINO:-$AQUI/datos}"
mkdir -p "$DESTINO"
cd "$DESTINO"

EFETCH="https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
ACC_NT="NM_000546.6"      # RefSeq, mRNA curado de TP53, variante 1
ACC_UP="P04637"           # UniProtKB, P53_HUMAN

# Envío original del INSDC para p53 humano. La práctica lo usa en la parada 3
# para probar que el intercambio diario existe: tiene que estar en los tres
# archivos, y tiene que ser p53 HUMANO.
#
# OJO: la especificación pedía X03495, pero ese accession es mRNA de glutamina
# sintetasa de hámster chino (Cricetulus longicaudatus) — verificado contra el
# NCBI el 2026-08-07. Se cambió por X02469, "Human mRNA for p53 cellular tumor
# antigen", que además es la primera referencia cruzada DR EMBL del registro
# P04637 de UniProt, así que la parada 4 también cierra.
ACC_INSDC="X02469"

# Si hay llave de API, se usa: sube el límite de 3 a 10 peticiones por segundo.
LLAVE=""
if [[ -n "${NCBI_API_KEY:-}" ]]; then
  LLAVE="&api_key=${NCBI_API_KEY}"
  echo "  (usando NCBI_API_KEY)"
fi

echo "Bajando ${ACC_NT} (RefSeq) en formato GenBank..."
curl -fsS "${EFETCH}?db=nucleotide&id=${ACC_NT}&rettype=gb&retmode=text${LLAVE}" \
  -o tp53_refseq.gb
sleep 1                                    # cortesía: bien por debajo del límite

echo "Bajando ${ACC_NT} en formato FASTA..."
curl -fsS "${EFETCH}?db=nucleotide&id=${ACC_NT}&rettype=fasta&retmode=text${LLAVE}" \
  -o tp53.fasta
sleep 1

echo "Bajando ${ACC_INSDC} (envío original del INSDC) en formato GenBank..."
curl -fsS "${EFETCH}?db=nucleotide&id=${ACC_INSDC}&rettype=gb&retmode=text${LLAVE}" \
  -o tp53_insdc.gb
sleep 1

echo "Bajando ${ACC_UP} de UniProt..."
curl -fsS "https://rest.uniprot.org/uniprotkb/${ACC_UP}.txt" -o p04637.txt

# --- Verificación. Un archivo truncado no se nota hasta que la figura sale mal.
for f in tp53_refseq.gb tp53.fasta tp53_insdc.gb p04637.txt; do
  test -s "$f" || { echo "$f vacío" >&2; exit 1; }
done

# efetch cierra el registro con "//" y deja UNA línea en blanco detrás, así que
# se mira la última línea NO vacía, no la última a secas.
ultima_util() { grep -v '^[[:space:]]*$' "$1" | tail -1; }

head -1 tp53_refseq.gb | grep -q '^LOCUS' || { echo "tp53_refseq.gb no empieza en LOCUS" >&2; exit 1; }
ultima_util tp53_refseq.gb | grep -q '^//' || { echo "tp53_refseq.gb no termina en //"   >&2; exit 1; }
grep -q "^VERSION     ${ACC_NT}$" tp53_refseq.gb \
  || { echo "OJO: tp53_refseq.gb no trae VERSION ${ACC_NT}. ¿Subió de versión?" >&2; exit 1; }
head -1 tp53.fasta | grep -q '^>'   || { echo "tp53.fasta sin encabezado" >&2; exit 1; }
head -1 p04637.txt | grep -q '^ID ' || { echo "p04637.txt sin línea ID"   >&2; exit 1; }

# El del INSDC tiene que ser p53 HUMANO, no otra cosa. Es exactamente el error
# que traía la especificación, así que se comprueba y no se asume.
head -1 tp53_insdc.gb | grep -q '^LOCUS' || { echo "tp53_insdc.gb no empieza en LOCUS" >&2; exit 1; }
grep -q '^SOURCE      Homo sapiens' tp53_insdc.gb \
  || { echo "OJO: ${ACC_INSDC} no es de Homo sapiens." >&2; exit 1; }
grep -qi '^DEFINITION.*p53' tp53_insdc.gb \
  || { echo "OJO: ${ACC_INSDC} no menciona p53 en su DEFINITION." >&2; exit 1; }
# ...y tiene que estar en el ENA, que es de donde lo bajan en la parada 3.
# Se guarda en una variable en vez de tubear a `head`: cortar el pipe le hace
# devolver curl: (23) y el aviso se confunde con un error de verdad.
ENA_CAB="$(curl -fsS "https://www.ebi.ac.uk/ena/browser/api/embl/${ACC_INSDC}" || true)"
printf '%s\n' "$ENA_CAB" | grep -q "^AC   ${ACC_INSDC};" \
  || { echo "OJO: ${ACC_INSDC} no aparece en el ENA." >&2; exit 1; }
unset ENA_CAB

HOY="$(date +%F)"
LARGO_NT="$(head -1 tp53_refseq.gb | awk '{print $3}')"
LARGO_AA="$(head -1 p04637.txt | awk '{print $4}')"
LARGO_IN="$(head -1 tp53_insdc.gb | awk '{print $3}')"

cat > PROCEDENCIA.md <<EOF
Generado por \`figuras/sesion11/00_descarga_datos.sh\` el ${HOY}.

| Archivo | Accession | Alcance | Fuente | Bajado |
|---|---|---|---|---|
| \`tp53_refseq.gb\` | ${ACC_NT} | completo, formato GenBank | NCBI Nucleotide | ${HOY} |
| \`tp53.fasta\` | ${ACC_NT} | completo, formato FASTA | NCBI Nucleotide | ${HOY} |
| \`tp53_insdc.gb\` | ${ACC_INSDC} | completo, formato GenBank | NCBI Nucleotide | ${HOY} |
| \`p04637.txt\` | ${ACC_UP} | completo, formato texto | UniProtKB | ${HOY} |

Largo del mRNA de RefSeq: ${LARGO_NT} bp. Largo del envío del INSDC:
${LARGO_IN} bp. Largo de la proteína: ${LARGO_AA} aa.

La versión va pegada al accession a propósito: \`${ACC_NT}\`, no \`NM_000546\`.
Es exactamente la disciplina del capítulo de accesiones. Si el NCBI sube la
versión, este script falla en la verificación en vez de bajar otra cosa en
silencio, que es lo que se quiere.

**Sobre \`${ACC_INSDC}\`.** La especificación pedía \`X03495\`, pero ese
accession es mRNA de glutamina sintetasa de *Cricetulus longicaudatus*
(hámster chino), no de p53 humano. Se sustituyó por \`${ACC_INSDC}\`, *Human
mRNA for p53 cellular tumor antigen*, que sí es humano, sí está en el ENA y
además es la primera referencia \`DR EMBL\` del registro ${ACC_UP}. El script
verifica las tres cosas antes de dar por bueno el archivo.

Los datos genómicos pesados (cromosoma 17, GTF, ClinVar, cadena de liftOver)
los baja \`00b_descarga_datos_genomicos.sh\`, que es aparte porque tarda y pesa.
EOF

echo ""
echo "Listo en ${DESTINO}:"
ls -la tp53_refseq.gb tp53.fasta tp53_insdc.gb p04637.txt PROCEDENCIA.md
echo ""
echo "  mRNA RefSeq ${ACC_NT}: ${LARGO_NT} bp"
echo "  envío INSDC ${ACC_INSDC}: ${LARGO_IN} bp"
echo "  proteína ${ACC_UP}: ${LARGO_AA} aa"
echo ""
echo "Para los datos genómicos:  bash figuras/sesion11/00b_descarga_datos_genomicos.sh"
