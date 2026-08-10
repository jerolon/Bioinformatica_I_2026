## Fig. @fig-matriz-ejemplo (Sesión 14, § La matriz de programación dinámica)
## La matriz de puntajes de Needleman-Wunsch con el traceback encima.
##
## ---------------------------------------------------------------------------
## ESTA FIGURA ES LA ÚNICA DE LA UNIDAD CON DATOS, Y ES DELIBERADAMENTE
## LA SALIDA DEL CÓDIGO DEL CAPÍTULO, NO DE UNA VERSIÓN MEJORADA.
##
## nw() se copia TEXTUALMENTE de contenido/06-introduccion-r/01-fundamentos.qmd
## y camino() de 03-rangos-y-graficas.qmd. El bloque de ggplot2 también va tal
## cual. La razón: el alumno va a correr ese mismo código y tiene que obtener
## esta misma figura. Si sale fea, se arregla el capítulo, no el script.
##
## Única desviación, y es de formato, no de contenido: al final se aplica
## tema_libro() en lugar de theme_minimal() para que la tipografía y los grises
## sean los del libro. La geometría, las escalas y los datos son los del
## capítulo, sin tocar.
##
## VERIFICADO (ver FIGURAS.md, "Al terminar"):
##   - score en la esquina = 2
##   - traceback de 6 pasos, de (7,7) a (1,1), continuo, sin saltos > 1 celda
##   - nw() coincide con pwalign::pairwiseAlignment(gapOpening=0,
##     gapExtension=2, type="global"): 0 discrepancias en 200 pares al azar
## ---------------------------------------------------------------------------
##
## Regenerar:  Rscript figuras/unidad6/03_matriz_nw.R

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

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(stringr)
})

# --- Matriz de sustitución del capítulo (match 1, mismatch -1) --------------
bases  <- c("A", "C", "G", "T")
submat <- matrix(-1, nrow = 4, ncol = 4)
diag(submat) <- 1
dimnames(submat) <- list(bases, bases)

# --- nw(), TEXTUAL de la sesión 12 -----------------------------------------
nw <- function(s1, s2, submat, gap = -2) {
  a <- strsplit(s1, "")[[1]]
  b <- strsplit(s2, "")[[1]]
  n <- length(a) + 1
  m <- length(b) + 1

  S <- matrix(0, nrow = n, ncol = m)
  T <- matrix("", nrow = n, ncol = m)

  S[, 1] <- (0:(n-1)) * gap
  S[1, ] <- (0:(m-1)) * gap
  T[-1, 1] <- "arriba"
  T[1, -1] <- "izquierda"

  for (i in 2:n) {
    for (j in 2:m) {
      opciones <- c(
        diagonal  = S[i-1, j-1] + submat[a[i-1], b[j-1]],
        arriba    = S[i-1, j  ] + gap,
        izquierda = S[i,   j-1] + gap
      )
      S[i, j] <- max(opciones)
      T[i, j] <- names(which.max(opciones))
    }
  }

  list(score = S[n, m], S = S, T = T, a = a, b = b)
}

# --- camino(), TEXTUAL de la sesión 14 -------------------------------------
camino <- function(res) {
  i <- length(res$a) + 1; j <- length(res$b) + 1
  puntos <- list(c(i, j))
  while (i > 1 || j > 1) {
    paso <- res$T[i, j]
    if (paso == "diagonal")      { i <- i-1; j <- j-1 }
    else if (paso == "arriba")   { i <- i-1 }
    else                         { j <- j-1 }
    puntos[[length(puntos)+1]] <- c(i, j)
  }
  do.call(rbind, puntos) %>%
    as.data.frame() %>%
    setNames(c("i", "j"))
}

# --- Correr y verificar ----------------------------------------------------
res  <- nw("ATGCTA", "ATCGTA", submat, gap = -2)
ruta <- camino(res)

message(sprintf("  score en la esquina: %s", res$score))
.d <- abs(diff(as.matrix(ruta)))
if (any(.d[, 1] > 1 | .d[, 2] > 1)) {
  stop("el traceback tiene saltos de más de una celda: revisar camino()")
}
message(sprintf("  traceback continuo: %d pasos, de (%d,%d) a (%d,%d)",
                nrow(ruta) - 1, ruta$i[1], ruta$j[1],
                ruta$i[nrow(ruta)], ruta$j[nrow(ruta)]))

# --- Matriz a formato largo, TEXTUAL del capítulo ---------------------------
matriz_larga <- as.data.frame(res$S) %>%
  mutate(i = row_number()) %>%
  pivot_longer(cols = -i, names_to = "j", values_to = "score") %>%
  mutate(j = as.integer(str_remove(j, "V")))

# --- La gráfica, TEXTUAL del capítulo --------------------------------------
p <- ggplot(matriz_larga, aes(x = j, y = i)) +
  geom_tile(aes(fill = score), color = "white") +
  geom_text(aes(label = score), size = 3) +
  geom_path(data = ruta, color = "orangered", linewidth = 1.2) +
  geom_point(data = ruta, color = "orangered", size = 2) +
  scale_fill_viridis_c() +
  scale_y_reverse(breaks = 1:(length(res$a)+1),
                  labels = c("", res$a)) +
  scale_x_continuous(breaks = 1:(length(res$b)+1),
                     labels = c("", res$b), position = "top") +
  coord_fixed() +
  labs(x = NULL, y = NULL, fill = "puntaje") +
  tema_libro()

guardar(p, "matriz-nw-ejemplo", w = 16, h = 12)
