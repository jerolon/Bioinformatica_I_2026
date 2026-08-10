## Fig. @fig-formatos (Sesión 2-3, § Los formatos: un mapa)
## Los formatos ubicados sobre el flujo de un análisis, no como lista.
##
## Esquema puro. La única "cuenta" es la geometría: el ancho de cada grupo de
## etapa sale de cuántas cajas lleva, y las cuatro etapas se reparten el panel
## con huecos iguales. Si mañana se agrega un formato a una etapa, la fila se
## reacomoda sola y los stopifnot avisan si algo se sale o se encima.
##
## Tres decisiones de codificación que conviene no "limpiar":
##
##   - El borde distingue TEXTO de BINARIO (relleno sólido y trazo más grueso).
##     Por eso SAM/BAM/CRAM van en tres cajas y no en una: en una sola no se
##     podría decir que SAM es texto y los otros dos no.
##   - El "0-based" de BED va en NARANJA, pero su BORDE sigue siendo azul de
##     formato de texto. El borde ya codifica texto/binario; si además marcara
##     la excepción, una caja estaría diciendo dos cosas con el mismo canal.
##   - FASTA y GenBank van DEBAJO de la línea punteada porque no pertenecen a
##     una etapa: alimentan a varias.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion02/05_mapa_formatos.R

.ubicar <- function() {
  for (i in rev(seq_len(sys.nframe()))) {   # de adentro hacia afuera
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar el script: correr con Rscript o con source()")
}
source(file.path(dirname(.ubicar()), "_tema.R"))


# --- Lo que afirma la figura ------------------------------------------------
# Único lugar donde se teclean los formatos. `coord` es exactamente lo que dice
# la tabla del capítulo, y `binario` lo que dice su columna "texto o binario".
ETAPAS <- c("Secuenciar", "Alinear", "Llamar variantes", "Interpretar")

FORMATOS <- data.frame(
  etapa   = c(1L,
              2L, 2L, 2L,
              3L, 3L,
              4L, 4L, 4L),
  nombre  = c("FASTQ",
              "SAM", "BAM", "CRAM",
              "VCF", "BCF",
              "GFF3", "GTF", "BED"),
  coord   = c("no aplica",
              "1-based", "1-based", "1-based",
              "1-based", "1-based",
              "1-based", "1-based", "0-based"),
  binario = c(FALSE,
              FALSE, TRUE, TRUE,
              FALSE, TRUE,
              FALSE, FALSE, FALSE),
  stringsAsFactors = FALSE
)

# Las dos cajas de referencia: no son una etapa, alimentan a varias.
REFERENCIAS <- data.frame(
  nombre  = c("FASTA", "GenBank / EMBL"),
  glosa   = c("la secuencia de referencia", "secuencia y anotación"),
  coord   = c("no aplica", "1-based"),
  binario = c(FALSE, FALSE),
  # A qué etapas alimenta cada una. FASTA es el sustrato de alinear, llamar
  # variantes e interpretar; GenBank no cuelga de ninguna etapa en particular.
  alimenta = I(list(2:4, integer(0))),
  stringsAsFactors = FALSE
)

# La excepción que el capítulo quiere que se recuerde.
EXCEPCION <- "0-based"


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 10) con 2 mm de margen a los lados: panel de 156 x 92 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 92

W_CAJA   <- 14      # cada caja de formato
H_CAJA   <- 11
SEP_CAJA <- 2       # entre cajas de la misma etapa

Y_CAJA_MIN <- 68
Y_CAJA_MAX <- Y_CAJA_MIN + H_CAJA         # 68 .. 79
Y_ETAPA    <- 86                          # rótulos de etapa y flechas del flujo

Y_PUNTEADA <- 56                          # separa el flujo de las referencias
Y_REF_MIN  <- 30
Y_REF_MAX  <- 48
W_REF      <- c(34, 42)
X_REF      <- c(18, 100)

Y_LEYENDA  <- 18
W_LEY      <- 9
H_LEY      <- 5.5
X_LEYENDA  <- c(8, 52)

TAM_ETAPA  <- 2.4
TAM_NOMBRE <- 2.5    # el nombre del formato: es código, va monoespaciado
TAM_COORD  <- 1.8
TAM_GLOSA  <- 1.8
TAM_LEY    <- 2.0
TAM_NOTA   <- 1.9

SANS <- familia_base()
MONO <- familia_mono()

# --- Reparto horizontal de las cuatro etapas --------------------------------
# El ancho de cada grupo sale de cuántas cajas lleva; el sobrante se reparte en
# huecos iguales entre grupos. Nada de posiciones a ojo.
#
# SANGRIA: la fila no arranca en x = 0. El borde de la primera caja caería justo
# sobre el borde del panel y el trazo se corta a la mitad al recortar el SVG.
SANGRIA   <- 1
UTIL      <- ANCHO_PANEL - 2 * SANGRIA

n_por_etapa <- as.integer(table(factor(FORMATOS$etapa, levels = seq_along(ETAPAS))))
w_grupo     <- n_por_etapa * W_CAJA + (n_por_etapa - 1) * SEP_CAJA
HUECO       <- (UTIL - sum(w_grupo)) / (length(ETAPAS) - 1)

x_ini_grupo <- SANGRIA + c(0, head(cumsum(w_grupo + HUECO), -1))
grupos <- data.frame(
  etapa = seq_along(ETAPAS),
  nombre = ETAPAS,
  xmin  = x_ini_grupo,
  xmax  = x_ini_grupo + w_grupo,
  stringsAsFactors = FALSE
)
grupos$x <- (grupos$xmin + grupos$xmax) / 2

# --- Cajas de formato -------------------------------------------------------
cajas <- FORMATOS
cajas$k <- ave(seq_len(nrow(cajas)), cajas$etapa, FUN = seq_along) - 1L
cajas$xmin <- grupos$xmin[cajas$etapa] + cajas$k * (W_CAJA + SEP_CAJA)
cajas$xmax <- cajas$xmin + W_CAJA
cajas$x    <- (cajas$xmin + cajas$xmax) / 2
cajas$excepcion <- cajas$coord == EXCEPCION

# --- Flechas del flujo, entre rótulos de etapa ------------------------------
# Arrancan y terminan librando el texto de cada rótulo, calculado con su ancho.
m_etapa <- media_ancho(ETAPAS, TAM_ETAPA)
flujo <- data.frame(
  x    = grupos$x[-length(ETAPAS)] + m_etapa[-length(ETAPAS)] + 3,
  xend = grupos$x[-1]              - m_etapa[-1]              - 3
)

# --- Cajas de referencia ----------------------------------------------------
refs <- transform(REFERENCIAS, xmin = X_REF, xmax = X_REF + W_REF,
                  ymin = Y_REF_MIN, ymax = Y_REF_MAX)
refs$x <- (refs$xmin + refs$xmax) / 2

# Flechas tenues de FASTA hacia las etapas que alimenta. Salen del borde
# superior de su caja y llegan bajo el grupo correspondiente.
alimenta <- do.call(rbind, lapply(seq_len(nrow(refs)), function(i) {
  destinos <- refs$alimenta[[i]]
  if (!length(destinos)) return(NULL)
  data.frame(x = refs$x[i], y = refs$ymax[i] + 0.5,
             xend = grupos$x[destinos], yend = Y_CAJA_MIN - 1.5)
}))

# --- Leyenda de la codificación ---------------------------------------------
leyenda <- data.frame(
  x       = X_LEYENDA,
  binario = c(FALSE, TRUE),
  txt     = c("formato de texto", "formato binario"),
  stringsAsFactors = FALSE
)

NOTA_REF <- "no pertenecen a una etapa: alimentan a varias"


construir <- function() {
  # Helper: dibuja un conjunto de cajas con la codificación texto/binario.
  # Se usa tres veces (formatos, referencias, leyenda) y por eso vive acá.
  capa_cajas <- function(d, grosor_texto = 0.45, grosor_bin = 0.8) {
    list(
      geom_rect(data = subset(d, !binario),
                aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
                fill = NA, colour = AZUL, linewidth = grosor_texto),
      geom_rect(data = subset(d, binario),
                aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
                fill = alpha(AZUL, 0.16), colour = AZUL, linewidth = grosor_bin)
    )
  }

  cajas$ymin <- Y_CAJA_MIN; cajas$ymax <- Y_CAJA_MAX
  ley <- transform(leyenda, xmin = x, xmax = x + W_LEY,
                   ymin = Y_LEYENDA - H_LEY / 2, ymax = Y_LEYENDA + H_LEY / 2)

  ggplot() +
    # --- Rótulos de etapa y flechas del flujo ---
    geom_text(data = grupos, aes(x = x, y = Y_ETAPA, label = nombre),
              family = SANS, size = TAM_ETAPA, colour = TEXTO) +
    geom_segment(data = flujo, aes(x = x, xend = xend, y = Y_ETAPA, yend = Y_ETAPA),
                 colour = GRIS, linewidth = 0.4, arrow.fill = GRIS,
                 arrow = arrow(length = unit(1.6, "mm"), type = "closed")) +

    # --- Las cajas de formato ---
    capa_cajas(cajas) +
    geom_text(data = cajas, aes(x = x, y = Y_CAJA_MIN + H_CAJA * 0.62,
                                label = nombre),
              family = MONO, size = TAM_NOMBRE, colour = TEXTO) +
    geom_text(data = cajas, aes(x = x, y = Y_CAJA_MIN + H_CAJA * 0.26,
                                label = coord, colour = excepcion),
              family = SANS, size = TAM_COORD, show.legend = FALSE) +

    # --- La línea que separa el flujo de las referencias ---
    geom_segment(data = data.frame(1),
                 aes(x = 0, xend = ANCHO_PANEL, y = Y_PUNTEADA, yend = Y_PUNTEADA),
                 colour = GRIS, linewidth = 0.3, linetype = "dotted") +
    geom_text(data = data.frame(1), aes(x = ANCHO_PANEL, y = Y_PUNTEADA - 3),
              label = NOTA_REF, family = SANS, size = TAM_NOTA, colour = GRIS,
              hjust = 1) +

    # --- Flechas tenues de FASTA hacia las etapas ---
    geom_segment(data = alimenta, aes(x = x, xend = xend, y = y, yend = yend),
                 colour = alpha(GRIS, 0.55), linewidth = 0.25,
                 arrow = arrow(length = unit(1.3, "mm"), type = "open")) +

    # --- Las cajas de referencia ---
    capa_cajas(refs) +
    geom_text(data = refs, aes(x = x, y = Y_REF_MIN + 12.6, label = nombre),
              family = MONO, size = TAM_NOMBRE, colour = TEXTO) +
    geom_text(data = refs, aes(x = x, y = Y_REF_MIN + 8.2, label = glosa),
              family = SANS, size = TAM_GLOSA, colour = GRIS) +
    geom_text(data = refs, aes(x = x, y = Y_REF_MIN + 4.4, label = coord),
              family = SANS, size = TAM_COORD, colour = GRIS) +

    # --- Leyenda de la codificación del borde ---
    capa_cajas(ley) +
    geom_text(data = ley, aes(x = xmax + 2, y = Y_LEYENDA, label = txt),
              family = SANS, size = TAM_LEY, colour = TEXTO, hjust = 0) +
    geom_text(data = data.frame(1), aes(x = X_LEYENDA[1], y = Y_LEYENDA - 8),
              label = paste0("El ", EXCEPCION, " de BED va en naranja: es la",
                             " única excepción de coordenadas de todo el mapa."),
              family = SANS, size = TAM_NOTA, colour = NARANJA, hjust = 0) +

    scale_colour_manual(values = c(`FALSE` = GRIS, `TRUE` = NARANJA),
                        guide = "none") +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = "FASTA se trata a fondo en la sesión de formatos de secuencia.") +
    tema_esquema()
}


if (!interactive()) {
  m_nombre <- media_ancho(cajas$nombre, TAM_NOMBRE, AVANCE_MONO)
  m_coord  <- media_ancho(cajas$coord,  TAM_COORD,  AVANCE_SANS)
  m_glosa  <- media_ancho(refs$glosa,   TAM_GLOSA,  AVANCE_SANS)
  m_ref    <- media_ancho(refs$nombre,  TAM_NOMBRE, AVANCE_MONO)
  m_nota   <- media_ancho(NOTA_REF,     TAM_NOTA,   AVANCE_SANS)

  stopifnot(
    # --- Lo que la figura afirma ---
    length(ETAPAS) == 4L,
    nrow(FORMATOS) == 9L,
    identical(sort(unique(FORMATOS$etapa)), seq_along(ETAPAS)),
    # los binarios son exactamente BAM, CRAM y BCF
    identical(sort(FORMATOS$nombre[FORMATOS$binario]), c("BAM", "BCF", "CRAM")),
    # y BED es el único 0-based del mapa
    identical(FORMATOS$nombre[FORMATOS$coord == EXCEPCION], "BED"),
    sum(cajas$excepcion) == 1L,
    # SAM, BAM y CRAM viven en la misma etapa; VCF y BCF también
    length(unique(FORMATOS$etapa[FORMATOS$nombre %in% c("SAM", "BAM", "CRAM")])) == 1L,
    length(unique(FORMATOS$etapa[FORMATOS$nombre %in% c("VCF", "BCF")])) == 1L,
    nrow(refs) == 2L,
    nrow(alimenta) == 3L,                     # FASTA alimenta 3 etapas

    # --- El reparto horizontal cierra ---
    # El hueco entre etapas tiene que ser bastante mayor que el que hay entre
    # cajas de la misma etapa; si no, los cuatro grupos se leen como una fila
    # continua de nueve cajas y la figura pierde su punto.
    HUECO > 2 * SEP_CAJA,
    isTRUE(all.equal(max(grupos$xmax), ANCHO_PANEL - SANGRIA)),
    min(grupos$xmin) >= SANGRIA,
    all(diff(sort(cajas$xmin)) >= W_CAJA),    # ninguna caja se encima con otra
    all(cajas$xmax <= ANCHO_PANEL),

    # --- El texto cabe en su caja ---
    all(2 * m_nombre < W_CAJA - 1.5),
    all(2 * m_coord  < W_CAJA - 1.5),
    all(2 * m_ref    < W_REF - 2),
    all(2 * m_glosa  < W_REF - 2),
    # y los rótulos de etapa caben sobre su grupo, con la flecha en medio
    all(flujo$xend - flujo$x > 4),

    # --- Nada se sale del panel, nada se encima en vertical ---
    Y_ETAPA + TAM_ETAPA <= ALTO_PANEL,
    Y_CAJA_MAX < Y_ETAPA - TAM_ETAPA,
    Y_REF_MAX < Y_PUNTEADA - 2,
    Y_PUNTEADA < Y_CAJA_MIN - 2,
    Y_LEYENDA + H_LEY / 2 < Y_REF_MIN - 2,
    Y_LEYENDA - 8 - TAM_NOTA >= 0,
    ANCHO_PANEL - 2 * m_nota >= max(refs$xmax) - 40,   # la nota no tapa GenBank
    max(refs$xmax) <= ANCHO_PANEL, min(refs$xmin) >= 0,
    max(X_LEYENDA + W_LEY) < ANCHO_PANEL
  )

  message(sprintf("  %d etapas, %d formatos (%d binarios), %d referencias",
                  length(ETAPAS), nrow(FORMATOS), sum(FORMATOS$binario), nrow(refs)))
  for (e in seq_along(ETAPAS)) {
    message(sprintf("    %-18s %s", ETAPAS[e],
                    paste(FORMATOS$nombre[FORMATOS$etapa == e], collapse = " / ")))
  }
  message(sprintf("  grupos de %s mm; hueco entre etapas: %.1f mm",
                  paste(w_grupo, collapse = ", "), HUECO))
  message(sprintf("  única excepción de coordenadas: %s (%s)",
                  paste(cajas$nombre[cajas$excepcion], collapse = ", "), EXCEPCION))
  message(sprintf("  familia monoespaciada: %s", MONO))

  guardar(construir(), "mapa-formatos", 16, 10)
}
