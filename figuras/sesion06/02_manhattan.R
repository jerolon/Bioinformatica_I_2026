## Fig. @fig-manhattan (Sesión 6, "Un rodeo por Manhattan")
## El turista voraz pierde.
##
## Cuadrícula de 4x4 nodos (3x3 cuadras). Los pesos NO están puestos a ojo: se
## diseñaron para que la estrategia voraz pierda y eso se COMPRUEBA acá abajo,
## con las dos cuentas hechas en el script:
##
##   1. la ruta voraz, tomando en cada nodo la arista de mayor peso;
##   2. la ruta óptima por fuerza bruta sobre los C(6,3) = 20 caminos;
##   3. un stopifnot que exige que la óptima gane por al menos 30 %.
##
## Con los pesos de abajo: voraz = 23, óptima = 36, margen = 56.5 %, y el
## óptimo es único (el segundo mejor camino da 26). Si alguien cambia un peso
## y la moraleja deja de cumplirse, el script truena en vez de publicar una
## figura que afirme algo falso.
##
## La historia que cuenta: en el primer nodo la voraz ve una cuadra de 6 al
## este contra una de 3 al sur, se lleva la de 6, y cae en una columna pobre.
## La óptima empieza con 3 y termina con 36.
##
## Nada de esto está calcado de Compeau y Pevzner: los pesos son propios (ver
## el aviso de licencia en _tema.R).
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion06/02_manhattan.R

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


# --- La cuadrícula ----------------------------------------------------------
N <- 3L   # cuadras por lado; nodos = N + 1

# ABAJO[i+1, j+1] = peso de la arista (i,j) -> (i+1,j),  i = 0..N-1, j = 0..N
# DERE [i+1, j+1] = peso de la arista (i,j) -> (i,j+1),  i = 0..N,   j = 0..N-1
ABAJO <- rbind(c(3, 2, 4, 1),
               c(7, 2, 2, 2),
               c(8, 2, 3, 3))
DERE  <- rbind(c(6, 1, 2),
               c(2, 1, 3),
               c(3, 1, 4),
               c(7, 6, 5))

peso_arista <- function(i, j, dir) {
  if (dir == "S") ABAJO[i + 1L, j + 1L] else DERE[i + 1L, j + 1L]
}

#' Nodos por los que pasa una sucesión de movimientos, como data.frame(i, j).
recorrer <- function(mov) {
  i <- 0L; j <- 0L
  out <- data.frame(i = i, j = j)
  for (m in mov) {
    if (m == "S") i <- i + 1L else j <- j + 1L
    out <- rbind(out, data.frame(i = i, j = j))
  }
  out
}

peso_total <- function(mov) {
  i <- 0L; j <- 0L; s <- 0
  for (m in mov) {
    s <- s + peso_arista(i, j, m)
    if (m == "S") i <- i + 1L else j <- j + 1L
  }
  s
}

#' 1. La estrategia voraz: en cada nodo, la arista de mayor peso.
#' En los bordes no hay elección. Los empates se resuelven al sur, pero con
#' estos pesos no hay ninguno (lo comprueba un stopifnot).
ruta_voraz <- function() {
  i <- 0L; j <- 0L; mov <- character(0)
  while (i < N || j < N) {
    m <- if (i == N) "E"
         else if (j == N) "S"
         else if (peso_arista(i, j, "E") > peso_arista(i, j, "S")) "E" else "S"
    mov <- c(mov, m)
    if (m == "S") i <- i + 1L else j <- j + 1L
  }
  mov
}

#' 2. La ruta óptima por fuerza bruta. En 4x4 son C(6,3) = 20 caminos: cabe.
CAMINOS <- lapply(combn(2 * N, N, simplify = FALSE), function(k) {
  m <- rep("E", 2 * N); m[k] <- "S"; m
})

VORAZ  <- ruta_voraz()
PESOS  <- vapply(CAMINOS, peso_total, numeric(1))
OPTIMA <- CAMINOS[[which.max(PESOS)]]

TOT_VORAZ  <- peso_total(VORAZ)
TOT_OPTIMA <- max(PESOS)
MARGEN     <- 100 * (TOT_OPTIMA - TOT_VORAZ) / TOT_VORAZ

NODOS_VORAZ  <- recorrer(VORAZ)
NODOS_OPTIMA <- recorrer(OPTIMA)

# El primer nodo donde las dos rutas toman decisiones distintas.
K_DIVERGE <- which(VORAZ != OPTIMA)[1]
NODO_DIVERGE <- NODOS_VORAZ[K_DIVERGE, ]


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 14, h = 12) con 2 mm de margen lateral y el caption abajo:
# panel util de 136 x 117 mm (medido sobre el render, no supuesto).
ANCHO_PANEL <- 136
ALTO_PANEL  <- 117

X0 <- 22; PASO_X <- 24     # columnas j = 0..3 -> x = 22, 46, 70, 94
Y0 <- 102; PASO_Y <- 27    # filas    i = 0..3 -> y = 102, 75, 48, 21

xn <- function(j) X0 + PASO_X * j
yn <- function(i) Y0 - PASO_Y * i

R_NODO   <- 1.3            # radio visual del círculo del nodo, para recortar
SEP_PESO <- 3.8            # cuánto se aparta la etiqueta de peso de su arista
DESFASE  <- 1.0            # separación de las dos rutas donde comparten arista

TAM_PESO  <- 2.4
TAM_COORD <- 2.4
TAM_TOTAL <- 3.0
TAM_NOTA  <- 2.5

SANS <- familia_base()


# --- Todas las aristas, con su peso ----------------------------------------
aristas <- do.call(rbind, c(
  lapply(0:(N - 1), function(i) do.call(rbind, lapply(0:N, function(j) {
    data.frame(dir = "S", i = i, j = j, hi = i + 1L, hj = j,
               peso = peso_arista(i, j, "S"))
  }))),
  lapply(0:N, function(i) do.call(rbind, lapply(0:(N - 1), function(j) {
    data.frame(dir = "E", i = i, j = j, hi = i, hj = j + 1L,
               peso = peso_arista(i, j, "E"))
  })))
))

seg_aristas <- do.call(rbind, Map(function(x0, y0, x1, y1)
  recortar(x0, y0, x1, y1, ini = R_NODO + 1.2, fin = R_NODO + 2.2),
  xn(aristas$j), yn(aristas$i), xn(aristas$hj), yn(aristas$hi)))
aristas <- cbind(aristas, seg_aristas)

# La etiqueta del peso se aparta perpendicular a su arista: las de las verticales
# a la IZQUIERDA, las de las horizontales arriba. Así ninguna queda debajo de
# una de las dos rutas, que van gruesas justo encima de la arista, y la última
# columna de pesos no se le encima a los totales, que van a la derecha.
aristas$xp <- (xn(aristas$j) + xn(aristas$hj)) / 2 -
              ifelse(aristas$dir == "S", SEP_PESO, 0)
aristas$yp <- (yn(aristas$i) + yn(aristas$hi)) / 2 +
              ifelse(aristas$dir == "S", 0, SEP_PESO)

nodos <- expand.grid(i = 0:N, j = 0:N)
nodos$x <- xn(nodos$j); nodos$y <- yn(nodos$i)


# --- Las dos rutas ----------------------------------------------------------
clave <- function(nd) paste0(nd$i[-nrow(nd)], ",", nd$j[-nrow(nd)], "->",
                             nd$i[-1], ",", nd$j[-1])
COMPARTIDAS <- intersect(clave(NODOS_VORAZ), clave(NODOS_OPTIMA))

#' Convierte una ruta en una polilínea en mm, desplazando los vértices de las
#' aristas COMPARTIDAS para que las dos rutas se distingan donde coinciden.
#' Se mueve el vértice y no el segmento: así la polilínea no queda con saltos.
polilinea <- function(nd, d) {
  p <- data.frame(x = xn(nd$j), y = yn(nd$i))
  cl <- clave(nd)
  off <- matrix(0, nrow(p), 2); n_off <- numeric(nrow(p))
  for (k in seq_along(cl)) {
    if (!(cl[k] %in% COMPARTIDAS)) next
    dx <- p$x[k + 1] - p$x[k]; dy <- p$y[k + 1] - p$y[k]
    L <- sqrt(dx^2 + dy^2)
    nv <- c(-dy / L, dx / L)                       # normal unitaria
    for (v in c(k, k + 1)) {
      off[v, ] <- off[v, ] + nv; n_off[v] <- n_off[v] + 1
    }
  }
  ok <- n_off > 0
  p$x[ok] <- p$x[ok] + d * off[ok, 1] / n_off[ok]
  p$y[ok] <- p$y[ok] + d * off[ok, 2] / n_off[ok]
  p
}

POLI_VORAZ  <- polilinea(NODOS_VORAZ,   DESFASE)
POLI_OPTIMA <- polilinea(NODOS_OPTIMA, -DESFASE)


# --- Anotaciones ------------------------------------------------------------
CIRC <- circulo(xn(NODO_DIVERGE$j), yn(NODO_DIVERGE$i), r = 5.5)

NOTA_DIVERGE <- paste("acá la voraz toma la cuadra",
                      "más gorda y se equivoca", sep = "\n")
X_NOTA <- 2; Y_NOTA <- 116

CURVA <- llamada(34, 109.5, xn(NODO_DIVERGE$j) + 4.5, yn(NODO_DIVERGE$i) + 4.5,
                 comba = 0.30)

# Fuente y sumidero, en dos renglones para que quepan sin invadir la cuadrícula.
etiquetas_nodo <- data.frame(
  x   = c(xn(0) - 8, xn(N)),
  y   = c(yn(0), yn(N) - 6),
  txt = c("fuente\n(0,0)", sprintf("sumidero\n(%d,%d)", N, N)),
  h   = c(1, 0.5)
)

totales <- data.frame(
  x = xn(N) + 6, y = c(yn(N) + 13, yn(N) + 5),
  txt = c(sprintf("ruta voraz  %d", TOT_VORAZ),
          sprintf("ruta óptima  %d", TOT_OPTIMA)),
  col = c(NARANJA, AZUL)
)

# Rosa de orientación: dos flechitas y una etiqueta. Arriba a la derecha.
ORI_X <- 102; ORI_Y <- 106
orientacion <- data.frame(
  x    = c(ORI_X, ORI_X),
  y    = c(ORI_Y, ORI_Y),
  xend = c(ORI_X + 9, ORI_X),
  yend = c(ORI_Y, ORI_Y - 6)
)
TXT_ORI <- "solo sur y este"


construir <- function() {
  ggplot() +
    # --- El grafo completo, tenue ---
    geom_segment(data = aristas, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = GRIS_TENUE, linewidth = 0.35,
                 arrow = arrow(length = unit(1.5, "mm"), type = "open")) +
    geom_text(data = aristas, aes(x = xp, y = yp, label = peso),
              family = SANS, size = TAM_PESO, colour = alpha(GRIS, 0.75)) +

    # --- Las dos rutas ---
    geom_path(data = POLI_VORAZ, aes(x = x, y = y),
              colour = NARANJA, linewidth = 1.5, lineend = "round",
              linejoin = "round") +
    geom_path(data = POLI_OPTIMA, aes(x = x, y = y),
              colour = AZUL, linewidth = 1.5, lineend = "round",
              linejoin = "round") +

    # --- Los nodos, encima de las rutas ---
    geom_point(data = nodos, aes(x = x, y = y), shape = 21,
               fill = "white", colour = GRIS, size = 2.1, stroke = 0.45) +

    # --- La primera decisión donde divergen ---
    geom_path(data = CIRC, aes(x = x, y = y), colour = NARANJA,
              linewidth = 0.5, linetype = "22") +
    geom_path(data = CURVA, aes(x = x, y = y), colour = NARANJA,
              linewidth = 0.4) +
    geom_text(data = data.frame(1), aes(x = X_NOTA, y = Y_NOTA),
              label = NOTA_DIVERGE, family = SANS, size = TAM_NOTA,
              colour = NARANJA, hjust = 0, vjust = 1, lineheight = 1.15) +

    # --- Fuente, sumidero y totales ---
    geom_text(data = etiquetas_nodo, aes(x = x, y = y, label = txt, hjust = h),
              family = SANS, size = TAM_COORD, colour = GRIS, lineheight = 1.1) +
    geom_text(data = totales, aes(x = x, y = y, label = txt, colour = col),
              family = SANS, size = TAM_TOTAL, hjust = 0, fontface = "bold") +

    # --- Rosa de orientación ---
    geom_segment(data = orientacion,
                 aes(x = x, y = y, xend = xend, yend = yend),
                 colour = GRIS, linewidth = 0.5, arrow.fill = GRIS,
                 arrow = arrow(length = unit(1.8, "mm"), type = "closed")) +
    geom_text(data = data.frame(1), aes(x = ORI_X - 1, y = ORI_Y + 5),
              label = TXT_ORI, family = SANS, size = TAM_NOTA,
              colour = GRIS, hjust = 0) +

    scale_colour_identity() +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = sprintf(paste("Pesos propios. Óptimo por fuerza bruta sobre",
                                 "los %d caminos: %d contra %d, un %.0f %% más."),
                           length(CAMINOS), TOT_OPTIMA, TOT_VORAZ, MARGEN)) +
    tema_esquema()
}


escribir_datos <- function() {
  en <- function(cl, nd) ifelse(cl %in% clave(nd), "sí", "no")
  cl <- paste0(aristas$i, ",", aristas$j, "->", aristas$hi, ",", aristas$hj)
  tab <- data.frame(
    tipo        = "arista",
    direccion   = ifelse(aristas$dir == "S", "sur", "este"),
    desde       = paste0(aristas$i, ",", aristas$j),
    hasta       = paste0(aristas$hi, ",", aristas$hj),
    movimientos = "",
    peso        = aristas$peso,
    en_voraz    = en(cl, NODOS_VORAZ),
    en_optima   = en(cl, NODOS_OPTIMA)
  )
  resumen <- data.frame(
    tipo        = "ruta",
    direccion   = c("voraz", "óptima"),
    desde       = "0,0",
    hasta       = sprintf("%d,%d", N, N),
    movimientos = c(paste(VORAZ, collapse = ""), paste(OPTIMA, collapse = "")),
    peso        = c(TOT_VORAZ, TOT_OPTIMA),
    en_voraz    = c("sí", "no"),
    en_optima   = c("no", "sí")
  )
  escribir_tsv(rbind(tab, resumen), "manhattan")
}


if (!interactive()) {
  # Empates en la decisión voraz: con estos pesos no debe haber ninguno, para
  # que la ruta voraz sea la única que la definición produce.
  empates <- sum(vapply(0:(N - 1), function(i) sum(vapply(0:(N - 1), function(j)
    peso_arista(i, j, "E") == peso_arista(i, j, "S"), logical(1))), numeric(1)))

  stopifnot(
    # --- Las cuentas ---
    length(CAMINOS) == choose(2 * N, N),
    length(VORAZ) == 2 * N, length(OPTIMA) == 2 * N,
    sum(VORAZ == "S") == N, sum(OPTIMA == "S") == N,
    TOT_VORAZ == peso_total(VORAZ),
    TOT_OPTIMA == max(PESOS),
    # La voraz es un camino legal, o sea que está entre los 20.
    any(vapply(CAMINOS, function(c) identical(c, VORAZ), logical(1))),

    # --- EL REQUISITO: la voraz pierde, y por un margen visible ---
    TOT_OPTIMA > TOT_VORAZ,
    MARGEN >= 30,
    sum(PESOS == TOT_OPTIMA) == 1L,        # el óptimo es único
    empates == 0,                          # la ruta voraz no depende del desempate
    # Y pierde por la razón que dice la etiqueta: gana la primera arista.
    K_DIVERGE == 1L,
    peso_arista(0, 0, "E") > peso_arista(0, 0, "S"),
    VORAZ[1] == "E", OPTIMA[1] == "S",

    # --- Nada se sale del panel ---
    xn(N) + 6 + media_ancho(totales$txt, TAM_TOTAL) * 2 <= ANCHO_PANEL,
    X_NOTA + media_ancho(NOTA_DIVERGE, TAM_NOTA) * 2 < xn(1),
    Y_NOTA <= ALTO_PANEL,
    ORI_X - 1 + media_ancho(TXT_ORI, TAM_NOTA) * 2 <= ANCHO_PANEL,
    ORI_Y + 5 + TAM_NOTA <= ALTO_PANEL,
    yn(N) - 6 - 2 * TAM_COORD >= 0,
    xn(0) - 8 - media_ancho("fuente", TAM_COORD) * 2 >= 0,
    max(aristas$xp) < min(totales$x),          # los pesos no invaden los totales
    min(aristas$xp) > xn(0) - 8,               # ni la etiqueta de la fuente
    max(aristas$yp) < Y_NOTA - 2 * TAM_NOTA * 1.15,
    max(totales$y) + TAM_TOTAL < yn(N - 1)     # ni los totales la fila de arriba
  )

  message(sprintf("  ruta voraz : %s  total %d", paste(VORAZ, collapse = ""), TOT_VORAZ))
  message(sprintf("  ruta óptima: %s  total %d", paste(OPTIMA, collapse = ""), TOT_OPTIMA))
  message(sprintf("  la óptima gana por %.1f %% (segundo mejor camino: %d)",
                  MARGEN, max(PESOS[PESOS < TOT_OPTIMA])))
  message(sprintf("  aristas compartidas por las dos rutas: %d", length(COMPARTIDAS)))

  escribir_datos()
  guardar(construir(), "manhattan", 14, 12)
}
