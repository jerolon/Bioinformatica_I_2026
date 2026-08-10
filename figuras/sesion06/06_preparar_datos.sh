#!/usr/bin/env bash
# Deja los siete FASTA que usa la práctica de la Sesión 6 (alineamiento por
# pares) y escribe un PROCEDENCIA.md al lado, con accession y fecha.
#
#   bash figuras/sesion06/06_preparar_datos.sh                  # a figuras/sesion06/datos
#   bash figuras/sesion06/06_preparar_datos.sh /datos/cursos/bioinfo1/sesion06
#
# Idempotente: si el archivo ya está y no está vacío, no se vuelve a bajar.
#
# ---------------------------------------------------------------------------
# POR QUÉ ESTAS SECUENCIAS Y NO OTRAS
#
# protA / protB      Hemoglobina alfa humana contra mioglobina de pez cebra.
#                    Dos requisitos, no uno. El primero: ~28 % de identidad, o
#                    sea plena zona crepuscular de Rost. El segundo, que es el
#                    que de verdad cuesta: que las TRES puntuaciones del
#                    Ejercicio 3 den alineamientos DISTINTOS. Casi ningún par
#                    de globinas al 28 % lo cumple: BLOSUM45 suele devolver
#                    exactamente el mismo alineamiento que BLOSUM62 y el
#                    ejercicio se queda sin nada que comparar.
#                    Se barrieron 60 x 200 pares de globinas revisadas de
#                    UniProt con needle para encontrarlo. Los números están en
#                    figuras/sesion06/FIGURAS.md.
#                    Son homólogas de verdad (misma familia, mismo plegamiento),
#                    que es justo la lección: homología real, identidad baja.
#
# larga / dominio    PAX6 humana (422 aa) y el homeodominio de eyeless, su
#                    ortólogo en Drosophila (60 aa). El dominio NO se recorta
#                    de la larga: se recorta del ortólogo, con las coordenadas
#                    que anota UniProt (O18381, DNA binding 430..489). Así el
#                    dominio está de verdad contenido y con identidad alta,
#                    pero no es un copiar y pegar de la misma proteína.
#
# genomica / cdna    APOE humana: RefSeqGene NG_007084.2 y su mRNA
#                    NM_000041.4. CUATRO exones. El conteo lo verifica este
#                    mismo script contra el GenBank, no está transcrito.
#                    La genómica va RECORTADA a 4515-9112, o sea el gen con
#                    500 pb de margen de cada lado. Es por la forma del dibujo,
#                    no por capricho: el RefSeqGene completo trae 10.6 kb, de
#                    los que el gen ocupa un tercio, y dottup dibuja una caja
#                    con la proporción de las dos longitudes. Sin recortar sale
#                    una tira de 12 a 1 con las diagonales apiñadas en el
#                    medio; recortada sale una caja de 4 a 1 donde los cuatro
#                    exones se leen. (Se probó también SOD1, con cinco exones:
#                    su gen mide 9.3 kb contra 895 pb de cDNA y ni recortado
#                    baja de 11 a 1. Por eso ganó APOE.)
#
# repetida           Involucrina humana, el ejemplo de libro de repeticiones
#                    internas en tándem. Con -wordsize 6 la autocomparación
#                    sale llena de diagonales paralelas fuera del centro.
# ---------------------------------------------------------------------------
set -euo pipefail

DESTINO="${1:-figuras/sesion06/datos}"
HOY="$(date +%F)"
mkdir -p "$DESTINO"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- Descarga ---------------------------------------------------------------
uniprot() {   # uniprot ACC -> stdout (FASTA crudo)
  curl -sS --fail --retry 3 --retry-delay 2 \
    "https://rest.uniprot.org/uniprotkb/${1}.fasta"
}

ncbi() {      # ncbi ACC TIPO -> stdout
  local acc="$1" tipo="${2:-fasta}"
  if command -v efetch >/dev/null 2>&1; then
    efetch -db nuccore -id "$acc" -format "${tipo/gbwithparts/gb}"
  else
    curl -sS --fail --retry 3 --retry-delay 2 \
      "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${acc}&rettype=${tipo}&retmode=text"
  fi
}

secuencia() { awk '!/^>/{printf "%s", $0} END{print ""}' "$1"; }
plegar()    { fold -w 60; }

#' escribir SALIDA ENCABEZADO < secuencia_en_una_linea
escribir() {
  local salida="$1" enc="$2"
  { printf '>%s\n' "$enc"; plegar; } > "$salida"
}

bajar_proteina() {   # bajar_proteina ARCHIVO ACC ENCABEZADO
  local salida="$DESTINO/$1" acc="$2" enc="$3"
  [ -s "$salida" ] && { echo "ya está   $1"; return; }
  uniprot "$acc" > "$TMP/x.fa"
  secuencia "$TMP/x.fa" | escribir "$salida" "$enc"
  echo "bajado    $1  ($acc)"
  sleep 1
}

bajar_recorte() {    # bajar_recorte ARCHIVO ACC DE A ENCABEZADO
  local salida="$DESTINO/$1" acc="$2" de="$3" a="$4" enc="$5"
  [ -s "$salida" ] && { echo "ya está   $1"; return; }
  uniprot "$acc" > "$TMP/x.fa"
  secuencia "$TMP/x.fa" | cut -c"${de}-${a}" | escribir "$salida" "$enc"
  echo "bajado    $1  ($acc, residuos ${de}-${a})"
  sleep 1
}

bajar_nucleotido() { # bajar_nucleotido ARCHIVO ACC ENCABEZADO [DE A]
  local salida="$DESTINO/$1" acc="$2" enc="$3" de="${4:-}" a="${5:-}"
  [ -s "$salida" ] && { echo "ya está   $1"; return; }
  ncbi "$acc" fasta > "$TMP/x.fa"
  head -n1 "$TMP/x.fa" | grep -q '^>' || { echo "ERROR bajando $acc" >&2; exit 1; }
  if [ -n "$de" ]; then
    secuencia "$TMP/x.fa" | cut -c"${de}-${a}" | escribir "$salida" "$enc"
    echo "bajado    $1  ($acc, posiciones ${de}-${a})"
  else
    secuencia "$TMP/x.fa" | escribir "$salida" "$enc"
    echo "bajado    $1  ($acc)"
  fi
  sleep 1   # cortesía con el NCBI: tres peticiones por segundo y por IP
}

echo "Destino: $DESTINO"
echo

bajar_proteina  protA.fasta    P69905 \
  "protA sp|P69905|HBA_HUMAN Hemoglobina subunidad alfa - Homo sapiens"
bajar_proteina  protB.fasta    Q6VN46 \
  "protB sp|Q6VN46|MYG_DANRE Mioglobina - Danio rerio"
bajar_proteina  larga.fasta    P26367 \
  "larga sp|P26367|PAX6_HUMAN Proteina Pax-6 - Homo sapiens"
bajar_recorte   dominio.fasta  O18381 430 489 \
  "dominio sp|O18381|PAX6_DROME homeodominio, residuos 430-489 - Drosophila melanogaster"
bajar_nucleotido genomica.fasta NG_007084.2 \
  "genomica NG_007084.2 APOE RefSeqGene, posiciones 4515-9112 - Homo sapiens" \
  4515 9112
bajar_nucleotido cdna.fasta     NM_000041.4 \
  "cdna NM_000041.4 APOE mRNA - Homo sapiens"
bajar_proteina  repetida.fasta P07476 \
  "repetida sp|P07476|INVO_HUMAN Involucrina - Homo sapiens"

echo
printf "  %-16s %8s  %s\n" archivo largo encabezado
for f in protA protB larga dominio genomica cdna repetida; do
  r="$DESTINO/$f.fasta"
  printf "  %-16s %8d  %s\n" "$f.fasta" \
    "$(secuencia "$r" | tr -d '\n' | wc -c | tr -d ' ')" \
    "$(head -n1 "$r" | cut -c2-58)"
done


# --- Verificación -----------------------------------------------------------
# Nada de esto es decorativo: son los tres requisitos que la práctica necesita
# que se cumplan. Si alguno falla, el ejercicio correspondiente no enseña nada.
echo
if ! command -v needle >/dev/null 2>&1; then
  echo "AVISO: no hay EMBOSS en esta máquina; no se pudo verificar."
  echo "       En ken:  bash $0 /datos/cursos/bioinfo1/sesion06"
else
  pct() { grep "^# $1" "$2" | sed 's/.*(\(.*\))/\1/'; }
  num() { grep "^# $1" "$2" | awk '{print $3}'; }

  # Los dos renglones alineados, sin la línea de consenso. Comparar la salida
  # entera NO sirve: la línea de en medio (los |, : y .) cambia sola al cambiar
  # de matriz, porque cambia qué cuenta como "similar", y dos alineamientos
  # idénticos parecerían distintos.
  filas() {
    awk 'NF==4 && $3 ~ /^[A-Za-z-]+$/ {f[$1] = f[$1] $3}
         END {for (k in f) print k "=" f[k]}' "$1" | sort
  }

  echo "== Ejercicio 3: protA contra protB (la zona crepuscular) =="
  needle -asequence "$DESTINO/protA.fasta" -bsequence "$DESTINO/protB.fasta" \
    -datafile EBLOSUM62 -gapopen 10 -gapextend 0.5 -outfile "$TMP/b62.needle" -auto
  needle -asequence "$DESTINO/protA.fasta" -bsequence "$DESTINO/protB.fasta" \
    -datafile EBLOSUM45 -gapopen 10 -gapextend 0.5 -outfile "$TMP/b45.needle" -auto
  needle -asequence "$DESTINO/protA.fasta" -bsequence "$DESTINO/protB.fasta" \
    -datafile EBLOSUM62 -gapopen 20 -gapextend 1  -outfile "$TMP/duro.needle" -auto
  printf "  %-24s %6s %9s %10s %7s %7s\n" esquema largo identidad similitud huecos score
  for n in b62 b45 duro; do
    printf "  %-24s %6s %9s %10s %7s %7s\n" "$n" \
      "$(num Length "$TMP/$n.needle")" "$(pct Identity "$TMP/$n.needle")" \
      "$(pct Similarity "$TMP/$n.needle")" "$(pct Gaps "$TMP/$n.needle")" \
      "$(num Score "$TMP/$n.needle")"
  done
  ID=$(pct Identity "$TMP/b62.needle" | tr -d '%')
  awk -v i="$ID" 'BEGIN{
    if (i >= 25 && i <= 31) printf "  OK: %.1f%% de identidad, plena zona crepuscular\n", i;
    else { printf "  FALLA: %.1f%% no es ~28%%. Cambiar el par.\n", i; exit 1 }
  }'
  # Los tres alineamientos tienen que ser DISTINTOS entre sí, que es lo que el
  # Ejercicio 3 pide comprobar. Si dos salieran iguales, no habría nada que ver.
  for par in "b62 b45" "b62 duro" "b45 duro"; do
    set -- $par
    if [ "$(filas "$TMP/$1.needle")" = "$(filas "$TMP/$2.needle")" ]; then
      echo "  FALLA: $1 y $2 dan el MISMO alineamiento." >&2; exit 1
    fi
  done
  echo "  OK: los tres alineamientos difieren entre sí, no sólo el score."

  echo
  echo "== Ejercicio 4: larga contra dominio (global contra local) =="
  needle -asequence "$DESTINO/larga.fasta" -bsequence "$DESTINO/dominio.fasta" \
    -gapopen 10 -gapextend 0.5 -outfile "$TMP/global.needle" -auto
  water  -asequence "$DESTINO/larga.fasta" -bsequence "$DESTINO/dominio.fasta" \
    -gapopen 10 -gapextend 0.5 -outfile "$TMP/local.water" -auto
  printf "  %-10s %6s %8s %8s\n" programa largo identidad huecos
  printf "  %-10s %6s %8s %8s\n" needle \
    "$(num Length "$TMP/global.needle")" "$(pct Identity "$TMP/global.needle")" \
    "$(pct Gaps "$TMP/global.needle")"
  printf "  %-10s %6s %8s %8s\n" water \
    "$(num Length "$TMP/local.water")" "$(pct Identity "$TMP/local.water")" \
    "$(pct Gaps "$TMP/local.water")"
  IDL=$(pct Identity "$TMP/local.water" | tr -d '%')
  LL=$(num Length "$TMP/local.water")
  awk -v i="$IDL" -v l="$LL" 'BEGIN{
    if (i >= 70 && l >= 40 && l <= 80)
      printf "  OK: water lo encuentra completo (%d columnas, %.1f%% de identidad)\n", l, i;
    else { printf "  FALLA: el dominio no está contenido con identidad alta.\n"; exit 1 }
  }'

  echo
  echo "== Ejercicio 5: la estructura de exones =="
  ncbi NG_007084.2 gbwithparts > "$TMP/gen.gb" 2>/dev/null || true
  N_EX=$(grep -cE '^     exon ' "$TMP/gen.gb" || echo 0)
  echo "  NG_007084.2 declara $N_EX exones en su GenBank"
  [ "$N_EX" -ge 4 ] && [ "$N_EX" -le 5 ] \
    && echo "  OK: cuatro o cinco exones, que es lo que el dot plot tiene que mostrar" \
    || { echo "  FALLA: se esperaban 4 o 5 exones." >&2; exit 1; }
  # Y que el recorte no se haya comido ninguno: los cuatro tienen que caer
  # dentro de la ventana 4515-9112.
  awk '/^     exon /{split($2,p,"\\.\\."); gsub(/[^0-9]/,"",p[1]); gsub(/[^0-9]/,"",p[2]);
       if (p[1] < 4515 || p[2] > 9112) fuera++; n++}
       END{ if (fuera) { printf "  FALLA: %d de %d exones quedan fuera del recorte\n", fuera, n; exit 1 }
            else printf "  OK: los %d exones caen dentro del recorte 4515-9112\n", n }' "$TMP/gen.gb"
fi


# --- PROCEDENCIA ------------------------------------------------------------
cat > "$DESTINO/PROCEDENCIA.md" <<EOF
# Procedencia de los datos — Sesión 6, alineamiento por pares

Generado por \`figuras/sesion06/06_preparar_datos.sh\` el $HOY.
No se edita a mano: se vuelve a correr el script.

| Archivo | Accession | Recorte | Fuente | Descargado |
|---|---|---|---|---|
| \`protA.fasta\` | P69905 (HBA_HUMAN) | completa | UniProtKB | $HOY |
| \`protB.fasta\` | Q6VN46 (MYG_DANRE) | completa | UniProtKB | $HOY |
| \`larga.fasta\` | P26367 (PAX6_HUMAN) | completa | UniProtKB | $HOY |
| \`dominio.fasta\` | O18381 (PAX6_DROME) | residuos 430-489 | UniProtKB | $HOY |
| \`genomica.fasta\` | NG_007084.2 (APOE) | posiciones 4515-9112 | NCBI Nucleotide | $HOY |
| \`cdna.fasta\` | NM_000041.4 (APOE) | completa | NCBI Nucleotide | $HOY |
| \`repetida.fasta\` | P07476 (INVO_HUMAN) | completa | UniProtKB | $HOY |

## Por qué cada una

- **protA / protB.** Hemoglobina alfa humana contra mioglobina de pez cebra:
  ~28 % de identidad, plena zona crepuscular. Homólogas de verdad, identidad
  baja. Además —y esto costó más de encontrar que el 28 %— los tres esquemas
  de puntuación del Ejercicio 3 dan tres alineamientos **distintos**, con
  17.1 %, 14.7 % y 11.1 % de huecos. Con casi cualquier otro par de globinas
  al 28 %, BLOSUM45 devuelve exactamente el mismo alineamiento que BLOSUM62 y
  el ejercicio se queda sin nada que comparar.
- **larga / dominio.** PAX6 humana (422 aa) y el homeodominio de su ortólogo
  de *Drosophila* (eyeless, 60 aa). El recorte 430-489 son las coordenadas que
  anota UniProt para ese dominio, no un corte inventado. El dominio no se saca
  de \`larga.fasta\`: viene de otra proteína, así que la identidad es alta pero
  no del 100 %.
- **genomica / cdna.** APOE humana, cuatro exones. La genómica va recortada al
  gen con 500 pb de margen (4515-9112 del RefSeqGene) porque \`dottup\` dibuja
  una caja con la proporción de las dos longitudes: con el registro completo
  (10.6 kb contra 1.2 kb) sale una tira ilegible, y recortada sale una caja de
  4 a 1 donde los cuatro exones se distinguen. El script comprueba que los
  cuatro exones queden dentro de la ventana.
- **repetida.** Involucrina humana, con repeticiones internas en tándem.

## Encabezados

Se reescribieron para que el primer campo sea el nombre corto que usan los
comandos de la práctica (\`protA\`, \`dominio\`, ...). El accession original va
en la descripción, en el mismo renglón, para que nada pierda su rastro.
EOF

echo
echo "Escrito $DESTINO/PROCEDENCIA.md"
