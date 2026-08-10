## Fig. @fig-tracks (Sesión 11, § Qué es un track)
## Cuatro pistas de tipos distintos, todas sobre el MISMO eje de coordenadas.
##
## ---------------------------------------------------------------------------
## LA FIGURA ES EL EJE, NO LAS PISTAS
##
## El argumento del capítulo es que un browser no es un visor de genes: es un
## sistema de coordenadas con cosas apiladas encima. Por eso el eje se dibuja
## una sola vez, arriba, y las cuatro pistas cuelgan de él alineadas al
## milímetro. Las guías verticales punteadas atraviesan las cuatro para que la
## alineación se vea, no se suponga.
##
## Las cuatro pistas son de tipos deliberadamente distintos —texto, geometría,
## señal continua y marcas puntuales— porque el punto es que el eje no le pide
## nada al dato salvo que tenga coordenadas.
##
## LOS DATOS SON INVENTADOS Y ESO ESTÁ BIEN: es un esquema de qué es un track,
## no una vista de TP53. No lleva coordenadas reales para que nadie lo lea como
## si lo fuera; el eje va en "posición en el cromosoma" sin números absolutos.
## Los valores de la señal están FIJOS (no aleatorios) para que dos corridas
## den bytes idénticos.
## ---------------------------------------------------------------------------
##
## Esquema: no afirma ninguna cantidad. Sin título dentro del SVG.
##
## Regenerar:  Rscript figuras/sesion11/09_tracks.R

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


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 9) con 2 mm de margen: panel de 156 x 86 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 86

X_ETIQ <- 3
X0 <- 34                          # inicio del eje
X1 <- 152                         # fin del eje
W  <- X1 - X0

Y_EJE <- 78
Y_PISTA <- c(64, 48, 30, 13)      # centro de cada pista

SANS <- familia_base()
MONO <- familia_mono()

TAM_ETIQ <- 2.3
TAM_SUB  <- 1.85
TAM_SEC  <- 1.9
TAM_LEY  <- 2.15

pistas <- data.frame(
  y = Y_PISTA,
  nombre = c("Secuencia", "Genes", "Señal continua", "Variantes"),
  sub = c("sólo visible con zoom", "exones, intrones, hebra",
          "bigWig", "VCF"),
  stringsAsFactors = FALSE
)

# --- Guías verticales, para que se vea que el eje es el mismo ----------------
GUIAS <- X0 + W * c(0.18, 0.42, 0.66, 0.88)

# --- Pista 1: secuencia -----------------------------------------------------
# Una tira de letras. Es una secuencia FIJA, no aleatoria (determinismo).
BASES <- strsplit("GATCCTGAGTAGCTGGGATTACAGGCGCCCGCCACCACGCCCGGCTAATTTTTGT", "")[[1]]
seq_x <- seq(X0 + 1.2, X1 - 1.2, length.out = length(BASES))
COL_BASE <- c(A = VERDE, C = AZUL, G = AMBAR, T = MORADO)
sec <- data.frame(x = seq_x, b = BASES, col = COL_BASE[BASES],
                  stringsAsFactors = FALSE)

# --- Pista 2: genes ---------------------------------------------------------
# Exones como cajas, intrones como línea, con flechas de hebra encima.
exones <- data.frame(
  xmin = X0 + W * c(0.06, 0.22, 0.38, 0.58, 0.80),
  xmax = X0 + W * c(0.13, 0.31, 0.45, 0.70, 0.93)
)
GEN_ALTO <- 5
Y_GEN <- Y_PISTA[2]

# Las flechas de hebra van SÓLO en los intrones, que es donde las pone un
# browser de verdad. Repartidas a ciegas por todo el gen caían encima de los
# exones y ensuciaban las cajas. Se calcula el hueco entre exón y exón y se
# ponen las que quepan, con separación mínima.
SEP_HEBRA <- 4.5
hebra_x <- unlist(lapply(seq_len(nrow(exones) - 1), function(k) {
  a <- exones$xmax[k] + 1.2
  b <- exones$xmin[k + 1] - 1.2
  if (b - a < SEP_HEBRA / 2) return(numeric(0))
  n <- max(1, floor((b - a) / SEP_HEBRA))
  seq(a, b, length.out = n + 2)[2:(n + 1)]
}))

# --- Pista 3: señal continua ------------------------------------------------
# Valores FIJOS. Se eligieron con dos picos que caen sobre exones, para que la
# figura sugiera lo que una señal real sugiere, sin afirmar ningún dato.
SENAL <- c(2, 3, 5, 9, 14, 11, 6, 4, 3, 5, 8, 13, 18, 15, 9, 5, 3, 4,
           6, 10, 7, 4, 3, 2, 4, 7, 12, 16, 12, 7, 4, 3, 2, 2, 3, 2)
sig_w <- W / length(SENAL)
ALTO_SENAL <- 13
senal <- data.frame(
  xmin = X0 + (seq_along(SENAL) - 1) * sig_w,
  xmax = X0 + seq_along(SENAL) * sig_w,
  ymin = Y_PISTA[3] - ALTO_SENAL / 2,
  ymax = Y_PISTA[3] - ALTO_SENAL / 2 + ALTO_SENAL * SENAL / max(SENAL)
)

# --- Pista 4: variantes -----------------------------------------------------
VAR_POS <- c(0.09, 0.11, 0.25, 0.27, 0.28, 0.41, 0.44, 0.60, 0.63, 0.64,
             0.65, 0.82, 0.85, 0.91)
variantes <- data.frame(x = X0 + W * VAR_POS)

TXT_LEY <- paste("todo lo que un browser hace es apilar anotaciones",
                 "sobre un sistema de coordenadas compartido")


construir <- function() {
  ggplot() +
    # --- Guías verticales: el mismo eje atraviesa las cuatro pistas ---
    annotate("segment", x = GUIAS, xend = GUIAS,
             y = min(Y_PISTA) - 8, yend = Y_EJE,
             colour = alpha(GRIS, 0.22), linewidth = 0.3, linetype = "dotted") +

    # --- El eje ---
    annotate("segment", x = X0, xend = X1, y = Y_EJE, yend = Y_EJE,
             colour = GRIS, linewidth = 0.45) +
    annotate("segment", x = GUIAS, xend = GUIAS, y = Y_EJE, yend = Y_EJE + 1.8,
             colour = GRIS, linewidth = 0.4) +
    annotate("text", x = X_ETIQ, y = Y_EJE, label = "posición en el cromosoma",
             family = SANS, size = TAM_SUB, colour = GRIS, hjust = 0) +

    # --- Rótulos de las pistas ---
    geom_text(data = pistas, aes(x = X_ETIQ, y = y + 1.6, label = nombre),
              family = SANS, size = TAM_ETIQ, colour = TEXTO,
              fontface = "bold", hjust = 0) +
    geom_text(data = pistas, aes(x = X_ETIQ, y = y - 2.2, label = sub),
              family = SANS, size = TAM_SUB, colour = GRIS, hjust = 0) +

    # --- Pista 1: secuencia ---
    geom_text(data = sec, aes(x = x, y = Y_PISTA[1], label = b,
                              colour = I(col)),
              family = MONO, size = TAM_SEC, fontface = "bold") +

    # --- Pista 2: genes ---
    annotate("segment", x = min(exones$xmin), xend = max(exones$xmax),
             y = Y_GEN, yend = Y_GEN, colour = AZUL, linewidth = 0.4) +
    annotate("text", x = hebra_x, y = Y_GEN, label = ">",
             family = SANS, size = 1.9, colour = alpha(AZUL, 0.75)) +
    geom_rect(data = exones,
              aes(xmin = xmin, xmax = xmax,
                  ymin = Y_GEN - GEN_ALTO / 2, ymax = Y_GEN + GEN_ALTO / 2),
              fill = alpha(AZUL_CLARO, 0.55), colour = AZUL, linewidth = 0.35) +

    # --- Pista 3: señal continua ---
    geom_rect(data = senal,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = alpha(VERDE, 0.55), colour = NA) +
    annotate("segment", x = X0, xend = X1,
             y = Y_PISTA[3] - ALTO_SENAL / 2, yend = Y_PISTA[3] - ALTO_SENAL / 2,
             colour = alpha(GRIS, 0.5), linewidth = 0.3) +

    # --- Pista 4: variantes ---
    geom_segment(data = variantes,
                 aes(x = x, xend = x,
                     y = Y_PISTA[4] - 3, yend = Y_PISTA[4] + 3),
                 colour = NARANJA, linewidth = 0.55) +
    annotate("segment", x = X0, xend = X1,
             y = Y_PISTA[4] - 3, yend = Y_PISTA[4] - 3,
             colour = alpha(GRIS, 0.5), linewidth = 0.3) +

    # --- La leyenda ---
    annotate("text", x = ANCHO_PANEL / 2, y = 3, label = TXT_LEY,
             family = SANS, size = TAM_LEY, colour = GRIS, fontface = "italic") +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    tema_esquema()
}


if (!interactive()) {
  m_ley <- media_ancho(TXT_LEY, TAM_LEY)
  m_nom <- media_ancho(pistas$nombre, TAM_ETIQ)
  m_sub <- media_ancho(pistas$sub, TAM_SUB)

  stopifnot(
    # --- Cuatro pistas de cuatro tipos distintos ---
    nrow(pistas) == 4L,
    !anyDuplicated(pistas$nombre),

    # --- TODO cuelga del mismo eje: nada se sale por los lados. Es la
    #     afirmación de la figura, así que se comprueba. ---
    all(sec$x >= X0), all(sec$x <= X1),
    all(exones$xmin >= X0), all(exones$xmax <= X1),
    all(senal$xmin >= X0 - 1e-9), all(senal$xmax <= X1 + 1e-9),
    all(variantes$x >= X0), all(variantes$x <= X1),
    all(GUIAS > X0), all(GUIAS < X1),

    # --- Geometría de cada pista ---
    all(exones$xmax > exones$xmin),
    all(diff(exones$xmin) > 0),               # exones ordenados y sin solapar
    all(exones$xmin[-1] > exones$xmax[-nrow(exones)]),
    length(SENAL) > 20, all(SENAL > 0),
    all(senal$ymax >= senal$ymin),
    length(BASES) > 40, all(BASES %in% names(COL_BASE)),

    # --- Las flechas de hebra caen en intrones, nunca sobre un exón ---
    length(hebra_x) > 0,
    !any(vapply(hebra_x, function(x)
      any(x >= exones$xmin & x <= exones$xmax), logical(1))),

    # --- Las pistas no se enciman ---
    all(diff(Y_PISTA) < 0),
    Y_PISTA[1] + 2 < Y_EJE,
    min(senal$ymin) > Y_PISTA[4] + 3,
    Y_PISTA[4] - 3 > 3 + TAM_LEY,

    # --- Nada se sale del panel ---
    X1 <= ANCHO_PANEL, Y_EJE + 1.8 <= ALTO_PANEL,
    all(X_ETIQ + 2 * m_nom < X0), all(X_ETIQ + 2 * m_sub < X0),
    ANCHO_PANEL / 2 - m_ley >= 0
  )

  message("  cuatro pistas sobre un solo eje:")
  for (k in seq_len(nrow(pistas))) {
    message(sprintf("    %-16s %s", pistas$nombre[k], pistas$sub[k]))
  }
  message(sprintf("  eje de %.0f a %.0f mm; %d guías verticales lo cruzan",
                  X0, X1, length(GUIAS)))
  message(sprintf("  %d bases, %d exones, %d barras de señal, %d variantes",
                  length(BASES), nrow(exones), length(SENAL), nrow(variantes)))
  message("  datos inventados y FIJOS: es un esquema, y el SVG es determinista")

  guardar(construir(), "tracks", 16, 9)
}
