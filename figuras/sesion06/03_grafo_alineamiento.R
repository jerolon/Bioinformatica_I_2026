## Fig. @fig-grafo (Sesión 6, "La revelación")
## El grafo de alineamiento y un camino: son la misma cosa.
##
## La figura climática del capítulo. Arriba, el grafo completo de v = ATGT
## contra w = ACGT (5x5 nodos, con TODAS sus aristas dibujadas en gris tenue) y
## un camino resaltado de (0,0) a (4,4). Abajo, el alineamiento que le
## corresponde, columna por columna.
##
## El alineamiento NO está escrito a mano: se DERIVA del camino, paso por paso,
## con las mismas tres reglas que enuncia el capítulo (diagonal = alineo uno de
## cada una, horizontal = hueco en v, vertical = hueco en w). Los stopifnot
## comprueban las dos direcciones de la equivalencia:
##
##   - que al quitarle los guiones al renglón de arriba salga v, y al de abajo
##     salga w (o sea, que el camino es un alineamiento legal);
##   - que el camino use los tres tipos de arista y que tenga al menos una
##     coincidencia y una discrepancia, que es lo que la figura tiene que
##     mostrar para que la leyenda de colores signifique algo.
##
## Las secuencias son cortas a propósito: con cuatro símbolos de cada lado el
## alineamiento de abajo se lee entero y el grafo todavía cabe.
##
## Camino elegido acá, secuencias elegidas acá. Nada calcado de Compeau y
## Pevzner (ver el aviso de licencia en _tema.R).
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion06/03_grafo_alineamiento.R

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


# --- Las secuencias y el camino ---------------------------------------------
V <- "SELE"
W <- "SALE"
HUECO <- "-"

v <- strsplit(V, "", fixed = TRUE)[[1]]
w <- strsplit(W, "", fixed = TRUE)[[1]]
NV <- length(v); NW <- length(w)

# El camino, como sucesión de nodos (i, j). i = símbolos de v consumidos,
# j = símbolos de w consumidos. Elegido para que mezcle los tres movimientos y
# para que entre las diagonales haya una coincidencia Y una discrepancia.
CAMINO <- data.frame(
  i = c(0, 1, 1, 2, 3, 4),
  j = c(0, 1, 2, 3, 3, 4)
)

#' Traduce el camino a alineamiento, con las tres reglas del capítulo.
#' Es la mitad "recorrer el grafo es construir el alineamiento" de la
#' equivalencia; el stopifnot de abajo comprueba la otra mitad.
traducir <- function(cam) {
  fila_v <- character(0); fila_w <- character(0)
  tipo   <- character(0)
  for (k in seq_len(nrow(cam) - 1)) {
    di <- cam$i[k + 1] - cam$i[k]
    dj <- cam$j[k + 1] - cam$j[k]
    if (di == 1 && dj == 1) {                      # diagonal
      a <- v[cam$i[k + 1]]; b <- w[cam$j[k + 1]]
      tipo <- c(tipo, if (a == b) "coincidencia" else "discrepancia")
    } else if (di == 0 && dj == 1) {               # horizontal: hueco en v
      a <- HUECO; b <- w[cam$j[k + 1]]
      tipo <- c(tipo, "hueco_v")
    } else if (di == 1 && dj == 0) {               # vertical: hueco en w
      a <- v[cam$i[k + 1]]; b <- HUECO
      tipo <- c(tipo, "hueco_w")
    } else {
      stop(sprintf("paso ilegal en el camino: (%d,%d) -> (%d,%d)",
                   cam$i[k], cam$j[k], cam$i[k + 1], cam$j[k + 1]))
    }
    fila_v <- c(fila_v, a); fila_w <- c(fila_w, b)
  }
  list(v = fila_v, w = fila_w, tipo = tipo)
}

AL <- traducir(CAMINO)
N_PASOS <- length(AL$tipo)

# Color de cada paso: verde si la diagonal es coincidencia, azul en todo lo
# demás. Es la misma clave para la arista del grafo y para la columna de abajo.
color_paso <- function(t) ifelse(t == "coincidencia", VERDE, AZUL)
COL_PASO <- color_paso(AL$tipo)

# Marca entre los dos renglones del alineamiento, como se anota a mano.
MARCA <- c(coincidencia = "|", discrepancia = "×",
           hueco_v = "", hueco_w = "")[AL$tipo]


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 14) con 2 mm de margen lateral y el caption abajo.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 133

XG0 <- 30; PASO_X <- 23    # columnas j = 0..4 -> x = 30, 53, 76, 99, 122
YG0 <- 122; PASO_Y <- 17   # filas    i = 0..4 -> y = 122, 105, 88, 71, 54

xg <- function(j) XG0 + PASO_X * j
yg <- function(i) YG0 - PASO_Y * i

Y_LETRAS_W <- 128          # las letras de w, arriba del grafo
X_LETRAS_V <- 21           # las letras de v, a la izquierda

Y_GUIA_FIN <- 46           # donde terminan las guías punteadas
Y_AL       <- c(v = 40, marca = 33.5, w = 27)
# Las columnas del alineamiento van a paso FIJO, aunque los pasos del camino
# no estén igual de separados: un alineamiento monoespaciado sólo se lee si
# sus columnas son parejas. De ahí que algunas guías salgan inclinadas.
X_AL0      <- 42; PASO_AL <- 17
X_AL_ETIQ  <- 33                       # las etiquetas "v" y "w"

Y_LEY   <- c(18, 10.5, 3)              # los tres renglones de la leyenda
X_LEY_M <- 3; X_LEY_T <- 14            # muestra y texto de la leyenda

R_NODO   <- 1.2
TAM_SEC   <- 5                       # las letras de v y w junto al grafo
TAM_AL    <- 5                       # las letras del alineamiento
TAM_COORD <- 3
TAM_LEY   <- 3

SANS <- familia_base()
MONO <- familia_mono()

xal <- function(k) X_AL0 + PASO_AL * (k - 1)


# --- El grafo completo ------------------------------------------------------
# Todas las aristas: diagonales, horizontales y verticales. Que se vean todas
# es parte del argumento: el grafo está completo y el camino es UNO de muchos.
todas_aristas <- do.call(rbind, c(
  # diagonales
  lapply(1:NV, function(i) do.call(rbind, lapply(1:NW, function(j)
    data.frame(i0 = i - 1, j0 = j - 1, i1 = i, j1 = j)))),
  # horizontales
  lapply(0:NV, function(i) do.call(rbind, lapply(1:NW, function(j)
    data.frame(i0 = i, j0 = j - 1, i1 = i, j1 = j)))),
  # verticales
  lapply(1:NV, function(i) do.call(rbind, lapply(0:NW, function(j)
    data.frame(i0 = i - 1, j0 = j, i1 = i, j1 = j))))
))

seg_todas <- do.call(rbind, Map(function(x0, y0, x1, y1)
  recortar(x0, y0, x1, y1, ini = R_NODO + 0.9, fin = R_NODO + 1.8),
  xg(todas_aristas$j0), yg(todas_aristas$i0),
  xg(todas_aristas$j1), yg(todas_aristas$i1)))

nodos <- expand.grid(i = 0:NV, j = 0:NW)
nodos$x <- xg(nodos$j); nodos$y <- yg(nodos$i)


# --- El camino resaltado ----------------------------------------------------
pasos <- data.frame(
  k    = seq_len(N_PASOS),
  x    = xg(CAMINO$j[-nrow(CAMINO)]), y    = yg(CAMINO$i[-nrow(CAMINO)]),
  xend = xg(CAMINO$j[-1]),            yend = yg(CAMINO$i[-1]),
  tipo = AL$tipo, col = COL_PASO
)
pasos$xm <- (pasos$x + pasos$xend) / 2
pasos$ym <- (pasos$y + pasos$yend) / 2

# Guías punteadas de cada paso del camino a su columna del alineamiento.
guias <- data.frame(x = pasos$xm, y = pasos$ym,
                    xend = xal(pasos$k), yend = Y_GUIA_FIN)


# --- Las letras de las secuencias junto al grafo ----------------------------
# La letra va en el punto medio del intervalo, porque el paso de la fila i-1 a
# la i es el que consume v[i]. Así se ve qué símbolo consume cada arista.
letras_v <- data.frame(x = X_LETRAS_V, y = (yg(0:(NV - 1)) + yg(1:NV)) / 2,
                       txt = v)
letras_w <- data.frame(x = (xg(0:(NW - 1)) + xg(1:NW)) / 2, y = Y_LETRAS_W,
                       txt = w)

# La fuente se etiqueta a su izquierda y el sumidero abajo a su derecha, para
# no pelearse con la esquina "v \ w" ni con la última letra de w.
coords <- data.frame(
  x   = c(xg(0) - 4, xg(NW) + 3),
  y   = c(yg(0), yg(NV) - 4),
  txt = c("(0,0)", sprintf("(%d,%d)", NV, NW)),
  h   = c(1, 0)
)


# --- El alineamiento de abajo -----------------------------------------------
# unname() en las y: Y_AL es un vector con nombres y data.frame los arrastraría
# como nombres de renglón, con warning.
cols_al <- rbind(
  data.frame(x = xal(seq_len(N_PASOS)), y = unname(Y_AL["v"]),
             txt = AL$v, col = COL_PASO),
  data.frame(x = xal(seq_len(N_PASOS)), y = unname(Y_AL["w"]),
             txt = AL$w, col = COL_PASO)
)
# Los guiones se leen en gris: no son símbolos de la secuencia.
cols_al$col[cols_al$txt == HUECO] <- GRIS

marcas_al <- data.frame(x = xal(seq_len(N_PASOS)), y = unname(Y_AL["marca"]),
                        txt = unname(MARCA), col = COL_PASO)
marcas_al <- marcas_al[nzchar(marcas_al$txt), ]

etiq_al <- data.frame(x = X_AL_ETIQ, y = unname(Y_AL[c("v", "w")]),
                      txt = c("v", "w"))


# --- La leyenda -------------------------------------------------------------
TXT_LEY <- c(
  "diagonal    →  alineo un símbolo de cada una  (coincidencia o discrepancia)",
  "horizontal  →  hueco en v  (consumo solo de w)",
  "vertical    →  hueco en w  (consumo solo de v)"
)

# Muestras: una diagonal partida en verde y azul (los dos casos), una
# horizontal y una vertical, con la misma pinta que en el grafo.
L <- 7
muestras <- data.frame(
  x    = c(X_LEY_M,     X_LEY_M + L / 2, X_LEY_M,     X_LEY_M + L / 2),
  y    = c(Y_LEY[1], Y_LEY[1] - 2,       Y_LEY[2],    Y_LEY[3] - 2.5),
  xend = c(X_LEY_M + L / 2, X_LEY_M + L, X_LEY_M + L, X_LEY_M + L / 2),
  yend = c(Y_LEY[1]  - 2,    Y_LEY[1] - 4,    Y_LEY[2],    Y_LEY[3] + 2.5),
  col  = c(VERDE, AZUL, AZUL, AZUL)
)


construir <- function() {
  ggplot() +
    # --- Guías punteadas, hasta el fondo ---
    geom_segment(data = guias, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = alpha(GRIS, 0.30), linewidth = 0.3, linetype = "12") +

    # --- El grafo completo, tenue: diagonales, horizontales y verticales ---
    geom_segment(data = seg_todas, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = GRIS_TENUE, linewidth = 0.3,
                 arrow = arrow(length = unit(1.1, "mm"), type = "open")) +

    # --- El camino ---
    geom_segment(data = pasos, aes(x = x, y = y, xend = xend, yend = yend,
                                   colour = col),
                 linewidth = 1.4, lineend = "round") +

    # --- Los nodos ---
    geom_point(data = nodos, aes(x = x, y = y), shape = 21,
               fill = "white", colour = GRIS, size = 1.9, stroke = 0.4) +

    # --- Las secuencias junto al grafo ---
    geom_text(data = letras_v, aes(x = x, y = y, label = txt),
              family = MONO, size = TAM_SEC, colour = TEXTO, fontface = "bold") +
    geom_text(data = letras_w, aes(x = x, y = y, label = txt),
              family = MONO, size = TAM_SEC, colour = TEXTO, fontface = "bold") +
    geom_text(data = data.frame(1), aes(x = X_LETRAS_V, y = Y_LETRAS_W),
              label = "v \\ w", family = SANS, size = TAM_COORD, colour = GRIS) +
    geom_text(data = coords, aes(x = x, y = y, label = txt, hjust = h),
              family = SANS, size = TAM_COORD, colour = GRIS) +

    # --- El alineamiento correspondiente ---
    geom_text(data = cols_al, aes(x = x, y = y, label = txt, colour = col),
              family = MONO, size = TAM_AL, fontface = "bold") +
    geom_text(data = marcas_al, aes(x = x, y = y, label = txt, colour = col),
              family = MONO, size = TAM_AL * 0.8) +
    geom_text(data = etiq_al, aes(x = x, y = y, label = txt),
              family = MONO, size = TAM_AL, colour = GRIS, hjust = 1) +

    # --- La leyenda de los tres movimientos ---
    geom_segment(data = muestras, aes(x = x, y = y, xend = xend, yend = yend,
                                      colour = col),
                 linewidth = 1.2, lineend = "round") +
    geom_text(data = data.frame(x = X_LEY_T, y = Y_LEY, txt = TXT_LEY),
              aes(x = x, y = y, label = txt), family = MONO, size = TAM_LEY,
              colour = TEXTO, hjust = 0) +

    scale_colour_identity() +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = sprintf(paste("v = %s contra w = %s. El alineamiento de abajo",
                                 "se deriva del camino, paso por paso."), V, W)) +
    tema_esquema()
}


if (!interactive()) {
  sin_huecos <- function(x) paste(x[x != HUECO], collapse = "")

  stopifnot(
    # --- El camino es legal y va de la fuente al sumidero ---
    CAMINO$i[1] == 0, CAMINO$j[1] == 0,
    CAMINO$i[nrow(CAMINO)] == NV, CAMINO$j[nrow(CAMINO)] == NW,
    all(diff(CAMINO$i) >= 0), all(diff(CAMINO$j) >= 0),

    # --- LA EQUIVALENCIA, en la dirección que la figura afirma ---
    # Quitarle los guiones al renglón de arriba tiene que devolver v, y al de
    # abajo, w. Si no, el dibujo estaría mintiendo.
    sin_huecos(AL$v) == V,
    sin_huecos(AL$w) == W,
    length(AL$v) == length(AL$w),
    length(AL$v) == N_PASOS,
    # Nunca un hueco contra un hueco.
    !any(AL$v == HUECO & AL$w == HUECO),

    # --- El camino mezcla los tres movimientos ---
    sum(AL$tipo %in% c("coincidencia", "discrepancia")) >= 1,
    sum(AL$tipo == "hueco_v") >= 1,
    sum(AL$tipo == "hueco_w") >= 1,
    # y tiene de los dos tipos de diagonal, para que la leyenda de color sirva
    sum(AL$tipo == "coincidencia") >= 1,
    sum(AL$tipo == "discrepancia") >= 1,

    # --- El grafo está completo ---
    nrow(todas_aristas) == NV * NW + (NV + 1) * NW + NV * (NW + 1),
    nrow(nodos) == (NV + 1) * (NW + 1),

    # --- Nada se sale del panel ---
    Y_LETRAS_W + TAM_SEC / 2 <= ALTO_PANEL,
    X_LETRAS_V - TAM_SEC / 2 >= 0,
    xg(NW) + 3 + media_ancho("(4,4)", TAM_COORD) * 2 <= ANCHO_PANEL,
    xg(0) - 4 - media_ancho("(0,0)", TAM_COORD) * 2 >= 0,
    yg(0) + TAM_COORD < Y_LETRAS_W - TAM_COORD,    # (0,0) no toca la esquina v\w
    xal(N_PASOS) + TAM_AL <= ANCHO_PANEL,
    X_LEY_T + media_ancho(TXT_LEY, TAM_LEY, AVANCE_MONO) * 2 <= ANCHO_PANEL,
    min(Y_LEY) - TAM_LEY >= 0,
    max(Y_LEY) + TAM_LEY < Y_AL["w"] - TAM_AL,
    Y_AL["v"] + TAM_AL < Y_GUIA_FIN,
    Y_GUIA_FIN < yg(NV) - 4 - TAM_COORD,
    # las guías no se cruzan entre sí: el orden de las columnas es el del camino
    !is.unsorted(xal(pasos$k)), !is.unsorted(pasos$xm)
  )

  message(sprintf("  v = %s   w = %s", V, W))
  message(sprintf("  camino: %s",
                  paste(sprintf("(%d,%d)", CAMINO$i, CAMINO$j), collapse = " -> ")))
  message(sprintf("  alineamiento derivado:\n    v: %s\n    w: %s",
                  paste(AL$v, collapse = " "), paste(AL$w, collapse = " ")))
  message(sprintf("  %d pasos: %d coincidencias, %d discrepancias, %d huecos en v, %d huecos en w",
                  N_PASOS, sum(AL$tipo == "coincidencia"),
                  sum(AL$tipo == "discrepancia"),
                  sum(AL$tipo == "hueco_v"), sum(AL$tipo == "hueco_w")))
  message(sprintf("  aristas del grafo completo: %d", nrow(todas_aristas)))

  guardar(construir(), "grafo-alineamiento", 16, 14)
}
