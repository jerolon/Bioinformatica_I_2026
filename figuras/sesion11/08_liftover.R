## Fig. @fig-liftover (Sesión 11, § Convertir coordenadas, y por qué duele)
## Los cuatro destinos de un intervalo al pasar de un ensamblado a otro.
##
## ---------------------------------------------------------------------------
## POR QUÉ EL PRIMER DESTINO ES "MAPEA LIMPIO" Y NO UN CUARTO MODO DE FALLA
##
## El caption del capítulo dice "Cuatro destinos posibles al convertir
## coordenadas. Solo el primero es el que la gente espera", así que el primero
## tiene que ser el caso bueno. La prosa del capítulo, en cambio, enumera
## cuatro FORMAS DE PERDER (no mapea, se parte, mapea a varios lugares, se
## invierte). No es contradicción: la prosa cuenta las pérdidas y la figura
## cuenta los destinos. Se sigue la especificación de la figura, que es la que
## concuerda con el caption.
##
## El caso "mapea a varios lugares" queda fuera del dibujo por espacio; está en
## la prosa. Anotado en FIGURAS-unidad5.md por si se quiere una quinta fila.
##
## LA CAJA .unmap NO ES UN PIE DE PÁGINA. Va del mismo tamaño que los destinos
## buenos y en naranja, porque el argumento del capítulo es que ese archivo se
## abre SIEMPRE y casi nadie lo abre.
## ---------------------------------------------------------------------------
##
## Esquema: no afirma ninguna cantidad. Sin título dentro del SVG.
##
## Regenerar:  Rscript figuras/sesion11/08_liftover.R

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
# guardar(w = 16, h = 10) con 2 mm de margen: panel de 156 x 96 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 96

X_ORIG <- 8;   W_ORIG <- 30       # los intervalos del ensamblado origen
X_DEST <- 96;  W_DEST <- 30       # los del destino
ALTO_INT <- 5.5

Y_FILA <- c(78, 58, 38, 16)       # una fila por destino
Y_CABEZA <- 90

SANS <- familia_base()
MONO <- familia_mono()

TAM_CABEZA <- 2.5
TAM_ETIQ   <- 2.3
TAM_SUB    <- 1.95

destinos <- data.frame(
  y = Y_FILA,
  nombre = c("Mapea limpio", "Se parte", "Se invierte", "No mapea"),
  detalle = c("mismo intervalo, otra dirección",
              "el destino lo parte en dos bloques",
              "el contig cambió de orientación",
              "la región no existe o se reorganizó"),
  color = c(VERDE, AZUL, AZUL, NARANJA),
  stringsAsFactors = FALSE
)


# --- La geometría, a nivel de módulo ----------------------------------------
# Vive fuera de construir() para que los stopifnot puedan medirla. Dentro de la
# función quedaba invisible a las comprobaciones, y una de ellas (la rama que
# atravesaba un bloque) es justo la que hacía falta.

  # --- Los intervalos de origen: uno por fila, todos iguales ---
  orig <- data.frame(xmin = X_ORIG, xmax = X_ORIG + W_ORIG,
                     ymin = Y_FILA - ALTO_INT / 2, ymax = Y_FILA + ALTO_INT / 2)

  # --- Los destinos, uno por caso ---
  # 1. limpio: un bloque igual
  d1 <- data.frame(xmin = X_DEST, xmax = X_DEST + W_DEST,
                   ymin = Y_FILA[1] - ALTO_INT / 2, ymax = Y_FILA[1] + ALTO_INT / 2)
  # 2. partido: dos bloques con un hueco
  d2 <- data.frame(
    xmin = c(X_DEST, X_DEST + 18), xmax = c(X_DEST + 12, X_DEST + W_DEST),
    ymin = Y_FILA[2] - ALTO_INT / 2, ymax = Y_FILA[2] + ALTO_INT / 2)
  # 3. invertido: un bloque igual, pero la flecha de hebra al revés
  d3 <- data.frame(xmin = X_DEST, xmax = X_DEST + W_DEST,
                   ymin = Y_FILA[3] - ALTO_INT / 2, ymax = Y_FILA[3] + ALTO_INT / 2)

  # --- La caja .unmap ---
  caja_unmap <- caja_redonda(X_DEST, X_DEST + W_DEST,
                             Y_FILA[4] - ALTO_INT / 2 - 1.5,
                             Y_FILA[4] + ALTO_INT / 2 + 1.5, r = 1.5)

  # --- Las flechas ---
  fl <- function(y0, y1, ini = X_ORIG + W_ORIG + 2, fin = X_DEST - 2) {
    data.frame(x = ini, y = y0, xend = fin, yend = y1)
  }
  f1 <- fl(Y_FILA[1], Y_FILA[1])
  f3 <- fl(Y_FILA[3], Y_FILA[3])
  # la que no mapea: termina antes, en una X
  f4 <- fl(Y_FILA[4], Y_FILA[4], fin = X_DEST - 16)

  # --- La bifurcación de "se parte" --------------------------------------
  # Un tronco que llega hasta antes de los destinos y ahí se abre en dos: una
  # rama recta al primer bloque y otra que pasa POR ENCIMA del primero para
  # caer sobre el segundo. La primera versión mandaba la segunda rama en línea
  # recta y le atravesaba el bloque 1, que se leía como una flecha clavada en
  # una caja en vez de como una bifurcación.
  X_FORK <- X_DEST - 17
  tronco2 <- data.frame(x = X_ORIG + W_ORIG + 2, y = Y_FILA[2],
                        xend = X_FORK, yend = Y_FILA[2])
  rama2a  <- data.frame(x = X_FORK, y = Y_FILA[2],
                        xend = X_DEST - 2, yend = Y_FILA[2])
  X_B2 <- X_DEST + 24                                  # centro del bloque 2
  rama2b <- llamada(X_FORK, Y_FILA[2], X_B2, Y_FILA[2] + ALTO_INT / 2 + 1.6,
                    comba = 0.30)

  X_X <- X_DEST - 13                # centro de la X
  aspa <- rbind(
    data.frame(x = X_X - 2, y = Y_FILA[4] - 2, xend = X_X + 2, yend = Y_FILA[4] + 2),
    data.frame(x = X_X - 2, y = Y_FILA[4] + 2, xend = X_X + 2, yend = Y_FILA[4] - 2)
  )


construir <- function() {
  ggplot() +
    # --- Encabezados de columna ---
    annotate("text", x = X_ORIG, y = Y_CABEZA, label = "ensamblado origen",
             family = SANS, size = TAM_CABEZA, colour = GRIS,
             fontface = "bold", hjust = 0) +
    annotate("text", x = X_DEST, y = Y_CABEZA, label = "ensamblado destino",
             family = SANS, size = TAM_CABEZA, colour = GRIS,
             fontface = "bold", hjust = 0) +

    # --- Intervalos de origen ---
    geom_rect(data = orig, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = alpha(GRIS_CAJA, 0.9), colour = GRIS_BORDE, linewidth = 0.35) +

    # --- Flechas ---
    geom_segment(data = f1, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = VERDE, linewidth = 0.5,
                 arrow = arrow(length = unit(2.2, "mm"), type = "closed")) +
    geom_segment(data = tronco2, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = AZUL, linewidth = 0.45) +
    geom_segment(data = rama2a, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = AZUL, linewidth = 0.45,
                 arrow = arrow(length = unit(2.0, "mm"), type = "closed")) +
    geom_path(data = rama2b, aes(x = x, y = y),
              colour = AZUL, linewidth = 0.45,
              arrow = arrow(length = unit(2.0, "mm"), type = "closed")) +
    geom_segment(data = f3, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = AZUL, linewidth = 0.5,
                 arrow = arrow(length = unit(2.2, "mm"), type = "closed")) +
    geom_segment(data = f4, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = NARANJA, linewidth = 0.5) +
    geom_segment(data = aspa, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = NARANJA, linewidth = 0.7, lineend = "round") +

    # --- Destinos ---
    geom_rect(data = d1, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = alpha(VERDE, 0.20), colour = VERDE, linewidth = 0.4) +
    geom_rect(data = d2, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = alpha(AZUL_CLARO, 0.25), colour = AZUL, linewidth = 0.4) +
    geom_rect(data = d3, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = alpha(AZUL_CLARO, 0.25), colour = AZUL, linewidth = 0.4) +
    geom_polygon(data = caja_unmap, aes(x = x, y = y),
                 fill = alpha(NARANJA, 0.14), colour = NARANJA,
                 linewidth = 0.5, linetype = "dashed") +

    # --- Símbolos de hebra: el origen en +, el destino invertido en - ---
    annotate("text", x = X_ORIG + W_ORIG - 3, y = Y_FILA[3], label = "→",
             family = SANS, size = 3.0, colour = GRIS) +
    annotate("text", x = X_DEST + 3, y = Y_FILA[3], label = "←",
             family = SANS, size = 3.0, colour = AZUL, fontface = "bold") +
    annotate("text", x = X_DEST + W_DEST / 2, y = Y_FILA[3] - 5.5,
             label = "hebra volteada", family = SANS, size = TAM_SUB,
             colour = AZUL, fontface = "italic") +

    # --- El rótulo de la caja .unmap ---
    annotate("text", x = X_DEST + W_DEST / 2, y = Y_FILA[4], label = ".unmap",
             family = MONO, size = TAM_ETIQ, colour = NARANJA,
             fontface = "bold") +
    annotate("text", x = X_DEST + W_DEST / 2, y = Y_FILA[4] - 7,
             label = "este archivo siempre se revisa", family = SANS,
             size = TAM_SUB, colour = NARANJA, fontface = "bold") +

    # --- Rótulos de cada fila ---
    geom_text(data = destinos,
              aes(x = X_ORIG + W_ORIG + 4, y = y + 4.5, label = nombre,
                  colour = I(color)),
              family = SANS, size = TAM_ETIQ, fontface = "bold", hjust = 0) +
    geom_text(data = destinos,
              aes(x = X_ORIG + W_ORIG + 4, y = y - 4.5, label = detalle),
              family = SANS, size = TAM_SUB, colour = GRIS, hjust = 0) +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    tema_esquema()
}


if (!interactive()) {
  m_det <- media_ancho(destinos$detalle, TAM_SUB)
  m_nom <- media_ancho(destinos$nombre, TAM_ETIQ)

  stopifnot(
    # --- Los cuatro destinos, en el orden del caption ---
    nrow(destinos) == 4L,
    destinos$nombre[1] == "Mapea limpio",       # "solo el primero es el que
    destinos$color[1] == VERDE,                 #  la gente espera"
    destinos$nombre[4] == "No mapea",
    destinos$color[4] == NARANJA,               # el .unmap va en naranja

    # --- Las filas van de arriba hacia abajo y no se enciman ---
    all(diff(Y_FILA) < 0),
    all(abs(diff(Y_FILA)) > ALTO_INT + 8),

    # --- Nada se sale del panel ---
    X_DEST + W_DEST <= ANCHO_PANEL,
    X_ORIG + W_ORIG < X_DEST,
    # los rótulos de fila caben en el hueco entre las dos columnas
    all(X_ORIG + W_ORIG + 4 + 2 * m_det <= X_DEST - 2),
    all(X_ORIG + W_ORIG + 4 + 2 * m_nom <= X_DEST - 2),
    Y_CABEZA <= ALTO_PANEL,
    max(Y_FILA) + ALTO_INT / 2 < Y_CABEZA - TAM_CABEZA,
    min(Y_FILA) - 7 - TAM_SUB >= 0,

    # --- "Se parte" son DOS bloques con hueco entre ellos ---
    nrow(d2) == 2L,
    d2$xmin[2] > d2$xmax[1],

    # --- Y la rama que va al segundo bloque pasa POR ENCIMA del primero, no
    #     a través. Ésta es la comprobación que faltaba: la primera versión
    #     dibujaba una recta que atravesaba el bloque 1 y se leía como una
    #     flecha clavada en una caja. ---
    {
      # puntos de la curva que caen sobre el ancho del bloque 1
      sobre <- rama2b[rama2b$x >= d2$xmin[1] & rama2b$x <= d2$xmax[1], ]
      nrow(sobre) > 0 && all(sobre$y > d2$ymax[1] + 0.5)
    },
    # la rama termina sobre el segundo bloque, no en el aire
    abs(rama2b$x[nrow(rama2b)] - (d2$xmin[2] + d2$xmax[2]) / 2) < 3,
    # y baja al final, para que la punta de flecha apunte hacia el bloque
    rama2b$y[nrow(rama2b)] < rama2b$y[nrow(rama2b) - 1]
  )

  message("  cuatro destinos de liftOver:")
  for (k in seq_len(nrow(destinos))) {
    message(sprintf("    %d. %-14s %s", k, destinos$nombre[k], destinos$detalle[k]))
  }
  message("  'mapea a varios lugares' queda en la prosa, no en el dibujo")
  message("  la caja .unmap va en naranja y del mismo tamaño que los destinos buenos")

  guardar(construir(), "liftover", 16, 10)
}
