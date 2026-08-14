## Fig. @fig-hamming (Sesión 6, "Intento 1: distancia de Hamming")
## Hamming falla ante un corrimiento.
##
## Esquema puro, sin datos externos. Las dos cadenas son las del capítulo y del
## Ejercicio 1: SELECTIVA y ELECTIVAS, que son la MISMA cadena corrida un lugar.
##
## Todo lo que la figura afirma se cuenta de las cadenas, no se transcribe:
## la distancia de Hamming del panel de arriba, las coincidencias del de abajo
## y qué celda se pinta de qué color salen de comparar los dos renglones
## carácter por carácter. Si alguien cambia las cadenas, los números y los
## colores se recalculan solos, y los stopifnot comprueban que la moraleja
## siga siendo cierta (arriba cero coincidencias, abajo casi todas).
##
## El contraste de color ES el argumento: todo gris arriba, casi todo verde
## abajo. Por eso las celdas son grandes y las letras también.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion06/01_hamming.R

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


# --- Las cadenas ------------------------------------------------------------
V <- "SELECTIVA"
W <- "ELECTIVAS"
HUECO <- "-"

letras <- function(s) strsplit(s, "", fixed = TRUE)[[1]]

# Panel de arriba: las dos cadenas tal cual, columna contra columna.
SUP <- list(v = letras(V), w = letras(W))

# Panel de abajo: un hueco de cada lado. V se corre a la izquierda, W a la
# derecha; es la misma jugada que hace el Ejercicio 1.
INF <- list(v = c(letras(V), HUECO), w = c(HUECO, letras(W)))

#' Estado de cada columna: coincidencia, discrepancia o hueco.
estado <- function(a, b) {
  ifelse(a == HUECO | b == HUECO, "hueco",
         ifelse(a == b, "coincidencia", "discrepancia"))
}

EST_SUP <- estado(SUP$v, SUP$w)
EST_INF <- estado(INF$v, INF$w)

# Los números que la figura anuncia, CONTADOS.
HAMMING   <- sum(EST_SUP == "discrepancia")   # arriba no hay huecos: es Hamming
N_COL_INF <- length(EST_INF)
N_COINC   <- sum(EST_INF == "coincidencia")

TXT_SUP <- sprintf("Distancia de Hamming = %d", HAMMING)
TXT_INF <- sprintf("%d coincidencias de %d", N_COINC, N_COL_INF)


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 9) con 2 mm de margen lateral y el caption abajo:
# panel util de 156 x 84 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 84

X0      <- 4      # borde izquierdo de la primera celda de los DOS paneles
CELDA_W <- 8
CELDA_H <- 9
X_ETIQ  <- 92     # donde arranca el letrero grande de cada panel

# y de: título, renglón 1, marca de comparación, renglón 2. Uno por panel.
Y_TIT   <- c(80, 36)
Y_F1    <- c(70, 26)
Y_MARCA <- c(63, 19)
Y_F2    <- c(56, 12)

X_FLECHA <- X0 + 4.5 * CELDA_W    # la flecha cae a la mitad de la cuadrícula
Y_FLECHA <- c(50, 41)             # de arriba hacia abajo
X_NOTA   <- X_FLECHA + 5

TAM_LETRA <- 4.6
TAM_MARCA <- 3.4
TAM_TIT   <- 3.2
TAM_ETIQ  <- 4.0
TAM_NOTA  <- 2.9

SANS <- familia_base()
MONO <- familia_mono()


# --- Colocación -------------------------------------------------------------
#' Un data.frame de celdas (una por letra) para un panel.
celdas_panel <- function(p, est, panel) {
  n <- length(p$v)
  x <- X0 + (seq_len(n) - 0.5) * CELDA_W
  rbind(
    data.frame(x = x, y = Y_F1[panel], letra = p$v, est = est, panel = panel),
    data.frame(x = x, y = Y_F2[panel], letra = p$w, est = est, panel = panel)
  )
}

celdas <- rbind(celdas_panel(SUP, EST_SUP, 1L),
                celdas_panel(INF, EST_INF, 2L))
celdas$fondo <- c(coincidencia = VERDE, discrepancia = GRIS_CELDA,
                  hueco = GRIS_HUECO)[celdas$est]
# Sobre el verde saturado el texto va en blanco; sobre los grises, en negro.
celdas$tinta <- ifelse(celdas$est == "coincidencia", "#ffffff",
                       ifelse(celdas$est == "hueco", GRIS, TEXTO))

#' Marca entre los dos renglones: equis si discrepan, barra si coinciden,
#' nada si hay hueco (que es como se anota un alineamiento a mano).
marcas <- do.call(rbind, lapply(1:2, function(panel) {
  est <- if (panel == 1L) EST_SUP else EST_INF
  x   <- X0 + (seq_along(est) - 0.5) * CELDA_W
  keep <- est != "hueco"
  data.frame(x = x[keep], y = Y_MARCA[panel],
             txt = ifelse(est[keep] == "coincidencia", "|", "×"),
             est = est[keep])
}))

titulos <- data.frame(
  x = X0, y = Y_TIT,
  txt = c("Sin desplazar", "Desplazando una posición")
)

letreros <- data.frame(
  x = X_ETIQ, y = (Y_F1 + Y_F2) / 2,
  txt = c(TXT_SUP, TXT_INF),
  col = c(TEXTO, VERDE)
)

NOTA_FLECHA <- "un solo hueco de cada lado"


construir <- function() {
  ggplot() +
    # --- Las celdas ---
    geom_tile(data = celdas, aes(x = x, y = y, fill = fondo),
              width = CELDA_W - 0.7, height = CELDA_H - 0.7) +
    geom_text(data = celdas, aes(x = x, y = y, label = letra, colour = tinta),
              family = MONO, size = TAM_LETRA, fontface = "bold") +

    # --- Marcas de comparación entre renglones ---
    geom_text(data = marcas, aes(x = x, y = y, label = txt,
                                 colour = ifelse(est == "coincidencia", VERDE, GRIS)),
              family = MONO, size = TAM_MARCA) +

    # --- Títulos de panel ---
    geom_text(data = titulos, aes(x = x, y = y, label = txt),
              family = SANS, size = TAM_TIT, colour = TEXTO,
              hjust = 0, fontface = "bold") +

    # --- El letrero grande de cada panel: el remate de la figura ---
    geom_text(data = letreros, aes(x = x, y = y, label = txt, colour = col),
              family = SANS, size = TAM_ETIQ, hjust = 0, fontface = "bold") +

    # --- La flecha entre paneles ---
    geom_segment(data = data.frame(1),
                 aes(x = X_FLECHA, xend = X_FLECHA,
                     y = Y_FLECHA[1], yend = Y_FLECHA[2]),
                 colour = NARANJA, linewidth = 1.1, arrow.fill = NARANJA,
                 arrow = arrow(length = unit(2.6, "mm"), type = "closed")) +
    geom_text(data = data.frame(1),
              aes(x = X_NOTA, y = mean(Y_FLECHA)), label = NOTA_FLECHA,
              family = SANS, size = TAM_NOTA, colour = NARANJA, hjust = 0) +

    scale_fill_identity() +
    scale_colour_identity() +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = sprintf(paste("Las dos cadenas son la misma, corrida un lugar.",
                                 "Arriba, %d columnas y ninguna coincide;",
                                 "abajo, con un hueco de cada lado, %d de %d."),
                           length(EST_SUP), N_COINC, N_COL_INF)) +
    tema_esquema()
}


if (!interactive()) {
  ancho_sup <- media_ancho(TXT_SUP, TAM_ETIQ) * 2
  ancho_inf <- media_ancho(TXT_INF, TAM_ETIQ) * 2
  ancho_nota <- media_ancho(NOTA_FLECHA, TAM_NOTA) * 2

  stopifnot(
    # --- Las cadenas son las del capítulo, y una es la otra corrida ---
    nchar(V) == nchar(W),
    substr(V, 2, nchar(V)) == substr(W, 1, nchar(W) - 1),

    # --- El panel de arriba: el peor caso posible ---
    HAMMING == nchar(V),                       # ninguna columna coincide
    all(EST_SUP == "discrepancia"),

    # --- El panel de abajo: casi todas coinciden ---
    N_COL_INF == nchar(V) + 1L,
    N_COINC == nchar(V) - 1L,
    sum(EST_INF == "hueco") == 2L,
    sum(EST_INF == "discrepancia") == 0L,
    # Los huecos van uno de cada lado: es lo que dice la nota de la flecha.
    EST_INF[1] == "hueco", EST_INF[N_COL_INF] == "hueco",
    # La moraleja: el MISMO par de cadenas, dos lecturas opuestas. Hamming no
    # ve ninguna coincidencia; corriendo un lugar aparecen casi todas.
    sum(EST_SUP == "coincidencia") == 0L,
    N_COINC >= nchar(V) - 1L,

    # --- Nada se sale del panel ---
    X0 + N_COL_INF * CELDA_W < X_ETIQ,
    X_ETIQ + max(ancho_sup, ancho_inf) <= ANCHO_PANEL,
    X_NOTA + ancho_nota <= ANCHO_PANEL,
    max(Y_TIT) + TAM_TIT <= ALTO_PANEL,
    min(Y_F2) - CELDA_H / 2 >= 0,
    Y_F2[1] - CELDA_H / 2 > Y_FLECHA[1],       # la flecha no toca el panel 1
    Y_FLECHA[2] > Y_TIT[2] + TAM_TIT,          # ni el título del panel 2
    all(Y_MARCA < Y_F1 - CELDA_H / 2), all(Y_MARCA > Y_F2 + CELDA_H / 2)
  )

  message(sprintf("  sin desplazar:  %d columnas, %d discrepancias -> Hamming = %d",
                  length(EST_SUP), HAMMING, HAMMING))
  message(sprintf("  desplazado:     %d columnas, %d coincidencias, %d huecos",
                  N_COL_INF, N_COINC, sum(EST_INF == "hueco")))

  guardar(construir(), "hamming", 16, 9)
}
