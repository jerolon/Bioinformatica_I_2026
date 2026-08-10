## Fig. @fig-flatfile (Sesión 11, § Cómo se lee un registro)
## Anatomía de un GenBank flat file: el registro REAL de TP53, recortado a las
## líneas representativas, con llaves de color señalando cada sección.
##
## ---------------------------------------------------------------------------
## LAS LÍNEAS NO ESTÁN TRANSCRITAS
##
## Todo lo que se dibuja sale de `datos/tp53.gb` con las reglas del formato, no
## de una copia pegada acá. Importa por dos razones:
##
##   1. Si el NCBI cambia el registro (y NM_000546 ya va en su versión 6), la
##      figura cambia con él o truena, pero no miente.
##   2. El capítulo enseña a leer un flat file. Una figura con líneas inventadas
##      enseñaría a leer un formato que no existe.
##
## La única concesión es la ELISIÓN: el registro trae 706 líneas y 26 no caben
## de otra forma. Los cortes se marcan con ⋮ y se cuentan, para que se vea que
## se saltó algo y cuánto.
## ---------------------------------------------------------------------------
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  bash figuras/sesion11/00_descarga_datos.sh   # una vez
##             Rscript figuras/sesion11/01_flatfile.R

.ubicar <- function() {
  for (i in rev(seq_len(sys.nframe()))) {
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar el script: correr con Rscript o con source()")
}
source(file.path(dirname(.ubicar()), "_tema.R"))


# --- El registro, leído ------------------------------------------------------
gb <- readLines(ruta_datos("tp53_refseq.gb"), warn = FALSE)

# efetch cierra el registro con "//" y deja UNA línea en blanco después. Se
# recorta para que length(gb) sea el largo del registro y no el del archivo:
# la cifra sale impresa en el caption de la figura y tiene que ser la honesta.
while (length(gb) && !nzchar(trimws(gb[length(gb)]))) gb <- gb[-length(gb)]

# Localizadores por regla del formato, no por número de línea: las palabras
# clave de primer nivel arrancan en la columna 1, los qualifiers llevan 21
# espacios. Si el registro crece, esto sigue apuntando a lo correcto.
.primera <- function(patron) {
  i <- grep(patron, gb)
  if (!length(i)) stop("no se encontró en tp53.gb: ", patron, call. = FALSE)
  i[1]
}

i_locus  <- .primera("^LOCUS ")
i_defin  <- .primera("^DEFINITION ")
i_acc    <- .primera("^ACCESSION ")
i_ver    <- .primera("^VERSION ")
i_keyw   <- .primera("^KEYWORDS ")
i_source <- .primera("^SOURCE ")
i_organ  <- .primera("^  ORGANISM ")
i_ref1   <- .primera("^REFERENCE ")
i_auth   <- .primera("^  AUTHORS ")
i_feat   <- .primera("^FEATURES ")
i_fsrc   <- .primera("^     source  ")
i_gene   <- .primera("^     gene  ")
i_cds    <- .primera("^     CDS  ")
i_trad   <- .primera('^ +/translation="')
i_prodid <- .primera('^ +/protein_id="')
i_prod   <- .primera('^ +/product="')
i_origin <- .primera("^ORIGIN")

# El linaje va justo debajo de ORGANISM; se toma la primera línea de
# continuación, que es la que muestra que ahí vive la taxonomía.
i_linaje <- i_organ + 1L

# --- El recorte --------------------------------------------------------------
# Cada fila: la línea real, a qué sección pertenece, y si es una elisión.
.f <- function(i, seccion) data.frame(txt = gb[i], sec = seccion,
                                      elide = FALSE, stringsAsFactors = FALSE)
.e <- function(n, seccion) data.frame(txt = sprintf("      ⋮   (%d líneas más)", n),
                                      sec = seccion, elide = TRUE,
                                      stringsAsFactors = FALSE)

recorte <- rbind(
  .f(i_locus,  "LOCUS"),
  .f(i_defin,  "DEFINITION"),
  .f(i_acc,    "ACCESSION"),
  .f(i_ver,    "VERSION"),
  .f(i_keyw,   "KEYWORDS"),
  .f(i_source, "SOURCE"),
  .f(i_organ,  "SOURCE"),
  .f(i_linaje, "SOURCE"),
  .f(i_ref1,   "REFERENCE"),
  .f(i_auth,   "REFERENCE"),
  .e(i_feat - i_auth - 1L, "REFERENCE"),
  .f(i_feat,   "FEATURES"),
  .f(i_fsrc,   "FEATURES"),
  .f(i_fsrc + 1L, "FEATURES"),
  .f(i_gene,   "FEATURES"),
  .f(i_gene + 1L, "FEATURES"),
  .f(i_cds,    "CDS"),
  .f(i_prod,   "CDS"),
  .f(i_prodid, "CDS"),
  .f(i_trad,   "CDS"),
  .f(i_trad + 1L, "CDS"),
  .e(i_origin - i_trad - 2L, "CDS"),
  .f(i_origin, "ORIGIN"),
  .f(i_origin + 1L, "ORIGIN")
)
recorte$i <- seq_len(nrow(recorte))

# El flat file es de 80 columnas; se recorta con … lo que se pase, que en la
# práctica es sólo alguna línea de qualifier muy larga.
ANCHO_MAX <- 80L
recorte$corta <- nchar(recorte$txt) > ANCHO_MAX
recorte$vis <- ifelse(recorte$corta,
                      paste0(substr(recorte$txt, 1, ANCHO_MAX - 1), "…"),
                      recorte$txt)


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 12) con 2 mm de margen: panel de 156 x 116 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 116

# El flat file es de 80 columnas y los rótulos de sección piden ~33 mm a la
# derecha. Con TAM_MONO = 2.3 el rótulo más largo se salía del panel por 2 mm
# (lo atrapó el stopifnot). Se baja el mono en vez de recortar el registro:
# perder columnas del formato sería perder justo lo que la figura enseña.
TAM_MONO <- 2.15
CHAR <- TAM_MONO * AVANCE_MONO        # ancho de un carácter mono, en mm
INTERLINEA <- 3.5

X_TXT  <- 6                           # borde izquierdo del texto
X_CAJA <- c(3, X_TXT + ANCHO_MAX * CHAR + 2)

Y_TOPE <- 104                         # línea de base de la primera fila
recorte$y <- Y_TOPE - (recorte$i - 1) * INTERLINEA

X_LLAVE <- X_CAJA[2] + 2.5            # las llaves, pegadas a la caja
PROF_LLAVE <- 2.2
X_ETIQ  <- X_LLAVE + PROF_LLAVE + 2.0

TAM_ETIQ <- 2.05
TAM_NOTA <- 2.2

SANS <- familia_base()
MONO <- familia_mono()


# --- Las llaves de sección ---------------------------------------------------
# Una por sección, abarcando de su primera a su última fila. El color dice qué
# tipo de cosa es: NARANJA lo que el capítulo de accesiones va a cobrar, VERDE
# la anotación, AZUL el resto de la cabecera.
secciones <- data.frame(
  sec = c("LOCUS", "DEFINITION", "ACCESSION", "VERSION", "KEYWORDS",
          "SOURCE", "REFERENCE", "FEATURES", "CDS", "ORIGIN"),
  etiqueta = c("LOCUS\nnombre, largo, tipo, fecha",
               "DEFINITION\ndescripción legible",
               "ACCESSION\nla dirección estable",
               "VERSION\nsube si cambia la secuencia",
               "KEYWORDS",
               "SOURCE / ORGANISM\norganismo y linaje",
               "REFERENCE\nartículos asociados",
               "FEATURES\nla anotación",
               "CDS\nregión codificante,\ncon su /translation",
               "ORIGIN\nla secuencia, numerada"),
  color = c(AZUL, AZUL, AZUL, NARANJA, GRIS, AZUL, AZUL, VERDE, VERDE, AZUL),
  grueso = c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE),
  stringsAsFactors = FALSE
)

rangos <- do.call(rbind, lapply(secciones$sec, function(s) {
  f <- recorte[recorte$sec == s, ]
  data.frame(sec = s, y0 = min(f$y) - 1.2, y1 = max(f$y) + 1.2,
             ymid = (min(f$y) + max(f$y)) / 2, stringsAsFactors = FALSE)
}))
secciones <- merge(secciones, rangos, by = "sec", sort = FALSE)
secciones <- secciones[match(rangos$sec, secciones$sec), ]

llaves <- do.call(rbind, lapply(seq_len(nrow(secciones)), function(k) {
  transform(llave_v(secciones$y0[k], secciones$y1[k], X_LLAVE, PROF_LLAVE,
                    izquierda = FALSE),
            id = k, col = secciones$color[k])
}))


# --- Anti-colisión de los rótulos -------------------------------------------
# LOCUS, DEFINITION, ACCESSION y VERSION ocupan UNA línea del registro (3.5 mm
# de alto) pero su rótulo son dos (~6 mm). A la altura exacta de su llave no
# caben: se encimaban y la figura salía ilegible por arriba. (No lo atrapó
# ningún stopifnot de la primera versión, que sólo medía el ancho — se vio al
# mirar el PNG. De ahí la comprobación de solapamiento vertical de abajo.)
#
# Se recorren de arriba hacia abajo empujando hacia abajo al que choca, y se
# dibuja un conector fino desde la llave hasta el rótulo cuando se movió.
ALTO_LINEA_ETIQ <- TAM_ETIQ * 1.45
GAP_ETIQ <- 0.7

secciones$n_lineas <- lengths(strsplit(secciones$etiqueta, "\n", fixed = TRUE))
secciones$alto  <- secciones$n_lineas * ALTO_LINEA_ETIQ
secciones$y_lab <- secciones$ymid

orden <- order(-secciones$ymid)
for (k in seq_along(orden)[-1]) {
  prev <- orden[k - 1]; act <- orden[k]
  tope <- secciones$y_lab[prev] - secciones$alto[prev] / 2 - GAP_ETIQ
  if (secciones$y_lab[act] + secciones$alto[act] / 2 > tope) {
    secciones$y_lab[act] <- tope - secciones$alto[act] / 2
  }
}
secciones$movido <- abs(secciones$y_lab - secciones$ymid) > 0.6

conectores <- do.call(rbind, lapply(which(secciones$movido), function(k) {
  data.frame(x = X_LLAVE + PROF_LLAVE + 0.3, y = secciones$ymid[k],
             xend = X_ETIQ - 0.6, yend = secciones$y_lab[k],
             col = secciones$color[k], stringsAsFactors = FALSE)
}))


# --- El resalte de VERSION ---------------------------------------------------
fila_ver <- recorte[recorte$sec == "VERSION", ]
fila_cds <- recorte[recorte$txt == gb[i_cds], ]

# La caja naranja abraza sólo el texto de la línea, no el ancho completo.
resalte_ver <- data.frame(
  xmin = X_TXT - 0.8,
  xmax = X_TXT + nchar(fila_ver$txt) * CHAR + 0.8,
  ymin = fila_ver$y - 1.5, ymax = fila_ver$y + 1.5
)

# La nota que explica el naranja, abajo a la izquierda.
TXT_NOTA <- paste0("El .6 es la VERSIÓN. Sube en uno cada vez que cambia la ",
                   "secuencia:\nesta referencia se ha corregido cinco veces.")


construir <- function() {
  ggplot() +
    # --- La caja del registro ---
    annotate("rect", xmin = X_CAJA[1], xmax = X_CAJA[2],
             ymin = min(recorte$y) - 2.6, ymax = max(recorte$y) + 2.6,
             fill = alpha(AZUL_CLARO, 0.08), colour = alpha(GRIS, 0.45),
             linewidth = 0.3) +

    # --- Resalte de la línea VERSION, detrás del texto ---
    geom_rect(data = resalte_ver,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = alpha(NARANJA, 0.20), colour = NA) +

    # --- Las líneas reales del registro ---
    geom_text(data = recorte[!recorte$elide, ],
              aes(x = X_TXT, y = y, label = vis),
              family = MONO, size = TAM_MONO, colour = TEXTO, hjust = 0) +
    # Las elisiones, en gris y en cursiva: se ven como lo que son.
    geom_text(data = recorte[recorte$elide, ],
              aes(x = X_TXT, y = y, label = vis),
              family = MONO, size = TAM_MONO * 0.92, colour = alpha(GRIS, 0.8),
              hjust = 0, fontface = "italic") +

    # --- Las llaves ---
    geom_path(data = llaves, aes(x = x, y = y, group = id, colour = I(col)),
              linewidth = 0.4, lineend = "round") +

    # --- Conectores de los rótulos que hubo que desplazar ---
    geom_segment(data = conectores,
                 aes(x = x, y = y, xend = xend, yend = yend, colour = I(col)),
                 linewidth = 0.25, linetype = "dotted") +

    # --- Los rótulos de sección ---
    geom_text(data = secciones,
              aes(x = X_ETIQ, y = y_lab, label = etiqueta, colour = I(color),
                  fontface = ifelse(grueso, "bold", "plain")),
              family = SANS, size = TAM_ETIQ, hjust = 0, lineheight = 1.12) +

    # --- La nota del naranja ---
    geom_text(data = data.frame(1), aes(x = X_CAJA[1], y = 6),
              label = TXT_NOTA, family = SANS, size = TAM_NOTA,
              colour = NARANJA, hjust = 0, lineheight = 1.1) +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = sprintf(paste("%s (RefSeq, MANE Select), %d líneas en total,",
                                 "recortado a %d. Los cortes van marcados con",
                                 "⋮ y cuentan\nlo que se saltaron. Ninguna",
                                 "línea está transcrita: todas se leen del",
                                 "archivo."),
                           sub("^VERSION +", "", gb[i_ver]), length(gb),
                           sum(!recorte$elide))) +
    tema_esquema()
}


if (!interactive()) {
  ACC_VER <- sub("^VERSION +", "", gb[i_ver])
  m_etiq  <- media_ancho(secciones$etiqueta, TAM_ETIQ)
  m_nota  <- media_ancho(TXT_NOTA, TAM_NOTA)

  stopifnot(
    # --- El registro es el que creemos ---
    grepl("^LOCUS", gb[1]),
    gb[length(gb)] == "//",
    ACC_VER == "NM_000546.6",              # si sube de versión, hay que verlo
    grepl("2512 bp", gb[i_locus]),
    grepl("Homo sapiens", gb[i_defin]),
    grepl("^ORIGIN", gb[i_origin]),

    # --- El orden del formato se respeta ---
    i_locus < i_defin, i_defin < i_acc, i_acc < i_ver, i_ver < i_keyw,
    i_keyw < i_source, i_source < i_organ, i_organ < i_ref1,
    i_ref1 < i_feat, i_feat < i_cds, i_cds < i_trad, i_trad < i_origin,

    # --- El recorte ---
    nrow(recorte) == 24L,
    sum(recorte$elide) == 2L,
    all(nchar(recorte$vis) <= ANCHO_MAX),
    all(!is.na(recorte$txt)),

    # --- Nada se sale del panel, nada se encima ---
    X_CAJA[2] < X_LLAVE,
    X_ETIQ + 2 * max(m_etiq) <= ANCHO_PANEL,
    max(recorte$y) + 2.6 <= ALTO_PANEL,
    min(recorte$y) - 2.6 > 6 + TAM_NOTA * 2,   # la caja no pisa la nota
    X_CAJA[1] + 2 * m_nota <= ANCHO_PANEL,
    all(secciones$y0 < secciones$y1),

    # --- Los rótulos no se encinan entre sí. Esta es la comprobación que
    #     faltaba en la primera versión: los cuatro de arriba se solapaban y
    #     sólo se vio mirando el PNG. Ahora truena. ---
    {
      s <- secciones[order(-secciones$y_lab), ]
      all(head(s$y_lab - s$alto / 2, -1) >= tail(s$y_lab + s$alto / 2, -1) - 1e-9)
    },
    # ... y ninguno se sale por arriba ni por abajo
    max(secciones$y_lab + secciones$alto / 2) <= ALTO_PANEL,
    min(secciones$y_lab - secciones$alto / 2) >= 0
  )

  message(sprintf("  registro: %s (%d líneas, %d recortadas a la figura)",
                  ACC_VER, length(gb), sum(!recorte$elide)))
  message(sprintf("  LOCUS:    %s", trimws(gb[i_locus])))
  message(sprintf("  elisiones: %s",
                  paste(recorte$vis[recorte$elide], collapse = " / ")))
  message(sprintf("  líneas recortadas por ancho (> %d col): %d",
                  ANCHO_MAX, sum(recorte$corta)))
  message(sprintf("  secciones marcadas: %s",
                  paste(secciones$sec, collapse = ", ")))

  escribir_tsv(
    data.frame(seccion = recorte$sec, elision = recorte$elide,
               linea = recorte$txt, stringsAsFactors = FALSE),
    "flatfile-anotado")
  guardar(construir(), "flatfile-anotado", 16, 12)
}
