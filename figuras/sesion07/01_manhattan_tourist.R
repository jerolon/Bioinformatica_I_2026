## Fig. @fig-manhattan-dp (Sesión 7, "Cómo encontrar la longitud del camino
## más largo en Manhattan con programación dinámica")
##
## Cuatro paneles: la cuadrícula con pesos (A), las matrices Derecha (B) y
## Abajo (C), y la matriz s[i,j] resuelta con un camino óptimo encima (D).
##
## Lo que la figura afirma lo CALCULA el script:
##   - s[i,j] sale de la recurrencia (manhattan_tourist);
##   - la misma s[i,j] se recalcula por FUERZA BRUTA sobre los C(n+m,n) = 35
##     caminos, celda por celda, y un stopifnot exige que las dos coincidan;
##   - el camino que se dibuja se reconstruye hacia atrás desde (n,m) y su peso
##     tiene que dar exactamente s[n,m].
## Si alguien cambia un peso, el script truena antes que publicar una figura que
## afirme algo falso. Es la misma regla que 02_manhattan.R de la sesión 6.
##
## Los pesos son propios (ver el aviso de licencia en _tema.R).
##
## Los títulos A/B/C/D sí van dentro del SVG (son etiquetas de panel); el
## caption de la figura vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion07/01_manhattan_tourist.R

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

COL_DER <- AZUL      # todo lo que sea "caminar a la derecha"
COL_ABA <- NARANJA   # todo lo que sea "caminar hacia abajo"


# --- 1. El algoritmo --------------------------------------------------------
# Convención de índices, la misma en todo el script:
#   nodo (i,j) con i = 0..n (renglón) y j = 0..m (columna);
#   Derecha[i,j] pesa la arista (i,j) -> (i,j+1),  j = 0..m-1  ->  (n+1) x m
#   Abajo   [i,j] pesa la arista (i,j) -> (i+1,j), i = 0..n-1  ->  n x (m+1)
# En R los arreglos empiezan en 1, así que a todo índice se le suma uno.
manhattan_tourist <- function(n, m, Down, Right) {
  stopifnot(is.matrix(Down), is.matrix(Right),
            all(dim(Down)  == c(n,     m + 1)),
            all(dim(Right) == c(n + 1, m)))
  s <- matrix(0, nrow = n + 1, ncol = m + 1,
              dimnames = list(paste0("i=", 0:n), paste0("j=", 0:m)))
  # Los bordes no tienen elección: para llegar a ellos sólo hay un camino.
  s[, 1] <- cumsum(c(0, Down[, 1]))
  s[1, ] <- cumsum(c(0, Right[1, ]))
  if (n > 0 && m > 0) {
    for (i in 2:(n + 1)) for (j in 2:(m + 1)) {
      s[i, j] <- max(s[i - 1, j] + Down[i - 1, j],
                     s[i, j - 1] + Right[i, j - 1])
    }
  }
  s
}

#' Reconstruye un camino óptimo caminando hacia atrás desde (n,m).
#' Con empates se queda con el paso a la derecha; da igual cuál, todos pesan lo
#' mismo, y el stopifnot comprueba que el peso del camino sea s[n,m].
camino_optimo <- function(S, Down, Right) {
  i <- nrow(S); j <- ncol(S)
  ruta <- data.frame(i = i - 1, j = j - 1)
  while (i > 1 || j > 1) {
    if (j > 1 && S[i, j] == S[i, j - 1] + Right[i, j - 1]) j <- j - 1 else i <- i - 1
    ruta <- rbind(data.frame(i = i - 1, j = j - 1), ruta)
  }
  ruta
}

#' Peso de un camino dado como sucesión de movimientos ("D" derecha, "A" abajo).
peso_total <- function(mov, Down, Right) {
  i <- 0L; j <- 0L; s <- 0
  for (mv in mov) {
    if (mv == "D") { s <- s + Right[i + 1L, j + 1L]; j <- j + 1L }
    else           { s <- s + Down [i + 1L, j + 1L]; i <- i + 1L }
  }
  s
}

#' Todos los caminos de (0,0) a (a,b): C(a+b, a) sucesiones de movimientos.
todos_los_caminos <- function(a, b) {
  if (a + b == 0) return(list(character(0)))
  lapply(combn(a + b, a, simplify = FALSE), function(k) {
    mv <- rep("D", a + b); mv[k] <- "A"; mv
  })
}

#' La misma tabla, pero por fuerza bruta: para cada nodo, el máximo sobre TODOS
#' los caminos que llegan a él. Es la comprobación independiente de la
#' recurrencia; no se usa para dibujar.
tabla_fuerza_bruta <- function(n, m, Down, Right) {
  S <- matrix(NA_real_, n + 1, m + 1)
  for (a in 0:n) for (b in 0:m) {
    S[a + 1, b + 1] <- max(vapply(todos_los_caminos(a, b), peso_total,
                                  numeric(1), Down = Down, Right = Right))
  }
  S
}


# --- 2. Los datos del ejemplo -----------------------------------------------
# Pesos propios. No es la cuadrícula cuadrada de la sesión 6 a propósito: acá
# el punto es que las dos matrices tienen dimensiones DISTINTAS entre sí y
# distintas de s[i,j], que es justo donde se atoran al programarlo.
n <- 3; m <- 4

Right <- matrix(c(3, 0, 2, 4,
                  5, 3, 1, 2,
                  2, 6, 4, 0,
                  1, 2, 5, 3), nrow = n + 1, byrow = TRUE)

Down  <- matrix(c(2, 4, 1, 3, 0,
                  6, 1, 5, 2, 4,
                  3, 2, 0, 6, 1), nrow = n, byrow = TRUE)

S    <- manhattan_tourist(n, m, Down, Right)
ruta <- camino_optimo(S, Down, Right)

MOVS <- with(ruta, ifelse(diff(j) == 1, "D", "A"))
TOTAL <- S[n + 1, m + 1]


# --- 3. Geometría de la cuadrícula ------------------------------------------
# nodo (i,j) -> x = j, y = -i  (i crece hacia abajo, como en la matriz)
#
# Las aristas se acortan RE en los dos extremos: si llegan hasta el centro del
# nodo, la punta de flecha queda debajo del círculo blanco (que se dibuja
# encima) y la figura pierde justo lo que quiere decir, que el turista sólo
# camina en dos direcciones.
RE <- 0.17

nodos <- expand.grid(i = 0:n, j = 0:m)
nodos$s <- S[cbind(nodos$i + 1, nodos$j + 1)]

der <- expand.grid(i = 0:n, j = 0:(m - 1))
der$w <- Right[cbind(der$i + 1, der$j + 1)]
der <- transform(der, x = j + RE, xend = j + 1 - RE, y = -i, yend = -i)

aba <- expand.grid(i = 0:(n - 1), j = 0:m)
aba$w <- Down[cbind(aba$i + 1, aba$j + 1)]
aba <- transform(aba, x = j, xend = j, y = -i - RE, yend = -i - 1 + RE)

# El camino va como UNA polilínea, no como segmentos sueltos: partido en
# aristas se ve entrecortado en cada nodo, y lo que se quiere resaltar es que
# es un solo recorrido.
poli_ruta <- data.frame(x = ruta$j, y = -ruta$i)

g_col <- data.frame(j = 0:m, i = 0)
g_ren <- data.frame(i = 0:n, j = 0)

FLECHA <- arrow(length = unit(1.6, "mm"), type = "closed")


# --- 4. Paneles de cuadrícula -----------------------------------------------
panel_rejilla <- function(pesos = TRUE, valores = FALSE, resaltar = FALSE,
                          titulo = "") {
  p <- ggplot()

  if (resaltar)
    p <- p + geom_path(data = poli_ruta, aes(x = x, y = y),
                       colour = VERDE, linewidth = 2.6, alpha = 0.35,
                       lineend = "round", linejoin = "round")

  p <- p +
    geom_segment(data = der, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = COL_DER, linewidth = if (pesos) 0.7 else 0.45,
                 arrow = FLECHA) +
    geom_segment(data = aba, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = COL_ABA, linewidth = if (pesos) 0.7 else 0.45,
                 arrow = FLECHA)

  if (pesos)
    p <- p +
      geom_text(data = der, aes(x = (x + xend) / 2, y = y + 0.16, label = w),
                family = SANS, colour = COL_DER, size = 3, vjust = 0) +
      geom_text(data = aba, aes(x = x + 0.13, y = (y + yend) / 2, label = w),
                family = SANS, colour = COL_ABA, size = 3, hjust = 0)

  p <- p +
    geom_text(data = g_col, aes(x = j, y = 0.62, label = paste0("j=", j)),
              family = SANS, colour = GRIS, size = 2.5) +
    geom_text(data = g_ren, aes(x = -0.62, y = -i, label = paste0("i=", i)),
              family = SANS, colour = GRIS, size = 2.5) +
    geom_point(data = nodos, aes(x = j, y = -i), shape = 21, fill = "white",
               colour = GRIS, size = if (valores) 7.5 else 5, stroke = 0.6)

  if (valores)
    p <- p + geom_text(data = nodos, aes(x = j, y = -i, label = s),
                       family = SANS, size = 2.9, colour = TEXTO)

  p + coord_equal(clip = "off") +
    scale_x_continuous(expand = expansion(add = 0.55)) +
    scale_y_continuous(expand = expansion(add = 0.45)) +
    labs(title = envolver(titulo)) + tema_panel()
}


# --- 5. Paneles de matriz ---------------------------------------------------
panel_matriz <- function(M, ren, col, color, titulo, dims) {
  d <- expand.grid(r = seq_len(nrow(M)), c = seq_len(ncol(M)))
  d$v <- M[cbind(d$r, d$c)]
  d$i <- ren[d$r]; d$j <- col[d$c]

  ggplot(d, aes(x = j, y = -i)) +
    geom_tile(fill = tinte(color), colour = color, linewidth = 0.5,
              width = 0.92, height = 0.92) +
    geom_text(aes(label = v), family = SANS, colour = color, size = 3.4,
              fontface = "bold") +
    geom_text(data = data.frame(j = col), aes(x = j, y = 0.72,
                                              label = paste0("j=", j)),
              inherit.aes = FALSE, family = SANS, colour = GRIS, size = 2.5) +
    geom_text(data = data.frame(i = ren), aes(x = -0.75, y = -i,
                                              label = paste0("i=", i)),
              inherit.aes = FALSE, family = SANS, colour = GRIS, size = 2.5) +
    coord_equal(clip = "off") +
    scale_x_continuous(expand = expansion(add = 0.6)) +
    scale_y_continuous(expand = expansion(add = 0.5)) +
    labs(title = envolver(titulo), subtitle = dims) + tema_panel()
}


# --- 6. Ensamblado ----------------------------------------------------------
SANS <- familia_base()

construir <- function() {
  pA <- panel_rejilla(
    pesos = TRUE, valores = FALSE,
    titulo = paste("A. La cuadrícula. Cada arista lleva el número de",
                   "atracciones que se ven al recorrerla: azul hacia la",
                   "derecha, naranja hacia abajo."))

  pB <- panel_matriz(
    Right, ren = 0:n, col = 0:(m - 1), color = COL_DER,
    dims = sprintf("Dimensión: (n+1) × m = %d × %d", n + 1, m),
    titulo = paste("B. Derecha[i,j]: atracciones que se ven caminando a la",
                   "derecha, de s[i,j] a s[i,j+1]."))

  pC <- panel_matriz(
    Down, ren = 0:(n - 1), col = 0:m, color = COL_ABA,
    dims = sprintf("Dimensión: n × (m+1) = %d × %d", n, m + 1),
    titulo = paste("C. Abajo[i,j]: atracciones que se ven caminando hacia",
                   "abajo, de s[i,j] a s[i+1,j]."))

  pD <- panel_rejilla(
    pesos = FALSE, valores = TRUE, resaltar = TRUE,
    titulo = paste("D. s[i,j]: número máximo de atracciones al llegar a cada",
                   "nodo, o sea la longitud del camino más largo desde (0,0)."))

  (pA | pB) / (pC | pD)
}


escribir_datos <- function() {
  en_ruta <- paste0(ruta$i, ",", ruta$j)
  celdas <- rbind(
    data.frame(matriz = "Derecha", i = der$i, j = der$j, valor = der$w,
               nota = sprintf("(%d,%d)->(%d,%d)", der$i, der$j, der$i, der$j + 1)),
    data.frame(matriz = "Abajo", i = aba$i, j = aba$j, valor = aba$w,
               nota = sprintf("(%d,%d)->(%d,%d)", aba$i, aba$j, aba$i + 1, aba$j)),
    data.frame(matriz = "s", i = nodos$i, j = nodos$j, valor = nodos$s,
               nota = ifelse(paste0(nodos$i, ",", nodos$j) %in% en_ruta,
                             "en el camino dibujado", ""))
  )
  resumen <- data.frame(
    matriz = "camino", i = n, j = m, valor = TOTAL,
    nota = sprintf("movimientos %s (D derecha, A abajo)", paste(MOVS, collapse = ""))
  )
  escribir_tsv(rbind(celdas, resumen), "manhattan-tourist")
}


if (!interactive()) {
  # --- La comprobación: la recurrencia contra la fuerza bruta ---------------
  S_BRUTA <- tabla_fuerza_bruta(n, m, Down, Right)
  N_CAMINOS <- choose(n + m, n)

  stopifnot(
    # Dimensiones: es el error clásico y la figura lo anota, así que se revisa.
    all(dim(Right) == c(n + 1, m)),
    all(dim(Down)  == c(n, m + 1)),
    all(dim(S)     == c(n + 1, m + 1)),

    # La recurrencia da lo mismo que mirar TODOS los caminos, celda por celda.
    all(S == S_BRUTA),
    TOTAL == max(vapply(todos_los_caminos(n, m), peso_total, numeric(1),
                        Down = Down, Right = Right)),

    # El camino dibujado es legal y pesa exactamente s[n,m].
    nrow(ruta) == n + m + 1,
    all(ruta[1, ] == c(0, 0)), all(ruta[nrow(ruta), ] == c(n, m)),
    sum(MOVS == "A") == n, sum(MOVS == "D") == m,
    all(diff(ruta$i) >= 0), all(diff(ruta$j) >= 0),
    all(diff(ruta$i) + diff(ruta$j) == 1),
    peso_total(MOVS, Down, Right) == TOTAL,

    # Que el camino sirva de ejemplo: si fuera todo por el borde no enseñaría
    # nada, porque en el borde no hay decisión que tomar.
    any(ruta$i > 0 & ruta$j > 0 & ruta$i < n & ruta$j < m)
  )

  message(sprintf("  caminos posibles de (0,0) a (%d,%d): %d", n, m, N_CAMINOS))
  message(sprintf("  camino más largo: %s, %d atracciones",
                  paste(MOVS, collapse = ""), TOTAL))
  message("  s[i,j]:")
  print(S)

  escribir_datos()
  guardar(construir(), "manhattan-tourist", 23.4, 18.8)
}
