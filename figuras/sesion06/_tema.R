## Configuración compartida de las CINCO figuras de la Sesión 6,
## Alineamiento de secuencias por pares.
##
## Adaptador, igual que los _tema.R de las sesiones 2 a 5: conserva los nombres
## que pide la especificación (AZUL, NARANJA, VERDE, guardar en centímetros) y
## los cablea a figuras/estilo.R, el único lugar del repo donde vive un hex.
##
## Uso, desde cualquier working directory:
##     source(".../figuras/sesion06/_tema.R")   # los scripts lo hacen solos
##
## ---------------------------------------------------------------------------
## AVISO DE LICENCIA
##
## Las IDEAS de este capítulo (Hamming, LCS, el turista de Manhattan, el grafo
## de alineamiento) vienen de Compeau y Pevzner, *Bioinformatics Algorithms*,
## que es All Rights Reserved. Las ideas se reusan citando; sus FIGURAS no.
##
## Las cinco figuras de esta carpeta se dibujan desde cero, con datos y
## geometrías propias: los pesos de la cuadrícula de Manhattan se diseñaron y
## se verificaron acá (02_manhattan.R), el camino de @fig-grafo es uno elegido
## acá sobre secuencias elegidas acá, y la curva de @fig-explosion se calcula
## con lgamma. Nada está calcado ni "basado visualmente" en sus diapositivas.
## Si algún día se rehace una figura, esa regla se mantiene.
## ---------------------------------------------------------------------------

.ubicar_tema <- function() {
  for (i in rev(seq_len(sys.nframe()))) {   # de adentro hacia afuera
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar _tema.R: correr con Rscript o con source()")
}

.DIR_SESION06 <- dirname(.ubicar_tema())
source(file.path(dirname(.DIR_SESION06), "estilo.R"))

# --- Alias de paleta con los nombres de la especificación -------------------
AZUL       <- TEAL
AZUL_CLARO <- TEAL_CLARO
NARANJA    <- AMBAR
# VERDE, GRIS, TEXTO y FONDO_CELDA vienen tal cual de estilo.R.

# Grises de relleno. El capítulo usa el contraste gris/verde como argumento
# (fig. 1), así que los dos grises tienen que ser inequívocamente grises: uno
# para "esto no coincide" y otro, más claro, para "acá no hay nada que comparar".
GRIS_CELDA  <- "#d4d4d4"
GRIS_HUECO  <- "#efefef"
GRIS_TENUE  <- alpha(GRIS, 0.22)   # las aristas del grafo completo

# --- Temas ------------------------------------------------------------------
tema_libro <- function(base_size = 10) tema_lgc(base_size = base_size)

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

guardar <- function(p, nombre, w = 16, h = 9) {
  .guardar_pulgadas(p, nombre, subdir = "sesion06",
                    ancho = w / CM_POR_PULGADA, alto = h / CM_POR_PULGADA)
}

escribir_tsv <- function(df, nombre) {
  ruta <- file.path(.DIR_SESION06, paste0(nombre, ".tsv"))
  write.table(df, ruta, sep = "\t", row.names = FALSE, quote = FALSE,
              fileEncoding = "UTF-8")
  message(sprintf("  escrito figuras/sesion06/%s.tsv", nombre))
  invisible(ruta)
}

# --- Helpers de dibujo ------------------------------------------------------
# Avances tipográficos aproximados, para comprobar en los stopifnot que nada se
# sale del panel. Mismos valores que la sesión 5.
AVANCE_SANS <- 0.55
AVANCE_MONO <- 0.60

media_ancho <- function(txt, tam, avance = AVANCE_SANS) {
  largo <- vapply(strsplit(txt, "\n", fixed = TRUE),
                  function(p) max(nchar(p)), numeric(1))
  largo * tam * avance / 2
}

#' Curva suave de una anotación a lo que señala, para geom_path.
#' Bézier cuadrática; el punto de control se desplaza perpendicular al segmento
#' para que la curva salga del lado que se pida. Igual que en la sesión 5.
llamada <- function(x0, y0, x1, y1, comba = 0.28, n = 40) {
  t  <- seq(0, 1, length.out = n)
  mx <- (x0 + x1) / 2; my <- (y0 + y1) / 2
  dx <- x1 - x0;       dy <- y1 - y0
  cx <- mx - comba * dy; cy <- my + comba * dx
  data.frame(x = (1 - t)^2 * x0 + 2 * (1 - t) * t * cx + t^2 * x1,
             y = (1 - t)^2 * y0 + 2 * (1 - t) * t * cy + t^2 * y1)
}

#' Círculo punteado para marcar un nodo. geom_point con stroke punteado no
#' existe, así que se dibuja el círculo como un path de n puntos.
circulo <- function(x0, y0, r, n = 80) {
  a <- seq(0, 2 * pi, length.out = n)
  data.frame(x = x0 + r * cos(a), y = y0 + r * sin(a))
}

#' Acorta un segmento por los dos extremos, para que las flechas no se metan
#' debajo de los círculos de los nodos.
recortar <- function(x0, y0, x1, y1, ini = 0, fin = 0) {
  L <- sqrt((x1 - x0)^2 + (y1 - y0)^2)
  ux <- (x1 - x0) / L; uy <- (y1 - y0) / L
  data.frame(x = x0 + ux * ini, y = y0 + uy * ini,
             xend = x1 - ux * fin, yend = y1 - uy * fin)
}

#' Desplaza un segmento perpendicularmente a sí mismo.
#' Se usa cuando dos rutas comparten una arista y hay que poder distinguirlas.
desfasar <- function(seg, d) {
  L  <- sqrt((seg$xend - seg$x)^2 + (seg$yend - seg$y)^2)
  nx <- -(seg$yend - seg$y) / L; ny <- (seg$xend - seg$x) / L
  seg$x <- seg$x + nx * d; seg$xend <- seg$xend + nx * d
  seg$y <- seg$y + ny * d; seg$yend <- seg$yend + ny * d
  seg
}
