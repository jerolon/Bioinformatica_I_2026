## Fig. @fig-coordenadas (Sesión 2-3, § La trampa de las coordenadas)
## Las dos convenciones de coordenadas sobre el MISMO fragmento.
##
## Esquema puro. La única idea que tiene que quedar inequívoca es dónde caen los
## números de cada sistema:
##
##   1-based cerrado (GFF3, GTF, SAM, VCF): los números etiquetan las BASES,
##       y van centrados sobre cada cuadrado.
##   0-based semiabierto (BED): los números etiquetan los CORTES entre bases,
##       y van en las FRONTERAS, con una marquita que apunta al corte.
##
## Todo lo que dice la figura se calcula de INI, N_BASES y el par resaltado; los
## dos "start" y los dos "end" no están tecleados, salen de ahí. Si alguien
## mueve el resaltado, las etiquetas y las dos longitudes se recalculan solas y
## los stopifnot del final comprueban que sigan cuadrando.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion02/02_coordenadas.R

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
SECUENCIA <- "ACGTACGTAC"                 # diez bases, una por cuadrado
PRIMERA   <- 5L                           # primera base resaltada (1-based)
ULTIMA    <- 8L                           # última base resaltada (1-based)

BASES  <- strsplit(SECUENCIA, "", fixed = TRUE)[[1]]
N      <- length(BASES)

# Las cuatro cifras de la figura, DERIVADAS. Ésta es la regla del capítulo:
#   start_BED = start_GFF - 1   ·   el end no se toca.
GFF_START <- PRIMERA
GFF_END   <- ULTIMA
BED_START <- PRIMERA - 1L
BED_END   <- ULTIMA

LARGO_GFF <- GFF_END - GFF_START + 1L
LARGO_BED <- BED_END - BED_START

ETIQ_GFF <- sprintf("GFF / GTF / SAM / VCF:  start = %d, end = %d",
                    GFF_START, GFF_END)
ETIQ_BED <- sprintf("BED:  start = %d, end = %d", BED_START, BED_END)
TXT_GFF  <- sprintf("longitud GFF = %d - %d + 1 = %d", GFF_END, GFF_START, LARGO_GFF)
TXT_BED  <- sprintf("longitud BED = %d - %d = %d",     BED_END, BED_START, LARGO_BED)
NOTA     <- "el start difiere en 1; el end es el mismo número"


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 9) con 2 mm de margen a los lados: panel de 156 x 84 mm.
# 1 unidad = 1 mm, igual que el `size` de geom_text, así que los anchos de
# texto se pueden comparar contra los huecos en los stopifnot del final.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 84

LADO <- 11                                # lado de cada cuadrado
INI  <- (ANCHO_PANEL - N * LADO) / 2       # la fila va centrada en el panel

Y_CAJA_MIN <- 48
Y_CAJA_MAX <- Y_CAJA_MIN + LADO           # 48 .. 59

Y_NUM_1    <- 63                          # números 1-based, sobre los cuadrados
Y_LLAVE_1  <- 66.5                         # base de la llave de arriba
PROF_LLAVE <- 3.6
Y_ETIQ_1   <- 74

Y_TICK_ALT <- 3.5                         # marquitas de los cortes, bajo la fila
Y_NUM_0    <- 42                          # números 0-based, en las fronteras
Y_LLAVE_0  <- 38                          # base de la llave de abajo
Y_ETIQ_0   <- 30

Y_TXT_BED  <- 20
Y_TXT_GFF  <- 15
Y_NOTA     <- 6

X_ROTULO   <- INI - 3                     # rótulos de fila, alineados a la derecha

TAM_LETRA  <- 3.2                         # la base dentro del cuadrado
TAM_NUM    <- 2.2
TAM_ETIQ   <- 2.4
TAM_TXT    <- 2.3
TAM_ROTULO <- 1.9

SANS <- familia_base()
MONO <- familia_mono()

# --- Cuadrados --------------------------------------------------------------
# `corte` es la coordenada 0-based del borde IZQUIERDO de cada cuadrado; es la
# misma cuenta que hace BED, sólo que dibujada.
cuadros <- data.frame(
  base      = BASES,
  pos1      = seq_len(N),                 # 1-based: etiqueta la base
  corte     = seq_len(N) - 1L,            # 0-based: etiqueta el borde izquierdo
  stringsAsFactors = FALSE
)
cuadros$xmin      <- INI + cuadros$corte * LADO
cuadros$xmax      <- cuadros$xmin + LADO
cuadros$x         <- (cuadros$xmin + cuadros$xmax) / 2
cuadros$resaltado <- cuadros$pos1 >= PRIMERA & cuadros$pos1 <= ULTIMA

# Los cortes: N+1 fronteras, de 0 a N.
cortes <- data.frame(k = 0:N)
cortes$x <- INI + cortes$k * LADO
# Los dos cortes que BED nombra van resaltados: son la prueba visual de que el
# 4 y el 8 de BED caen en fronteras, no en bases.
cortes$usado <- cortes$k %in% c(BED_START, BED_END)

# Extremos del tramo resaltado, en milímetros. Los DOS sistemas describen este
# mismo par de milímetros: es el corazón de la figura.
X_IZQ <- INI + BED_START * LADO
X_DER <- INI + BED_END   * LADO

llave_gff <- llave(X_IZQ, X_DER, Y_LLAVE_1, PROF_LLAVE, arriba = TRUE)
llave_bed <- llave(X_IZQ, X_DER, Y_LLAVE_0, PROF_LLAVE, arriba = FALSE)


construir <- function() {
  ggplot() +
    # --- La fila de bases ---
    geom_rect(data = subset(cuadros, !resaltado),
              aes(xmin = xmin, xmax = xmax, ymin = Y_CAJA_MIN, ymax = Y_CAJA_MAX),
              fill = alpha(AZUL, 0.10), colour = AZUL, linewidth = 0.4) +
    geom_rect(data = subset(cuadros, resaltado),
              aes(xmin = xmin, xmax = xmax, ymin = Y_CAJA_MIN, ymax = Y_CAJA_MAX),
              fill = alpha(NARANJA, 0.28), colour = NARANJA, linewidth = 0.6) +
    geom_text(data = cuadros, aes(x = x, y = (Y_CAJA_MIN + Y_CAJA_MAX) / 2,
                                  label = base),
              family = MONO, size = TAM_LETRA, colour = TEXTO) +

    # --- Arriba: 1-based, los números etiquetan las BASES ---
    geom_text(data = cuadros, aes(x = x, y = Y_NUM_1, label = pos1,
                                  colour = resaltado),
              family = MONO, size = TAM_NUM, show.legend = FALSE) +
    geom_path(data = llave_gff, aes(x = x, y = y),
              colour = NARANJA, linewidth = 0.5, lineend = "round") +
    geom_text(data = data.frame(1), aes(x = (X_IZQ + X_DER) / 2, y = Y_ETIQ_1),
              label = ETIQ_GFF, family = MONO, size = TAM_ETIQ, colour = NARANJA) +

    # --- Abajo: 0-based, los números etiquetan los CORTES ---
    # Las marquitas son la mitad del mensaje: sin ellas, un número puesto entre
    # dos cuadrados se lee como si etiquetara al de la derecha.
    geom_segment(data = subset(cortes, !usado),
                 aes(x = x, xend = x, y = Y_CAJA_MIN,
                     yend = Y_CAJA_MIN - Y_TICK_ALT),
                 colour = GRIS, linewidth = 0.35) +
    geom_segment(data = subset(cortes, usado),
                 aes(x = x, xend = x, y = Y_CAJA_MIN,
                     yend = Y_CAJA_MIN - Y_TICK_ALT),
                 colour = NARANJA, linewidth = 0.7) +
    geom_text(data = cortes, aes(x = x, y = Y_NUM_0, label = k,
                                 colour = usado),
              family = MONO, size = TAM_NUM, show.legend = FALSE) +
    scale_colour_manual(values = c(`FALSE` = TEXTO, `TRUE` = NARANJA),
                        guide = "none") +
    geom_path(data = llave_bed, aes(x = x, y = y),
              colour = NARANJA, linewidth = 0.5, lineend = "round") +
    geom_text(data = data.frame(1), aes(x = (X_IZQ + X_DER) / 2, y = Y_ETIQ_0),
              label = ETIQ_BED, family = MONO, size = TAM_ETIQ, colour = NARANJA) +

    # --- Rótulos de fila, a la izquierda ---
    geom_text(data = data.frame(
                y   = c(Y_NUM_1, (Y_CAJA_MIN + Y_CAJA_MAX) / 2, Y_NUM_0),
                txt = c("posición 1-based", "bases", "corte 0-based")),
              aes(x = X_ROTULO, y = y, label = txt),
              family = SANS, size = TAM_ROTULO, colour = GRIS, hjust = 1) +

    # --- Las dos aritméticas y la moraleja ---
    geom_text(data = data.frame(y = c(Y_TXT_BED, Y_TXT_GFF),
                                txt = c(TXT_BED, TXT_GFF)),
              aes(x = INI, y = y, label = txt),
              family = MONO, size = TAM_TXT, colour = TEXTO, hjust = 0) +
    geom_text(data = data.frame(1), aes(x = INI, y = Y_NOTA), label = NOTA,
              family = SANS, size = TAM_TXT, colour = NARANJA, hjust = 0) +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = paste("Las dos llaves cubren exactamente el mismo tramo de la secuencia.",
                         "Lo único que cambia son los números con que se escribe.")) +
    tema_esquema()
}


if (!interactive()) {
  m_etiq  <- media_ancho(c(ETIQ_GFF, ETIQ_BED), TAM_ETIQ, AVANCE_MONO)
  m_txt   <- media_ancho(c(TXT_BED, TXT_GFF),   TAM_TXT,  AVANCE_MONO)
  m_nota  <- media_ancho(NOTA,                  TAM_TXT,  AVANCE_SANS)
  m_rot   <- media_ancho(c("posición 1-based", "bases", "corte 0-based"),
                         TAM_ROTULO, AVANCE_SANS)
  m_num   <- media_ancho(as.character(0:N), TAM_NUM, AVANCE_MONO)

  stopifnot(
    # --- La aritmética que enseña la figura ---
    BED_START == GFF_START - 1L,          # el start difiere en uno
    BED_END   == GFF_END,                 # el end es el mismo número
    LARGO_BED == LARGO_GFF,               # y las dos longitudes coinciden
    LARGO_GFF == ULTIMA - PRIMERA + 1L,
    sum(cuadros$resaltado) == LARGO_GFF,  # tantos cuadrados como dice la cuenta

    # --- Dónde caen los números: el punto entero de la figura ---
    # Los 1-based, en el CENTRO de su cuadrado; los 0-based, en las FRONTERAS.
    all(abs(cuadros$x - (cuadros$xmin + cuadros$xmax) / 2) < 1e-9),
    all(cortes$x %in% c(cuadros$xmin, cuadros$xmax)),
    !any(cortes$x %in% cuadros$x),        # ningún corte cae en un centro
    nrow(cortes) == N + 1L,               # hay un corte más que bases
    sum(cortes$usado) == 2L,              # BED nombra exactamente dos cortes

    # --- Las dos llaves cubren el MISMO tramo ---
    isTRUE(all.equal(X_IZQ, cuadros$xmin[cuadros$pos1 == PRIMERA])),
    isTRUE(all.equal(X_DER, cuadros$xmax[cuadros$pos1 == ULTIMA])),
    isTRUE(all.equal(range(llave_gff$x), range(llave_bed$x))),
    isTRUE(all.equal(X_DER - X_IZQ, LARGO_BED * LADO)),

    # --- Nada se sale del panel ---
    INI > 0, INI + N * LADO <= ANCHO_PANEL,
    X_ROTULO - 2 * max(m_rot) >= 0,       # los rótulos caben a la izquierda
    min(cortes$x - m_num) >= 0,
    max(cortes$x + m_num) <= ANCHO_PANEL,
    max(llave_gff$y) < Y_ETIQ_1 - TAM_ETIQ,
    Y_ETIQ_1 + TAM_ETIQ <= ALTO_PANEL,
    min(llave_bed$y) > Y_ETIQ_0 + TAM_ETIQ,
    all((X_IZQ + X_DER) / 2 - m_etiq >= 0),
    all((X_IZQ + X_DER) / 2 + m_etiq <= ANCHO_PANEL),
    all(INI + 2 * m_txt <= ANCHO_PANEL),
    INI + 2 * m_nota <= ANCHO_PANEL,

    # --- Nada se encima en vertical ---
    Y_NUM_1 > Y_CAJA_MAX + TAM_NUM / 2,
    Y_NUM_0 < Y_CAJA_MIN - Y_TICK_ALT - TAM_NUM / 2,
    Y_LLAVE_1 > Y_NUM_1 + TAM_NUM,
    Y_LLAVE_0 < Y_NUM_0 - TAM_NUM,
    Y_ETIQ_0 - TAM_ETIQ > Y_TXT_BED + TAM_TXT,
    Y_TXT_GFF - TAM_TXT > Y_NOTA + TAM_TXT
  )

  message(sprintf("  %d bases (%s), resaltadas %d..%d", N, SECUENCIA, PRIMERA, ULTIMA))
  message(sprintf("  GFF/GTF/SAM/VCF  start = %d  end = %d  ->  longitud %d",
                  GFF_START, GFF_END, LARGO_GFF))
  message(sprintf("  BED              start = %d  end = %d  ->  longitud %d",
                  BED_START, BED_END, LARGO_BED))
  message(sprintf("  las dos llaves van de x = %.1f a x = %.1f mm (el mismo tramo)",
                  X_IZQ, X_DER))

  guardar(construir(), "coordenadas", 16, 9)
}
