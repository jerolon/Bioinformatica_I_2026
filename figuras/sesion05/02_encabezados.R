## Fig. @fig-encabezados (Sesión 5, § Los encabezados, que es donde se pone feo)
## Cinco convenciones de encabezado, con sus partes coloreadas.
##
## ---------------------------------------------------------------------------
## LA LÍNEA DEL PRIMER ESPACIO NO PUEDE SER UNA SOLA LÍNEA RECTA
##
## La especificación pedía "una línea vertical punteada que cruza los cinco
## encabezados marcando dónde cae el primer espacio". Eso es geométricamente
## imposible y, peor, conceptualmente falso: el primer espacio cae en una
## columna DISTINTA en cada encabezado (13, 22, 19) y en dos de ellos NO EXISTE.
##
##   >NC_001416.1 ...                  primer espacio en la columna 13
##   >sp|P01013|OVAX_CHICK ...         en la 22
##   >gi|129295|sp|P01013|OVAX_CHICK   no hay espacio
##   >ENST00000456328.2 cdna ...       en la 19
##   >mi_secuencia_favorita            no hay espacio
##
## Una recta vertical sólo podría estar en una de esas columnas y sugeriría que
## el corte cae siempre ahí, que es exactamente el error que la figura quiere
## desarmar. Así que se dibuja una MARCA POR ENCABEZADO en su propia columna,
## unidas por una polilínea punteada que se ve quebrada: la quebradura es el
## mensaje. Los dos sin espacio llevan su marca al final de la línea y una nota
## aparte, porque ahí el identificador es el encabezado entero.
## ---------------------------------------------------------------------------
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion05/02_encabezados.R

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


# --- Los cinco encabezados, tal cual los cita el capítulo -------------------
ENCABEZADOS <- data.frame(
  fuente = c("NCBI actual", "UniProt", "NCBI histórico\n(GI, retirado en 2016)",
             "Ensembl", "hecho a mano"),
  texto = c(
    ">NC_001416.1 Escherichia virus Lambda, complete genome",
    ">sp|P01013|OVAX_CHICK Ovalbumin-related protein X OS=Gallus gallus OX=9031 PE=1 SV=2",
    ">gi|129295|sp|P01013|OVAX_CHICK",
    ">ENST00000456328.2 cdna chromosome:GRCh38:1:11869:14409:1 gene:ENSG00000290825.1",
    ">mi_secuencia_favorita"),
  stringsAsFactors = FALSE
)

# El primer espacio, CALCULADO. -1 cuando no hay.
ENCABEZADOS$espacio <- vapply(ENCABEZADOS$texto, function(s) {
  p <- regexpr(" ", s, fixed = TRUE); if (p < 0) -1L else as.integer(p)
}, integer(1), USE.NAMES = FALSE)
ENCABEZADOS$tiene_espacio <- ENCABEZADOS$espacio > 0
# Dónde termina el identificador: en el primer espacio, o al final si no hay.
ENCABEZADOS$fin_id <- ifelse(ENCABEZADOS$tiene_espacio,
                             ENCABEZADOS$espacio - 1L,
                             nchar(ENCABEZADOS$texto))


# --- Tramos coloreados ------------------------------------------------------
# Cada tramo es (fila, primer carácter, último carácter, papel). Los papeles
# son los cuatro del código de color de la especificación.
tramo <- function(fila, de, a, papel) {
  data.frame(fila = fila, de = de, a = a, papel = papel, stringsAsFactors = FALSE)
}

TRAMOS <- rbind(
  # 1. NCBI actual: identificador y descripción libre
  tramo(1, 2, 12, "id"), tramo(1, 14, 54, "libre"),
  # 2. UniProt: sp|ACC|NOMBRE, descripción, y los campos clave=valor
  tramo(2, 2, 21, "id"), tramo(2, 23, 48, "libre"),
  tramo(2, 50, 84, "clave"),
  # 3. NCBI histórico: el GI retirado, luego el resto del identificador
  tramo(3, 2, 10, "gi"), tramo(3, 12, 31, "id"),
  # 4. Ensembl: identificador, tipo, y los campos clave:valor
  tramo(4, 2, 18, "id"), tramo(4, 20, 23, "libre"),
  tramo(4, 25, 80, "clave"),
  # 5. hecho a mano: todo es identificador, no hay nada más
  tramo(5, 2, 22, "id")
)

COLOR_PAPEL <- c(id = AZUL, clave = VERDE, libre = GRIS, gi = NARANJA)
ETIQ_PAPEL  <- c(id = "identificador", clave = "campos clave=valor",
                 libre = "descripción libre", gi = "número GI (retirado)")


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 18, h = 8) con 2 mm de margen: panel de 176 x 74 mm.
ANCHO_PANEL <- 176
ALTO_PANEL  <- 74

X_ROTULO <- 2                     # rótulo de fuente, alineado a la izquierda
X_TXT    <- 44                    # donde empieza el texto monoespaciado

N <- nrow(ENCABEZADOS)
LARGO_MAX <- max(nchar(ENCABEZADOS$texto))
# El ancho de carácter sale de lo que hay: el encabezado más largo tiene que
# caber entre X_TXT y el borde, con 3 mm de aire para la marca del corte.
CHAR <- (ANCHO_PANEL - X_TXT - 4) / LARGO_MAX
TAM_MONO <- CHAR / AVANCE_MONO

Y_FILA <- seq(64, 26, length.out = N)   # de arriba abajo
ALTO_RESALTA <- 3.4

Y_NOTA_CORTE <- 14
Y_LEYENDA <- 5

TAM_ROTULO <- 1.9
TAM_NOTA   <- 2.0
TAM_LEY    <- 1.9

SANS <- familia_base()
MONO <- familia_mono()


# --- Colocación -------------------------------------------------------------
ENCABEZADOS$y <- Y_FILA
# x del corte: justo después del último carácter del identificador.
ENCABEZADOS$x_corte <- X_TXT + ENCABEZADOS$fin_id * CHAR

resaltas <- transform(
  TRAMOS,
  xmin = X_TXT + (de - 1) * CHAR,
  xmax = X_TXT + a * CHAR,
  ymin = Y_FILA[TRAMOS$fila] - ALTO_RESALTA / 2,
  ymax = Y_FILA[TRAMOS$fila] + ALTO_RESALTA / 2
)
resaltas$color <- unname(COLOR_PAPEL[resaltas$papel])

# Tachadura sobre el GI: es el tramo retirado.
tachadura <- subset(resaltas, papel == "gi")

# Marcas del corte y la polilínea que las une. Se ve quebrada a propósito.
marcas <- data.frame(x = ENCABEZADOS$x_corte, y = Y_FILA,
                     tiene = ENCABEZADOS$tiene_espacio)
quebrada <- data.frame(x = ENCABEZADOS$x_corte, y = Y_FILA)

NOTA_CORTE <- "por convención, el identificador termina aquí: en el primer espacio"
NOTA_SIN   <- "sin espacio: el identificador es el encabezado entero"

# Leyenda del código de color.
ley <- data.frame(papel = names(ETIQ_PAPEL), texto = unname(ETIQ_PAPEL),
                  stringsAsFactors = FALSE)
ley$ancho <- 4.5 + 1.4 + 2 * media_ancho(ley$texto, TAM_LEY)
ley$x <- cumsum(c(0, head(ley$ancho + 5, -1)))
ley$x <- ley$x + (ANCHO_PANEL - (sum(ley$ancho) + 5 * (nrow(ley) - 1))) / 2


construir <- function() {
  ggplot() +
    # --- Resaltados detrás del texto ---
    geom_rect(data = resaltas,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = alpha(resaltas$color, 0.20), colour = NA) +
    # El GI va tachado: se retiró en 2016.
    geom_segment(data = tachadura,
                 aes(x = xmin + 0.3, xend = xmax - 0.3,
                     y = (ymin + ymax) / 2, yend = (ymin + ymax) / 2),
                 colour = NARANJA, linewidth = 0.5) +

    # --- Los cinco encabezados ---
    geom_text(data = ENCABEZADOS, aes(x = X_TXT, y = y, label = texto),
              family = MONO, size = TAM_MONO, colour = TEXTO, hjust = 0) +
    geom_text(data = ENCABEZADOS, aes(x = X_ROTULO, y = y, label = fuente),
              family = SANS, size = TAM_ROTULO, colour = GRIS, hjust = 0,
              lineheight = 1.05) +

    # --- Dónde termina el identificador ---
    geom_path(data = quebrada, aes(x = x, y = y),
              colour = alpha(NARANJA, 0.55), linewidth = 0.4,
              linetype = "dotted") +
    geom_segment(data = marcas,
                 aes(x = x, xend = x, y = y - ALTO_RESALTA / 2 - 1.2,
                     yend = y + ALTO_RESALTA / 2 + 1.2, linetype = tiene),
                 colour = NARANJA, linewidth = 0.5) +
    # Los dos sin espacio llevan además una llamada
    geom_text(data = subset(marcas, !tiene),
              aes(x = x + 2, y = y), label = "◄ sin espacio",
              family = SANS, size = TAM_ROTULO, colour = NARANJA, hjust = 0) +

    geom_text(data = data.frame(1), aes(x = X_TXT, y = Y_NOTA_CORTE),
              label = paste(NOTA_CORTE, NOTA_SIN, sep = "\n"),
              family = SANS, size = TAM_NOTA, colour = TEXTO, hjust = 0,
              lineheight = 1.15) +

    # --- Leyenda del código de color ---
    geom_rect(data = ley,
              aes(xmin = x, xmax = x + 4.5, ymin = Y_LEYENDA - 1.5,
                  ymax = Y_LEYENDA + 1.5),
              fill = alpha(unname(COLOR_PAPEL[ley$papel]), 0.35),
              colour = unname(COLOR_PAPEL[ley$papel]), linewidth = 0.3) +
    geom_text(data = ley, aes(x = x + 5.9, y = Y_LEYENDA, label = texto),
              family = SANS, size = TAM_LEY, colour = TEXTO, hjust = 0) +

    scale_linetype_manual(values = c(`TRUE` = "solid", `FALSE` = "22"),
                          guide = "none") +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = paste("Los cinco encabezados son reales. La columna donde",
                         "termina el identificador está calculada, no dibujada",
                         "a ojo:\npor eso la línea sale quebrada.")) +
    tema_esquema()
}


if (!interactive()) {
  m_nota <- media_ancho(c(NOTA_CORTE, NOTA_SIN), TAM_NOTA)

  stopifnot(
    # --- Lo que la figura afirma ---
    nrow(ENCABEZADOS) == 5L,
    all(grepl("^>", ENCABEZADOS$texto)),
    # dos de los cinco no tienen espacio
    sum(!ENCABEZADOS$tiene_espacio) == 2L,
    identical(which(!ENCABEZADOS$tiene_espacio), c(3L, 5L)),
    # y los que sí lo tienen en columnas distintas: por eso no hay recta
    length(unique(ENCABEZADOS$espacio[ENCABEZADOS$tiene_espacio])) == 3L,
    length(unique(ENCABEZADOS$fin_id)) > 1L,
    # sólo el histórico lleva GI
    sum(TRAMOS$papel == "gi") == 1L,
    unique(TRAMOS$fila[TRAMOS$papel == "gi"]) == 3L,

    # --- Los tramos caen dentro de su encabezado ---
    all(TRAMOS$de >= 1), all(TRAMOS$a >= TRAMOS$de),
    all(TRAMOS$a <= nchar(ENCABEZADOS$texto)[TRAMOS$fila]),
    # y ninguno se encima con otro de la misma fila
    all(vapply(split(TRAMOS, TRAMOS$fila), function(g) {
      g <- g[order(g$de), ]
      nrow(g) == 1L || all(g$de[-1] > head(g$a, -1))
    }, logical(1))),

    # --- Nada se sale del panel ---
    X_TXT + LARGO_MAX * CHAR <= ANCHO_PANEL,
    max(resaltas$xmax) <= ANCHO_PANEL,
    max(Y_FILA) + ALTO_RESALTA <= ALTO_PANEL,
    min(Y_FILA) - ALTO_RESALTA > Y_NOTA_CORTE + 2 * TAM_NOTA,
    Y_NOTA_CORTE - 2 * TAM_NOTA > Y_LEYENDA + 1.5,
    Y_LEYENDA - 1.5 >= 0,
    X_TXT + 2 * max(m_nota) <= ANCHO_PANEL,
    min(ley$x) >= 0, max(ley$x + ley$ancho) <= ANCHO_PANEL,
    # el rótulo de fuente no invade el texto
    X_ROTULO + 2 * max(media_ancho(ENCABEZADOS$fuente, TAM_ROTULO)) < X_TXT
  )

  message(sprintf("  %d encabezados; ancho de carácter %.2f mm (mono a %.2f mm)",
                  nrow(ENCABEZADOS), CHAR, TAM_MONO))
  message("  dónde termina el identificador:")
  for (i in seq_len(nrow(ENCABEZADOS))) {
    message(sprintf("    %-16s columna %2d%s",
                    sub("\n.*", "", ENCABEZADOS$fuente[i]),
                    ENCABEZADOS$fin_id[i],
                    if (ENCABEZADOS$tiene_espacio[i])
                      sprintf("  (primer espacio en la %d)", ENCABEZADOS$espacio[i])
                    else "  <- SIN ESPACIO: el identificador es todo"))
  }
  message("  -> tres columnas distintas y dos sin espacio: la recta vertical")
  message("     que pedía la especificación no existe. Ver el encabezado del script.")

  guardar(construir(), "encabezados", 18, 8)
}
