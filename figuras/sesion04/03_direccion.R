## Fig. @fig-direccion (Sesión 4, callout de § BLOSUM: la ruta de los Henikoff)
## PAM y BLOSUM numeran en direcciones opuestas.
##
## Esquema puro, sin datos. Toda la figura es un contraste visual: dos flechas
## naranjas apuntando en sentidos contrarios sobre la misma escala. Si alguien
## "arregla" la figura poniendo las dos flechas en el mismo sentido, deja de
## decir lo único que tiene que decir.
##
## La escala horizontal es CUALITATIVA y las cuatro posiciones están repartidas
## parejo. No se espacian por valor de PAM ni por entropía a propósito: las
## equivalencias entre las dos series son aproximadas, y espaciarlas por un
## número fingiría una precisión que no existe. La nota al pie lo dice.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion04/03_direccion.R

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
# Las equivalencias son las de la tabla del capítulo. Están ordenadas de
# parientes CERCANOS a LEJANOS, que es como se recorre la figura de izquierda a
# derecha: PAM crece, BLOSUM decrece.
EQUIVALENCIAS <- data.frame(
  pam    = c(100L, 120L, 160L, 250L),
  blosum = c( 90L,  80L,  62L,  45L),
  stringsAsFactors = FALSE
)

TXT_PAM    <- "número mayor = más divergencia"
TXT_BLOSUM <- "número mayor = secuencias más parecidas"
NOTA <- "Equivalencias aproximadas, basadas en entropía relativa."


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 8) con 2 mm de margen: panel de 156 x 74 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 74

X_INI <- 20                       # extremos de los dos ejes
X_FIN <- 140
X_MARCA_INI <- 34                 # primera y última marca
X_MARCA_FIN <- 126

Y_PAM    <- 50                    # línea del eje de PAM
Y_BLOSUM <- 24                    # línea del eje de BLOSUM

SEP_ETIQ <- 5.5                   # de la línea a su etiqueta
ALTO_MARCA <- 2

Y_FLECHA_PAM    <- 62
Y_FLECHA_BLOSUM <- 12
SEP_FLECHA_TXT  <- 4

Y_EXTREMOS <- 70                  # "parientes cercanos" / "parientes lejanos"
Y_NOTA     <- 3

TAM_MATRIZ <- 2.4
TAM_FLECHA <- 2.2
TAM_EXTREMO <- 2.1
TAM_NOTA   <- 2.0

SANS <- familia_base()
MONO <- familia_mono()


# --- Colocación -------------------------------------------------------------
n <- nrow(EQUIVALENCIAS)
EQUIVALENCIAS$x <- seq(X_MARCA_INI, X_MARCA_FIN, length.out = n)
EQUIVALENCIAS$etiqueta_pam    <- sprintf("PAM%d", EQUIVALENCIAS$pam)
EQUIVALENCIAS$etiqueta_blosum <- sprintf("BLOSUM%d", EQUIVALENCIAS$blosum)

# Las verticales punteadas: de un eje al otro, sin tocarlos.
conectores <- data.frame(
  x = EQUIVALENCIAS$x,
  y = Y_PAM - SEP_ETIQ - 2.5,
  yend = Y_BLOSUM + SEP_ETIQ + 2.5
)

# Las dos flechas. La de PAM va a la derecha (más divergencia), la de BLOSUM a
# la izquierda (números mayores = secuencias más parecidas = parientes
# cercanos, que están a la izquierda). Ese cruce ES la figura.
flechas <- data.frame(
  x    = c(X_MARCA_INI,  X_MARCA_FIN),
  xend = c(X_MARCA_FIN,  X_MARCA_INI),
  y    = c(Y_FLECHA_PAM, Y_FLECHA_BLOSUM),
  serie = c("PAM", "BLOSUM"),
  texto = c(TXT_PAM, TXT_BLOSUM),
  stringsAsFactors = FALSE
)
# La etiqueta de cada flecha va del lado en que NACE, para que se lea en el
# sentido del movimiento.
flechas$y_txt <- c(Y_FLECHA_PAM + SEP_FLECHA_TXT, Y_FLECHA_BLOSUM - SEP_FLECHA_TXT)


construir <- function() {
  ggplot() +
    # --- Los dos ejes ---
    geom_segment(data = data.frame(y = c(Y_PAM, Y_BLOSUM)),
                 aes(x = X_INI, xend = X_FIN, y = y, yend = y),
                 colour = AZUL, linewidth = 0.6) +
    geom_segment(data = rbind(
                   data.frame(x = EQUIVALENCIAS$x, y = Y_PAM),
                   data.frame(x = EQUIVALENCIAS$x, y = Y_BLOSUM)),
                 aes(x = x, xend = x, y = y - ALTO_MARCA, yend = y + ALTO_MARCA),
                 colour = AZUL, linewidth = 0.5) +

    # --- Verticales punteadas entre pares equivalentes ---
    geom_segment(data = conectores,
                 aes(x = x, xend = x, y = y, yend = yend),
                 colour = alpha(GRIS, 0.9), linewidth = 0.45, linetype = "dotted") +

    # --- Nombres de las matrices ---
    geom_text(data = EQUIVALENCIAS,
              aes(x = x, y = Y_PAM + SEP_ETIQ, label = etiqueta_pam),
              family = MONO, size = TAM_MATRIZ, colour = TEXTO) +
    geom_text(data = EQUIVALENCIAS,
              aes(x = x, y = Y_BLOSUM - SEP_ETIQ, label = etiqueta_blosum),
              family = MONO, size = TAM_MATRIZ, colour = TEXTO) +

    # --- Nombre de cada serie, al principio de su eje ---
    geom_text(data = data.frame(y = c(Y_PAM, Y_BLOSUM),
                                txt = c("PAM", "BLOSUM")),
              aes(x = X_INI - 2, y = y, label = txt),
              family = SANS, size = TAM_MATRIZ, colour = AZUL, hjust = 1,
              fontface = "bold") +

    # --- Las dos flechas, en sentidos opuestos ---
    geom_segment(data = flechas, aes(x = x, xend = xend, y = y, yend = y),
                 colour = NARANJA, linewidth = 0.7, arrow.fill = NARANJA,
                 arrow = arrow(length = unit(2.2, "mm"), type = "closed")) +
    geom_text(data = flechas, aes(x = (x + xend) / 2, y = y_txt, label = texto),
              family = SANS, size = TAM_FLECHA, colour = NARANJA) +

    # --- Los extremos de la escala ---
    geom_text(data = data.frame(x = c(X_INI, X_FIN), h = c(0, 1),
                                txt = c("parientes cercanos", "parientes lejanos")),
              aes(x = x, y = Y_EXTREMOS, label = txt, hjust = h),
              family = SANS, size = TAM_EXTREMO, colour = GRIS) +

    geom_text(data = data.frame(1), aes(x = X_INI, y = Y_NOTA), label = NOTA,
              family = SANS, size = TAM_NOTA, colour = GRIS, hjust = 0) +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = paste("Esquema. La escala horizontal es cualitativa:",
                         "las cuatro posiciones están repartidas parejo,",
                         "no espaciadas por valor.")) +
    tema_esquema()
}


if (!interactive()) {
  m_flecha <- media_ancho(flechas$texto, TAM_FLECHA)
  m_matriz <- media_ancho(c(EQUIVALENCIAS$etiqueta_pam,
                            EQUIVALENCIAS$etiqueta_blosum),
                          TAM_MATRIZ, AVANCE_MONO)
  m_nota <- media_ancho(NOTA, TAM_NOTA)

  stopifnot(
    # --- Lo que la figura afirma ---
    nrow(EQUIVALENCIAS) == 4L,
    # PAM crece de izquierda a derecha y BLOSUM decrece: el punto entero
    !is.unsorted(EQUIVALENCIAS$pam),
    !is.unsorted(rev(EQUIVALENCIAS$blosum)),
    # y las dos flechas apuntan en sentidos opuestos
    sign(flechas$xend[1] - flechas$x[1]) == -sign(flechas$xend[2] - flechas$x[2]),
    # las equivalencias son las de la tabla del capítulo
    identical(EQUIVALENCIAS$pam,    c(100L, 120L, 160L, 250L)),
    identical(EQUIVALENCIAS$blosum, c( 90L,  80L,  62L,  45L)),

    # --- La geometría ---
    # los conectores unen los dos ejes sin tocarlos
    all(conectores$y < Y_PAM), all(conectores$yend > Y_BLOSUM),
    all(conectores$y > conectores$yend),
    X_INI < X_MARCA_INI, X_MARCA_FIN < X_FIN,
    Y_BLOSUM < Y_PAM,

    # --- Nada se sale del panel, nada se encima ---
    Y_EXTREMOS + TAM_EXTREMO <= ALTO_PANEL,
    Y_FLECHA_PAM + SEP_FLECHA_TXT + TAM_FLECHA < Y_EXTREMOS,
    Y_FLECHA_BLOSUM - SEP_FLECHA_TXT - TAM_FLECHA > Y_NOTA + TAM_NOTA,
    Y_PAM + SEP_ETIQ + TAM_MATRIZ < Y_FLECHA_PAM,
    Y_BLOSUM - SEP_ETIQ - TAM_MATRIZ > Y_FLECHA_BLOSUM,
    all((flechas$x + flechas$xend) / 2 - m_flecha >= 0),
    all((flechas$x + flechas$xend) / 2 + m_flecha <= ANCHO_PANEL),
    # las etiquetas de matriz caben entre marca y marca
    all(2 * m_matriz < diff(EQUIVALENCIAS$x)[1] - 1),
    X_INI + 2 * m_nota <= ANCHO_PANEL
  )

  message("  equivalencias aproximadas PAM <-> BLOSUM:")
  for (i in seq_len(nrow(EQUIVALENCIAS))) {
    message(sprintf("    %-7s  ~  %-9s   (x = %.0f mm)",
                    EQUIVALENCIAS$etiqueta_pam[i],
                    EQUIVALENCIAS$etiqueta_blosum[i], EQUIVALENCIAS$x[i]))
  }
  message("  PAM crece hacia la derecha; BLOSUM decrece. Flechas opuestas.")

  guardar(construir(), "direccion-numeracion", 16, 8)
}
