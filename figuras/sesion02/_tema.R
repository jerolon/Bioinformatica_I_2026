## Configuración compartida de las CINCO figuras de la Sesión 2-3
## (jerarquía gen→proteína, coordenadas, composición del genoma, biotypes,
## mapa de formatos).
##
## ---------------------------------------------------------------------------
## POR QUÉ ESTE ARCHIVO ES UN ADAPTADOR Y NO UN MÓDULO DE ESTILO
##
## La especificación pedía `source("figuras/_tema.R")` con una paleta propia
## (AZUL, NARANJA, GRIS, VERDE). En este repo la paleta vive en UN solo lugar,
## `figuras/estilo.R`, gemelo de `estilo.py`: "nadie teclea un hex suelto"
## (figuras/sesion01/FIGURAS.md, § Paleta). Si estas cinco figuras declararan
## sus propios hex quedarían al lado de las de la Sesión 01, dibujadas con la
## paleta del libro, y no combinarían.
##
## Así que este archivo conserva los NOMBRES de la especificación y los cablea
## a la paleta real. Misma decisión —y mismo mapeo— que figuras/sesion01/_tema.R.
##
## Mapeo:  AZUL -> TEAL (#1a7a8a) · AZUL_CLARO -> TEAL_CLARO (#2bb5c6)
##         NARANJA -> AMBAR (#d98c00) · GRIS -> GRIS · VERDE -> VERDE
##
## Lo demás de la especificación se respeta al pie: svglite (nunca el device
## svg() de base R, que vectoriza el texto), sin título dentro del SVG, fondo
## transparente, etiquetas en español, y cada figura con datos escribe su .tsv.
## ---------------------------------------------------------------------------
##
## Uso, desde cualquier working directory:
##     source(".../figuras/sesion02/_tema.R")   # los scripts lo hacen solos

# --- Localizar estilo.R ----------------------------------------------------
# Mismo idiom que el resto de las figuras: se busca el `ofile` que source() deja
# en los frames, de ADENTRO hacia afuera, para que el path sea el de ESTE
# archivo y no el del script que lo sourcea.
.ubicar_tema <- function() {
  for (i in rev(seq_len(sys.nframe()))) {
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar _tema.R: correr con Rscript o con source()")
}

.DIR_SESION02 <- dirname(.ubicar_tema())
source(file.path(dirname(.DIR_SESION02), "estilo.R"))

# estilo.R ya cargó ggplot2, svglite y scales, y definió TEAL, TEAL_CLARO,
# AMBAR, VERDE, GRIS, TEXTO, tema_lgc(), guardar(), familia_base(),
# familia_mono() y DIR_FIGURAS.

# --- Alias de paleta con los nombres de la especificación -------------------
AZUL       <- TEAL         # trazo primario
AZUL_CLARO <- TEAL_CLARO   # secundario: lo que no es repetitivo ni codificante
NARANJA    <- AMBAR        # contraste / "el punto de la figura"
# GRIS y VERDE ya vienen de estilo.R con esos mismos nombres.

# --- Tema -------------------------------------------------------------------
#' Tema de estas figuras: el del libro con la base a 10 pt.
tema_libro <- function(base_size = 10) tema_lgc(base_size = base_size)

#' Tema de las figuras de ESQUEMA (1, 2 y 5, y la 3 que se dibuja a mano).
#'
#' theme_void() con la nota de fuente al pie, en gris chico y pegada al borde
#' izquierdo de la FIGURA (no del panel), igual que tema_lgc(). El margen va acá
#' y no en la escala para que la nota arranque donde arranca el dibujo.
tema_esquema <- function(base_size = 10, margen = margin(0, 2, 0, 2, "mm")) {
  theme_void(base_size = base_size, base_family = familia_base()) +
    theme(plot.caption = element_text(size = rel(0.73), colour = GRIS,
                                      face = "italic", hjust = 0,
                                      margin = margin(t = 3)),
          plot.caption.position = "plot",
          plot.margin = margen)
}

# --- Salida -----------------------------------------------------------------
# estilo.R define guardar(p, nombre, subdir, ancho, alto) en PULGADAS. La
# especificación de estas figuras habla en centímetros. Se guarda la original y
# se expone una con la firma que pide la especificación.
.guardar_pulgadas <- guardar

CM_POR_PULGADA <- 2.54

#' Guarda el SVG en figuras/sesion02/<nombre>.svg. Ancho y alto en CENTÍMETROS.
guardar <- function(p, nombre, w = 16, h = 10) {
  .guardar_pulgadas(p, nombre, subdir = "sesion02",
                    ancho = w / CM_POR_PULGADA, alto = h / CM_POR_PULGADA)
}

#' Escribe el .tsv con los números que graficó la figura. Es el chequeo de que
#' la figura y el texto del capítulo dicen lo mismo.
escribir_tsv <- function(df, nombre) {
  ruta <- file.path(.DIR_SESION02, paste0(nombre, ".tsv"))
  write.table(df, ruta, sep = "\t", row.names = FALSE, quote = FALSE,
              fileEncoding = "UTF-8")
  message(sprintf("  escrito figuras/sesion02/%s.tsv", nombre))
  invisible(ruta)
}

# --- Helpers de dibujo compartidos ------------------------------------------

# Avance medio de un carácter, en fracción del em. Es una cota para los
# chequeos de encimado y para repartir el espacio, no una medida de la fuente
# real (que depende de qué esté instalado en cada máquina).
AVANCE_SANS <- 0.55
AVANCE_MONO <- 0.60

#' Medio ancho de un texto, en mm, para los stopifnot de encimado.
#' nchar() se mide sobre la línea más larga: las etiquetas van partidas con "\n".
media_ancho <- function(txt, tam, avance = AVANCE_SANS) {
  largo <- vapply(strsplit(txt, "\n", fixed = TRUE),
                  function(p) max(nchar(p)), numeric(1))
  largo * tam * avance / 2
}

#' Polilínea con forma de llave (brace) para geom_path.
#'
#' Se dibuja como cuatro cuartos de circunferencia: las dos puntas (convexas) y
#' las dos del pico central (cóncavas). Los tramos rectos entre arcos los pone
#' geom_path solo, al unir puntos consecutivos.
#'
#' @param x0,x1  extremos horizontales (x0 < x1)
#' @param y      línea base, donde nacen las puntas
#' @param prof   profundidad total de la llave
#' @param arriba TRUE si el pico apunta hacia arriba
llave <- function(x0, x1, y, prof, arriba = TRUE, n = 20) {
  s  <- if (arriba) 1 else -1
  xm <- (x0 + x1) / 2
  r  <- min(prof / 2, (x1 - x0) / 4)
  a  <- seq(0, pi / 2, length.out = n)
  rbind(
    data.frame(x = x0 + r * sin(a),           y = y + s * r * (1 - cos(a))),
    data.frame(x = xm - r * cos(a),           y = y + s * (r + r * sin(a))),
    data.frame(x = xm + r * cos(rev(a)),      y = y + s * (r + r * sin(rev(a)))),
    data.frame(x = x1 - r * sin(rev(a)),      y = y + s * r * (1 - cos(rev(a))))
  )
}

#' Círculo como polígono, con el radio en las MISMAS unidades que los ejes.
#' geom_point mide su `size` en puntos y no se puede comparar contra la
#' geometría en mm de estos esquemas; esto sí.
circulo <- function(x, y, r, id = 1, n = 48) {
  ang <- seq(0, 2 * pi, length.out = n + 1)[-(n + 1)]
  data.frame(x = x + r * cos(ang), y = y + r * sin(ang), id = id)
}

#' Número con separador de miles, con el mismo separador que usa el capítulo
#' (coma: "35,901"). Es una decisión del texto, no de la localización de R.
miles <- function(n) formatC(n, format = "d", big.mark = ",")
