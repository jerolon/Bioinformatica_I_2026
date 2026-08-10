## Fig. @fig-linealizar (Sesión 5, Ejercicio 6)
## El truco de linealizar: antes y después.
##
## Esquema puro. Las secuencias son de juguete y cortas a propósito: la figura
## es sobre el CONTEO DE LÍNEAS, no sobre las bases, y con secuencias reales el
## número de líneas no cabría en la página.
##
## Todo lo que la figura afirma —cuántas líneas hay de cada lado, cuántos
## registros, cuántas contienen ATG— se cuenta de los datos de juguete con el
## mismo criterio que usaría grep. Si alguien cambia las secuencias, los
## números se recalculan solos y el stopifnot comprueba que la moraleja siga
## siendo cierta (que plegado y linealizado den conteos DISTINTOS).
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion05/05_linealizar.R

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


# --- Los datos de juguete ---------------------------------------------------
# Dos registros, plegados a 12 caracteres. Las secuencias están armadas para
# que el conteo de ATG sea distinto entre plegado y linealizado, que es lo que
# la figura tiene que demostrar: seqA lleva dos ATG en líneas distintas.
ANCHO <- 12L
REGISTROS <- list(
  list(id = ">seqA", sec = "ATGCCCGGGTTTAAACCCATGGGGTTTCCCAAA"),
  list(id = ">seqB", sec = "GGGCCCTTTAAAGGGCCCTTTAAAGGGCCC")
)
MOTIVO <- "ATG"

partir <- function(s, w) substring(s, seq(1, nchar(s), w),
                                   pmin(seq(w, nchar(s) + w - 1, w), nchar(s)))

plegado <- unlist(lapply(REGISTROS, function(r) c(r$id, partir(r$sec, ANCHO))))
lineal  <- unlist(lapply(REGISTROS, function(r) c(r$id, r$sec)))

# Lo que contaría grep -c en cada archivo. Es la cifra que la figura afirma.
cuenta_motivo <- function(x) sum(grepl(MOTIVO, x[!grepl("^>", x)], fixed = TRUE))
N_PLEGADO <- cuenta_motivo(plegado)
N_LINEAL  <- cuenta_motivo(lineal)
N_REG     <- length(REGISTROS)
# Cuántos registros CONTIENEN el motivo, que es lo que uno quería saber.
N_REG_CON <- sum(vapply(REGISTROS, function(r) grepl(MOTIVO, r$sec, fixed = TRUE),
                        logical(1)))

CMD <- "awk '/^>/{if(seq)print seq; print; seq=\"\"; next}{seq=seq $0}END{if(seq)print seq}'"
CMD_CORTO <- "awk '/^>/{...}'"


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 10) con 2 mm de margen: panel de 156 x 94 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 94

TAM_MONO <- 2.6
CHAR <- TAM_MONO * AVANCE_MONO

X_NUM <- c(4, 88)                 # columna del número de línea
X_TXT <- c(10, 94)                # donde empieza el texto de cada columna
W_COL <- 58

Y_TITULO <- 88
Y_INI    <- 80                    # primera línea de cada columna
PASO     <- 5.2

Y_NOTA   <- 34                    # la nota de cada columna
Y_FLECHA <- 54                    # la flecha entre columnas
Y_CMD    <- 60

Y_GREP <- c(14, 7)                # los dos renglones de grep

TAM_TITULO <- 2.6
TAM_NUM    <- 1.9
TAM_NOTA   <- 2.1
TAM_CMD    <- 2.0
TAM_GREP   <- 2.1

SANS <- familia_base()
MONO <- familia_mono()


# --- Colocación -------------------------------------------------------------
columnas <- list(
  list(titulo = "plegado", lineas = plegado, i = 1),
  list(titulo = "linealizado", lineas = lineal, i = 2)
)

filas <- do.call(rbind, lapply(columnas, function(co) {
  data.frame(col = co$i, n = seq_along(co$lineas), texto = co$lineas,
             y = Y_INI - (seq_along(co$lineas) - 1) * PASO,
             es_enc = grepl("^>", co$lineas),
             stringsAsFactors = FALSE)
}))
filas$x_num <- X_NUM[filas$col]
filas$x_txt <- X_TXT[filas$col]

titulos <- data.frame(
  col = 1:2, x = X_TXT, titulo = c("plegado", "linealizado"),
  stringsAsFactors = FALSE
)

notas <- data.frame(
  col = 1:2, x = X_TXT,
  texto = c(sprintf("%d líneas, %d secuencias.\nLas herramientas de UNIX\ncuentan líneas.",
                    length(plegado), N_REG),
            sprintf("%d líneas, %d secuencias.\nUna línea de secuencia\n= una secuencia.",
                    length(lineal), N_REG)),
  stringsAsFactors = FALSE
)

# La flecha entre columnas, en el hueco.
X_FLECHA <- c(X_TXT[1] + W_COL + 2, X_TXT[2] - 4)

TXT_GREP <- c(
  sprintf("plegado:      grep -c \"%s\"   ->  %d   (cuenta líneas, no secuencias)",
          MOTIVO, N_PLEGADO),
  sprintf("linealizado:  grep -c \"%s\"   ->  %d   (cuenta secuencias que contienen %s)",
          MOTIVO, N_LINEAL, MOTIVO)
)


construir <- function() {
  ggplot() +
    # --- Títulos de columna ---
    geom_text(data = titulos, aes(x = x, y = Y_TITULO, label = titulo),
              family = SANS, size = TAM_TITULO, colour = TEXTO, hjust = 0,
              fontface = "bold") +

    # --- Números de línea y contenido ---
    geom_text(data = filas, aes(x = x_num, y = y, label = n),
              family = MONO, size = TAM_NUM, colour = alpha(GRIS, 0.8),
              hjust = 1) +
    geom_text(data = filas, aes(x = x_txt, y = y, label = texto,
                                colour = es_enc),
              family = MONO, size = TAM_MONO, hjust = 0, show.legend = FALSE) +

    # --- Notas de cada columna ---
    geom_text(data = notas, aes(x = x, y = Y_NOTA, label = texto),
              family = SANS, size = TAM_NOTA, colour = TEXTO, hjust = 0,
              lineheight = 1.15, vjust = 1) +

    # --- La flecha y el comando ---
    geom_segment(data = data.frame(1),
                 aes(x = X_FLECHA[1], xend = X_FLECHA[2],
                     y = Y_FLECHA, yend = Y_FLECHA),
                 colour = NARANJA, linewidth = 1.1, arrow.fill = NARANJA,
                 arrow = arrow(length = unit(2.6, "mm"), type = "closed")) +
    geom_text(data = data.frame(1),
              aes(x = mean(X_FLECHA), y = Y_CMD), label = CMD_CORTO,
              family = MONO, size = TAM_CMD, colour = NARANJA) +

    # --- Lo que se desbloquea ---
    geom_text(data = data.frame(y = Y_GREP, txt = TXT_GREP),
              aes(x = X_NUM[1], y = y, label = txt),
              family = MONO, size = TAM_GREP, colour = TEXTO, hjust = 0) +

    scale_colour_manual(values = c(`TRUE` = AZUL, `FALSE` = TEXTO),
                        guide = "none") +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = sprintf(paste("Secuencias de juguete, plegadas a %d caracteres.",
                                 "El comando completo está en el Ejercicio 6."),
                           ANCHO)) +
    tema_esquema()
}


if (!interactive()) {
  m_grep <- media_ancho(TXT_GREP, TAM_GREP, AVANCE_MONO)
  ancho_max <- max(nchar(c(plegado, lineal))) * CHAR

  stopifnot(
    # --- Los datos de juguete ---
    length(REGISTROS) == 2L,
    length(plegado) == 8L,                 # 2 encabezados + 6 de secuencia
    length(lineal) == 4L,                  # 2 encabezados + 2 de secuencia
    length(lineal) == 2L * N_REG,
    # linealizar conserva las secuencias, sólo cambia el plegado
    identical(vapply(REGISTROS, function(r) r$sec, character(1)),
              lineal[!grepl("^>", lineal)]),
    identical(paste0(plegado[!grepl("^>", plegado)][1:3], collapse = ""),
              REGISTROS[[1]]$sec),

    # --- La moraleja: los dos conteos DIFIEREN ---
    N_PLEGADO != N_LINEAL,
    N_LINEAL == N_REG_CON,                 # el linealizado da la respuesta buena
    N_PLEGADO > N_LINEAL,                  # y el plegado infla

    # --- Nada se sale del panel ---
    max(X_TXT) + ancho_max <= ANCHO_PANEL,
    X_TXT[1] + ancho_max < X_NUM[2],       # la columna 1 no invade la 2
    min(filas$y) > Y_NOTA + 2,
    Y_NOTA - 3 * TAM_NOTA > max(Y_GREP) + TAM_GREP,
    min(Y_GREP) - TAM_GREP >= 0,
    Y_TITULO + TAM_TITULO <= ALTO_PANEL,
    all(X_NUM[1] + 2 * m_grep <= ANCHO_PANEL),
    X_FLECHA[2] > X_FLECHA[1]
  )

  message(sprintf("  plegado a %d caracteres: %d líneas, %d registros",
                  ANCHO, length(plegado), N_REG))
  message(sprintf("  linealizado:             %d líneas, %d registros",
                  length(lineal), N_REG))
  message(sprintf("  grep -c \"%s\": %d en el plegado, %d en el linealizado",
                  MOTIVO, N_PLEGADO, N_LINEAL))
  message(sprintf("  registros que de verdad contienen %s: %d  <- lo que uno quería",
                  MOTIVO, N_REG_CON))

  guardar(construir(), "linealizar", 16, 10)
}
