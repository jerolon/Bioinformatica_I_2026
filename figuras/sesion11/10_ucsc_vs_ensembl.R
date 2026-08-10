## Fig. @fig-ucsc-ensembl (Sesión 11, § UCSC contra Ensembl)
## Tabla comparativa de dos columnas, con el mnemónico abajo.
##
## ---------------------------------------------------------------------------
## SIN CAPTURAS DE PANTALLA, A PROPÓSITO
##
## Lo pide la especificación y las dos razones son buenas. Una es de licencia:
## las capturas de UCSC y Ensembl no son nuestras para redistribuir en un sitio
## público. La otra es de vida útil: las interfaces cambian cada año y una
## figura con capturas envejece mal y en silencio — el capítulo de *Dummies*
## que la bibliografía descarta murió exactamente así.
##
## Los "iconos" se dibujan con geometría (un ojo con dos arcos y un círculo,
## una caja con una flecha hacia abajo) en vez de con emoji o con una fuente de
## iconos. Un emoji se renderiza distinto en cada máquina y una fuente de
## iconos es una dependencia más; los dos romperían la promesa de que el SVG
## sale igual en cualquier lado.
## ---------------------------------------------------------------------------
##
## Esquema: no afirma ninguna cantidad. Sin título dentro del SVG.
##
## Regenerar:  Rscript figuras/sesion11/10_ucsc_vs_ensembl.R

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


# --- El contenido ------------------------------------------------------------
tabla <- data.frame(
  fila   = c("Fuerte en", "Herramienta insignia", "Acceso programático",
             "Cromosomas", "Formato propio"),
  ucsc   = c("explorar visualmente", "Table Browser", "API REST",
             "chr17", ".2bit, bigWig, bigBed"),
  ensembl = c("traer datos en bloque", "BioMart", "API REST + biomaRt",
              "17", "GTF, FASTA por especie"),
  # las filas donde el valor es literalmente código se ponen en monoespaciada
  mono   = c(FALSE, FALSE, FALSE, TRUE, TRUE),
  stringsAsFactors = FALSE
)

TXT_MNEMO <- "UCSC para mirar, Ensembl para traer."


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 14, h = 10) con 2 mm de margen: panel de 136 x 96 mm.
ANCHO_PANEL <- 136
ALTO_PANEL  <- 96

X_FILA <- 3                       # rótulo de la fila
X_UCSC <- 48                      # centro de la columna UCSC
X_ENS  <- 100                     # centro de la columna Ensembl
COL_W  <- 44

Y_ICONO  <- 86
Y_CABEZA <- 76
Y_TOPE   <- 66
PASO     <- 8.4
tabla$y  <- Y_TOPE - (seq_len(nrow(tabla)) - 1) * PASO

Y_MNEMO <- 12

SANS <- familia_base()
MONO <- familia_mono()

TAM_CABEZA <- 2.9
TAM_FILA   <- 2.15
TAM_VALOR  <- 2.15
TAM_MNEMO  <- 3.2

# Bandas alternas
bandas <- tabla[seq(1, nrow(tabla), by = 2), ]

# --- Los iconos, dibujados con geometría -------------------------------------
# Ojo: dos arcos que se encuentran en las puntas, más el iris.
.arco <- function(cx, cy, w, h, arriba = TRUE, n = 40) {
  t <- seq(0, pi, length.out = n)
  data.frame(x = cx - w / 2 + w * t / pi,
             y = cy + (if (arriba) 1 else -1) * h * sin(t))
}
ojo <- rbind(transform(.arco(X_UCSC, Y_ICONO, 13, 3.4, TRUE), id = 1),
             transform(.arco(X_UCSC, Y_ICONO, 13, 3.4, FALSE), id = 2))
iris <- transform(caja_redonda(X_UCSC - 1.9, X_UCSC + 1.9,
                               Y_ICONO - 1.9, Y_ICONO + 1.9, r = 1.9), id = 3)

# Caja con flecha de descarga.
caja_desc <- caja_redonda(X_ENS - 6.5, X_ENS + 6.5,
                          Y_ICONO - 3.6, Y_ICONO + 1.4, r = 0.9)
flecha_desc <- data.frame(x = X_ENS, y = Y_ICONO + 4.2,
                          xend = X_ENS, yend = Y_ICONO - 1.2)


construir <- function() {
  ggplot() +
    # --- Bandas alternas ---
    geom_rect(data = bandas,
              aes(xmin = 2, xmax = ANCHO_PANEL - 2,
                  ymin = y - PASO / 2 + 0.5, ymax = y + PASO / 2 - 0.5),
              fill = alpha(AZUL_CLARO, 0.07), colour = NA) +

    # --- Iconos ---
    geom_path(data = ojo, aes(x = x, y = y, group = id),
              colour = AZUL, linewidth = 0.5) +
    geom_polygon(data = iris, aes(x = x, y = y), fill = AZUL, colour = NA) +

    geom_polygon(data = caja_desc, aes(x = x, y = y),
                 fill = NA, colour = VERDE, linewidth = 0.5) +
    geom_segment(data = flecha_desc,
                 aes(x = x, y = y, xend = xend, yend = yend),
                 colour = VERDE, linewidth = 0.6,
                 arrow = arrow(length = unit(2.0, "mm"), type = "closed")) +

    # --- Encabezados ---
    annotate("text", x = X_UCSC, y = Y_CABEZA, label = "UCSC",
             family = SANS, size = TAM_CABEZA, colour = AZUL, fontface = "bold") +
    annotate("text", x = X_ENS, y = Y_CABEZA, label = "Ensembl",
             family = SANS, size = TAM_CABEZA, colour = VERDE, fontface = "bold") +
    annotate("segment", x = 2, xend = ANCHO_PANEL - 2,
             y = Y_CABEZA - 4.2, yend = Y_CABEZA - 4.2,
             colour = alpha(GRIS, 0.45), linewidth = 0.35) +

    # --- Rótulos de fila ---
    geom_text(data = tabla, aes(x = X_FILA, y = y, label = fila),
              family = SANS, size = TAM_FILA, colour = GRIS, hjust = 0) +

    # --- Valores: en sans o en mono según la fila ---
    geom_text(data = tabla[!tabla$mono, ], aes(x = X_UCSC, y = y, label = ucsc),
              family = SANS, size = TAM_VALOR, colour = TEXTO) +
    geom_text(data = tabla[!tabla$mono, ], aes(x = X_ENS, y = y, label = ensembl),
              family = SANS, size = TAM_VALOR, colour = TEXTO) +
    geom_text(data = tabla[tabla$mono, ], aes(x = X_UCSC, y = y, label = ucsc),
              family = MONO, size = TAM_VALOR, colour = TEXTO) +
    geom_text(data = tabla[tabla$mono, ], aes(x = X_ENS, y = y, label = ensembl),
              family = MONO, size = TAM_VALOR, colour = TEXTO) +

    # --- El mnemónico ---
    annotate("segment", x = 2, xend = ANCHO_PANEL - 2,
             y = Y_MNEMO + 7, yend = Y_MNEMO + 7,
             colour = alpha(GRIS, 0.45), linewidth = 0.35) +
    annotate("text", x = ANCHO_PANEL / 2, y = Y_MNEMO, label = TXT_MNEMO,
             family = SANS, size = TAM_MNEMO, colour = TEXTO, fontface = "bold") +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    tema_esquema()
}


if (!interactive()) {
  m_mnemo <- media_ancho(TXT_MNEMO, TAM_MNEMO)
  m_fila  <- media_ancho(tabla$fila, TAM_FILA)
  m_ucsc  <- media_ancho(tabla$ucsc, TAM_VALOR)
  m_ens   <- media_ancho(tabla$ensembl, TAM_VALOR)

  stopifnot(
    # --- Las cinco filas de la especificación ---
    nrow(tabla) == 5L,
    !anyDuplicated(tabla$fila),
    all(nzchar(tabla$ucsc)), all(nzchar(tabla$ensembl)),
    # la fila de cromosomas es la que sostiene @fig-nomenclatura
    tabla$ucsc[tabla$fila == "Cromosomas"] == "chr17",
    tabla$ensembl[tabla$fila == "Cromosomas"] == "17",

    # --- El mnemónico dice lo que el capítulo dice ---
    grepl("mirar", TXT_MNEMO), grepl("traer", TXT_MNEMO),

    # --- Las dos columnas no se tocan y nada se sale ---
    X_FILA + 2 * max(m_fila) < X_UCSC - max(m_ucsc),
    X_UCSC + max(m_ucsc) < X_ENS - max(m_ens),
    X_ENS + max(m_ens) <= ANCHO_PANEL,
    ANCHO_PANEL / 2 - m_mnemo >= 0,

    # --- Vertical ---
    Y_ICONO + 5 <= ALTO_PANEL,
    max(tabla$y) < Y_CABEZA - 4.2,
    min(tabla$y) - PASO / 2 > Y_MNEMO + 7,
    Y_MNEMO - TAM_MNEMO >= 0
  )

  message("  tabla comparativa, 5 filas, sin capturas de pantalla:")
  for (k in seq_len(nrow(tabla))) {
    message(sprintf("    %-22s | %-22s | %s", tabla$fila[k], tabla$ucsc[k],
                    tabla$ensembl[k]))
  }
  message(sprintf("  mnemónico: %s", TXT_MNEMO))
  message("  iconos dibujados con geometría (sin emoji ni fuente de iconos)")

  escribir_tsv(tabla[, c("fila", "ucsc", "ensembl")], "ucsc-vs-ensembl")
  guardar(construir(), "ucsc-vs-ensembl", 14, 10)
}
