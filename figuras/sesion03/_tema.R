## Configuración compartida de las CINCO figuras de la Sesión 3, Código genético.
##
## Gemelo de figuras/sesion02/_tema.R: adaptador, no módulo de estilo. Conserva
## los nombres que pedía la especificación (AZUL, NARANJA, tema_libro, guardar
## en centímetros) y los cablea a figuras/estilo.R, que es el único lugar del
## repo donde vive un hex. Ver figuras/sesion01/FIGURAS.md, § Paleta.
##
## Mapeo:  AZUL -> TEAL (#1a7a8a) · AZUL_CLARO -> TEAL_CLARO (#2bb5c6)
##         NARANJA -> AMBAR (#d98c00) · MORADO, VERDE, GRIS -> iguales
##
## MORADO se agregó a estilo.R (y a estilo.py, su gemelo) para esta sesión: la
## escala por clase química necesita seis niveles y con cuatro colores el par
## ácido/básico —que es justo el contraste que importa— quedaba en el mismo tono.
## Ver la nota en estilo.R.
##
## Uso, desde cualquier working directory:
##     source(".../figuras/sesion03/_tema.R")   # los scripts lo hacen solos

.ubicar_tema <- function() {
  for (i in rev(seq_len(sys.nframe()))) {   # de adentro hacia afuera
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar _tema.R: correr con Rscript o con source()")
}

.DIR_SESION03 <- dirname(.ubicar_tema())
source(file.path(dirname(.DIR_SESION03), "estilo.R"))

# estilo.R ya cargó ggplot2, svglite y scales, y definió TEAL, TEAL_CLARO,
# AMBAR, VERDE, MORADO, GRIS, TEXTO, tema_lgc(), guardar(), familia_base(),
# familia_mono() y DIR_FIGURAS.

# --- Alias de paleta con los nombres de la especificación -------------------
AZUL       <- TEAL
AZUL_CLARO <- TEAL_CLARO
NARANJA    <- AMBAR
# MORADO, VERDE y GRIS ya vienen de estilo.R con esos mismos nombres.

# --- Temas ------------------------------------------------------------------
tema_libro <- function(base_size = 10) tema_lgc(base_size = base_size)

#' Tema de las figuras de esquema: theme_void() con la nota de fuente al pie,
#' pegada al borde izquierdo de la FIGURA (no del panel).
tema_esquema <- function(base_size = 10, margen = margin(0, 2, 0, 2, "mm")) {
  theme_void(base_size = base_size, base_family = familia_base()) +
    theme(plot.caption = element_text(size = rel(0.73), colour = GRIS,
                                      face = "italic", hjust = 0,
                                      margin = margin(t = 3)),
          plot.caption.position = "plot",
          plot.margin = margen)
}

# --- Salida -----------------------------------------------------------------
.guardar_pulgadas <- guardar
CM_POR_PULGADA <- 2.54

#' Guarda el SVG en figuras/sesion03/<nombre>.svg. Ancho y alto en CENTÍMETROS.
guardar <- function(p, nombre, w = 16, h = 10) {
  .guardar_pulgadas(p, nombre, subdir = "sesion03",
                    ancho = w / CM_POR_PULGADA, alto = h / CM_POR_PULGADA)
}

escribir_tsv <- function(df, nombre) {
  ruta <- file.path(.DIR_SESION03, paste0(nombre, ".tsv"))
  write.table(df, ruta, sep = "\t", row.names = FALSE, quote = FALSE,
              fileEncoding = "UTF-8")
  message(sprintf("  escrito figuras/sesion03/%s.tsv", nombre))
  invisible(ruta)
}

# --- Helpers de dibujo compartidos ------------------------------------------
AVANCE_SANS <- 0.55
AVANCE_MONO <- 0.60

#' Medio ancho de un texto, en mm, para los stopifnot de encimado.
media_ancho <- function(txt, tam, avance = AVANCE_SANS) {
  largo <- vapply(strsplit(txt, "\n", fixed = TRUE),
                  function(p) max(nchar(p)), numeric(1))
  largo * tam * avance / 2
}

#' Polilínea con forma de llave (brace) para geom_path. Gemela de la de
#' sesion02: cuatro cuartos de circunferencia; los tramos rectos los pone
#' geom_path solo al unir puntos consecutivos.
llave <- function(x0, x1, y, prof, arriba = TRUE, n = 20) {
  s  <- if (arriba) 1 else -1
  xm <- (x0 + x1) / 2
  r  <- min(prof / 2, (x1 - x0) / 4)
  a  <- seq(0, pi / 2, length.out = n)
  rbind(
    data.frame(x = x0 + r * sin(a),        y = y + s * r * (1 - cos(a))),
    data.frame(x = xm - r * cos(a),        y = y + s * (r + r * sin(a))),
    data.frame(x = xm + r * cos(rev(a)),   y = y + s * (r + r * sin(rev(a)))),
    data.frame(x = x1 - r * sin(rev(a)),   y = y + s * r * (1 - cos(rev(a))))
  )
}

#' Círculo como polígono, con el radio en las MISMAS unidades que los ejes.
#' geom_point mide su `size` en puntos y no se puede comparar contra la
#' geometría en mm de estos esquemas; esto sí, y por eso los stopifnot pueden
#' comprobar que dos nodos del grafo no se tocan.
circulo <- function(x, y, r, id = 1, n = 48) {
  ang <- seq(0, 2 * pi, length.out = n + 1)[-(n + 1)]
  data.frame(x = x + r * cos(ang), y = y + r * sin(ang), id = id)
}

#' Mezcla un color de la paleta con blanco y devuelve un color OPACO.
#'
#' No es lo mismo que alpha(): alpha() deja el canal de transparencia puesto, y
#' entonces col2rgb() —y por lo tanto texto_sobre()— siguen viendo el color
#' oscuro original aunque en pantalla se vea claro. Resultado: texto blanco
#' sobre un relleno casi blanco. Pasó con la clase "Especial" de la tabla de
#' codones. Con la mezcla opaca, lo que se mide es lo que se ve.
#'
#' @param p fracción del color original que se conserva (0 = blanco, 1 = igual)
aclarar <- function(color, p) {
  rgb <- grDevices::col2rgb(color)[, 1]
  grDevices::rgb(t(rgb * p + 255 * (1 - p)), maxColorValue = 255)
}

#' Blanco o negro, el que contraste mejor contra `fondo`.
#'
#' Las celdas de la tabla de codones llevan texto encima de seis rellenos
#' distintos. Con un color de texto fijo, la letra sobre el ámbar o sobre el
#' gris claro se pierde. Se decide por luminancia relativa (WCAG) en vez de a
#' ojo, para que siga siendo correcto si mañana se cambia un color de la paleta.
texto_sobre <- function(fondo) {
  vapply(fondo, function(f) {
    canal <- grDevices::col2rgb(f)[, 1] / 255
    lin   <- ifelse(canal <= 0.03928, canal / 12.92,
                    ((canal + 0.055) / 1.055) ^ 2.4)
    L     <- sum(c(0.2126, 0.7152, 0.0722) * lin)
    # Contraste contra blanco vs. contra negro; gana el mayor.
    if ((1.05 / (L + 0.05)) >= ((L + 0.05) / 0.05)) "white" else TEXTO
  }, character(1), USE.NAMES = FALSE)
}
