## Fig. @fig-fasta-anatomia (Sesión 01) — Anatomía de un registro FASTA.
##
## Esquema, no figura de datos: las tres primeras líneas REALES del genoma de
## lambda, con llamadas a las partes del header y al salto de línea.
##
## El punto de la figura es el salto de línea (en NARANJA): es un carácter del
## archivo, no una base. Todo lo demás va en AZUL y GRIS para no competir.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion01/01_fasta_anatomia.R

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


# --- Datos: las tres primeras líneas del archivo, tal cual ------------------
# No se usa leer_fasta(): esta figura habla del ARCHIVO (header, saltos de
# línea, ancho de columna), no de la secuencia concatenada que leer_fasta
# devuelve. Por eso readLines() crudo.
ARCHIVO <- "NC_001416.1.fasta"
LINEAS  <- sub("\r$", "", readLines(ruta_datos(ARCHIVO), n = 3, warn = FALSE))

# Partes del header. El formato de RefSeq es ">accession.version descripción":
# el primer espacio separa el identificador de la prosa libre.
ACCESION    <- sub("^>([^ ]+).*$", "\\1", LINEAS[1])
DESCRIPCION <- sub("^>[^ ]+ ?", "", LINEAS[1])

# Columnas (base 1) que ocupa cada parte dentro de la línea del header.
COL_MARCA <- c(1, 1)
COL_ACC   <- c(2, 1 + nchar(ACCESION))
COL_DESC  <- c(COL_ACC[2] + 2, nchar(LINEAS[1]))   # +2: se salta el espacio

# Ancho de columna del archivo, tomado de la primera línea de secuencia. Todo
# lo que la figura afirma sobre "cuántos caracteres por línea" sale de aquí.
N_COL <- nchar(LINEAS[2])


# --- Geometría del esquema (centímetros sobre el lienzo) --------------------
# El lienzo se define en cm y el panel se estira a todo el SVG (theme_void,
# plot.margin cero), así que 1 unidad de datos ≈ 1 cm. Si el panel resultara un
# pelo más angosto por el caption, TODO se encoge junto y las alineaciones no
# se rompen: cajas, texto y llamadas viven en el mismo sistema.
ANCHO_FIG <- 16
ALTO_FIG  <- 7
ALTO_PANEL <- 6.54        # 7 cm menos lo que se lleva el caption (medido)

COL0        <- 0.55       # borde izquierdo del primer carácter
ANCHO_TEXTO <- 12.00      # ancho del bloque de texto; el resto es el margen
                          # derecho donde vive la llamada del salto de línea
W    <- ANCHO_TEXTO / N_COL          # ancho de una columna de caracteres
X_FIN <- COL0 + ANCHO_TEXTO          # final de una línea de secuencia
CAJA_X <- c(0.25, 12.95)

Y_ETQ     <- 5.65         # etiquetas de las partes del header
Y_CURVA0  <- 5.38         # de dónde salen las llamadas
Y_CURVA1  <- 4.44         # a dónde llegan (justo arriba de la caja)
CAJA_Y    <- c(2.02, 4.32)
Y_LINEA   <- c(3.87, 3.17, 2.47)     # las tres líneas del archivo
Y_BARRA   <- 1.52
Y_BARRA_ETQ <- 0.95
ALTO_REALCE <- 0.17       # medio alto de las bandas de realce

TAM_ETQ_PT <- 6.8         # etiquetas y anotaciones
CM_POR_PT  <- 2.54 / 72

MONO <- familia_mono()
SANS <- familia_base()

#' Centro horizontal de la columna k (base 1).
x_col <- function(k) COL0 + (k - 0.5) * W

#' Borde izquierdo/derecho de un rango de columnas.
x_rango <- function(cols) c(COL0 + (cols[1] - 1) * W, COL0 + cols[2] * W)

#' Ancho de una cadena en cm, con las métricas reales de la fuente. Se usa para
#' acomodar las tres etiquetas del header sin traslaparlas ni medirlas a ojo.
ancho_cm <- function(s, pt, familia) {
  systemfonts::string_width(s, family = familia, size = pt, res = 72) * CM_POR_PT
}

# Tamaño del monoespaciado: se despeja del ancho de columna que ya fijamos.
# El avance de un carácter es (tamaño × razón de la fuente), así que la razón se
# mide en la fuente instalada en vez de suponer 0.6 em. Diferencia de un M de
# más: eso es el avance puro, sin bearings.
.avance_rel <- (systemfonts::string_width(strrep("M", 21), family = MONO,
                                          size = 100, res = 72) -
                systemfonts::string_width(strrep("M", 20), family = MONO,
                                          size = 100, res = 72)) / 100
TAM_MONO_PT <- W / CM_POR_PT / .avance_rel


# --- Texto del archivo, carácter por carácter -------------------------------
# Cada carácter es su propio <text> centrado en su columna. Es deliberado:
# guardar() reescribe el font-family del SVG por el stack sans del libro, así
# que la línea NO puede depender de que el visor tenga la monoespaciada. Con una
# posición por carácter las columnas cuadran con cualquier fuente, que es justo
# lo que la figura afirma ("70 caracteres por línea").
caracteres <- function(linea, y, colores) {
  n <- nchar(linea)
  data.frame(x = x_col(seq_len(n)), y = y,
             ch = strsplit(linea, "")[[1]], col = colores)
}

# Header: la marca y el accession en AZUL, la prosa en GRIS.
col_header <- ifelse(seq_len(nchar(LINEAS[1])) <= COL_ACC[2], AZUL, GRIS)

TEXTO_ARCHIVO <- rbind(
  caracteres(LINEAS[1], Y_LINEA[1], col_header),
  caracteres(LINEAS[2], Y_LINEA[2], TEXTO),
  caracteres(LINEAS[3], Y_LINEA[3], TEXTO)
)

# Bandas de realce detrás de cada parte del header: la etiqueta apunta a la
# banda, no a un punto, y así la llamada no tiene que atinarle a un carácter.
REALCES <- data.frame(
  x0 = c(x_rango(COL_MARCA)[1], x_rango(COL_ACC)[1], x_rango(COL_DESC)[1]),
  x1 = c(x_rango(COL_MARCA)[2], x_rango(COL_ACC)[2], x_rango(COL_DESC)[2]),
  # El ">" lleva el realce más fuerte: si no, se lee pegado al accession y las
  # dos primeras llamadas parecen apuntar a lo mismo.
  fill = c(alpha(AZUL, 0.38), alpha(AZUL, 0.12), alpha(GRIS, 0.10))
)

# --- Etiquetas del header ---------------------------------------------------
ETIQUETAS <- c("marca de inicio de registro", "accession con versión",
               "descripción libre")
ANCLA_X   <- c(mean(x_rango(COL_MARCA)), mean(x_rango(COL_ACC)),
               mean(x_rango(COL_DESC)))

# Se empacan de izquierda a derecha, en el mismo orden que sus anclas, para que
# las tres llamadas bajen sin cruzarse entre sí.
.anchos <- ancho_cm(ETIQUETAS, TAM_ETQ_PT, SANS)
.hueco  <- (11.0 - CAJA_X[1] - sum(.anchos)) / (length(ETIQUETAS) - 1)
ETQ_X   <- CAJA_X[1] + cumsum(c(0, head(.anchos, -1) + .hueco))

# --- Salto de línea ---------------------------------------------------------
MARCA_SALTO <- "¶"          # calderón: existe en cualquier fuente, a diferencia
                            # de ↵, que en varias sale como caja vacía
# El realce mide EXACTAMENTE una columna, la que sigue a la última base: es la
# forma de decir que el salto ocupa una posición de carácter, ni más ni menos.
# El glifo va más grande que la secuencia para que se vea, aunque se desborde un
# poco de su celda.
X_MARCA     <- X_FIN + W / 2
TAM_MARCA_PT <- TAM_MONO_PT * 1.35
ETQ_SALTO   <- paste("salto de línea:", "es un carácter", "del archivo,",
                     "NO una base", sep = "\n")
X_ETQ_SALTO <- 13.40      # a la derecha de la caja, a la altura de la línea 2
X_FLECHA    <- 13.30      # la flecha entra a la caja y apunta a la marca


construir <- function() {
  ggplot() +
    # Caja del archivo
    annotate("rect", xmin = CAJA_X[1], xmax = CAJA_X[2],
             ymin = CAJA_Y[1], ymax = CAJA_Y[2],
             fill = NA, colour = GRIS, linewidth = 0.35) +
    # Realces del header
    geom_rect(data = REALCES,
              aes(xmin = x0, xmax = x1,
                  ymin = Y_LINEA[1] - ALTO_REALCE,
                  ymax = Y_LINEA[1] + ALTO_REALCE, fill = fill)) +
    scale_fill_identity() +
    # Realce del salto de línea: el único elemento naranja del bloque de texto
    annotate("rect", xmin = X_FIN, xmax = X_FIN + W,
             ymin = Y_LINEA[2] - ALTO_REALCE, ymax = Y_LINEA[2] + ALTO_REALCE,
             fill = alpha(NARANJA, 0.22)) +
    # Las tres líneas del archivo
    geom_text(data = TEXTO_ARCHIVO, aes(x, y, label = ch, colour = col),
              family = MONO, size = TAM_MONO_PT / .pt) +
    scale_colour_identity() +
    # El ">" en negritas: es la marca, no una letra más
    annotate("text", x = x_col(1), y = Y_LINEA[1], label = ">",
             family = MONO, size = TAM_MONO_PT / .pt, fontface = "bold",
             colour = AZUL) +
    annotate("text", x = X_MARCA, y = Y_LINEA[2], label = MARCA_SALTO,
             family = MONO, size = TAM_MARCA_PT / .pt, fontface = "bold",
             colour = NARANJA) +

    # Llamadas del header
    annotate("curve", x = ETQ_X + .anchos / 2, y = Y_CURVA0,
             xend = ANCLA_X, yend = Y_CURVA1,
             curvature = -0.18, linewidth = 0.3, colour = AZUL,
             arrow = arrow(length = unit(1.3, "mm"), type = "closed",
                           angle = 20)) +
    annotate("text", x = ETQ_X, y = Y_ETQ, label = ETIQUETAS, hjust = 0,
             family = SANS, size = TAM_ETQ_PT / .pt, colour = AZUL) +

    # Llamada del salto de línea
    annotate("segment", x = X_FLECHA, xend = X_FIN + W + 0.06, y = Y_LINEA[2],
             yend = Y_LINEA[2], linewidth = 0.35, colour = NARANJA,
             arrow = arrow(length = unit(1.3, "mm"), type = "closed",
                           angle = 20)) +
    annotate("text", x = X_ETQ_SALTO, y = Y_LINEA[2], label = ETQ_SALTO,
             hjust = 0, vjust = 0.5, lineheight = 1.12, family = SANS,
             size = TAM_ETQ_PT / .pt, colour = NARANJA) +

    # Barra del ancho de línea, con topes en las columnas 1 y N_COL
    annotate("segment", x = COL0, xend = X_FIN, y = Y_BARRA, yend = Y_BARRA,
             linewidth = 0.35, colour = GRIS) +
    annotate("segment", x = c(COL0, X_FIN), xend = c(COL0, X_FIN),
             y = Y_BARRA, yend = Y_BARRA + 0.22,
             linewidth = 0.35, colour = GRIS) +
    annotate("text", x = COL0 + ANCHO_TEXTO / 2, y = Y_BARRA_ETQ,
             label = sprintf("%d caracteres por línea", N_COL),
             family = SANS, size = TAM_ETQ_PT / .pt, colour = GRIS) +

    coord_cartesian(xlim = c(0, ANCHO_FIG), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = sprintf("Fuente: primeras tres líneas de datos/%s (RefSeq).",
                           ARCHIVO)) +
    theme_void(base_size = 10, base_family = SANS) +
    theme(plot.caption = tema_libro(10)$plot.caption,
          plot.caption.position = "plot",
          plot.margin = margin(0, 0, 0, 0),
          legend.position = "none")
}


if (!interactive()) {
  n <- nchar(LINEAS)
  stopifnot(
    length(LINEAS) == 3,
    substr(LINEAS[1], 1, 1) == ">",            # la marca de inicio de registro
    ACCESION == "NC_001416.1",                 # el registro que espera el texto
    n[2] == 70, n[3] == 70,                    # ancho de línea de RefSeq
    n[1] == 1 + nchar(ACCESION) + 1 + nchar(DESCRIPCION),
    !any(grepl("[^ACGT]", LINEAS[2:3])),       # sin N, sin minúsculas, sin \r
    X_FIN + W < CAJA_X[2],                     # el texto no se sale de la caja
    .hueco > 0.3,                              # las tres etiquetas no se juntan
    max(ETQ_X + .anchos) < ANCHO_FIG,          # ni se salen del lienzo
    X_ETQ_SALTO +
      max(ancho_cm(strsplit(ETQ_SALTO, "\n")[[1]], TAM_ETQ_PT, SANS)) <
      ANCHO_FIG                                # la llamada naranja tampoco
  )

  message(sprintf("  archivo: datos/%s", ARCHIVO))
  message(sprintf("  línea 1 (header):    %d caracteres", n[1]))
  message(sprintf("    accession = %s (%d) · descripción = %d caracteres",
                  ACCESION, nchar(ACCESION), nchar(DESCRIPCION)))
  message(sprintf("  línea 2 (secuencia): %d caracteres", n[2]))
  message(sprintf("  línea 3 (secuencia): %d caracteres", n[3]))
  message(sprintf("  ancho de columna = %.4f cm → mono %s a %.2f pt",
                  W, MONO, TAM_MONO_PT))

  escribir_tsv(data.frame(
    linea      = seq_along(LINEAS),
    tipo       = c("header", "secuencia", "secuencia"),
    caracteres = n
  ), "fasta-anatomia")

  guardar(construir(), "fasta-anatomia", w = ANCHO_FIG, h = ALTO_FIG)
}
