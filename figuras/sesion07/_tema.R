## Configuración compartida de las figuras en R de la Sesión 7,
## Algoritmos: Needleman-Wunsch y Smith-Waterman.
##
## Adaptador, igual que los _tema.R de las sesiones 2 a 6: conserva los nombres
## que usan los scripts (AZUL, NARANJA, VERDE, guardar en centímetros) y los
## cablea a figuras/estilo.R, el único lugar del repo donde vive un hex.
##
## Ojo: las otras figuras de este capítulo (fig01_reticula … fig07_gotoh) son
## las viejas, en Python, y escriben en figuras/svg/. Las nuevas van en R y en
## esta carpeta, como las sesiones 5 y 6. Las dos paletas son la misma
## (estilo.py y estilo.R comparten hex), así que conviven sin desentonar.
##
## Uso, desde cualquier working directory:
##     source(".../figuras/sesion07/_tema.R")   # los scripts lo hacen solos
##
## ---------------------------------------------------------------------------
## AVISO DE LICENCIA
##
## La IDEA del turista de Manhattan viene de Compeau y Pevzner, *Bioinformatics
## Algorithms*, que es All Rights Reserved. Las ideas se reusan citando; sus
## FIGURAS no.
##
## La figura de esta carpeta se dibuja desde cero: los pesos son propios, la
## geometría es propia y los números que anota los calcula el script (la
## recurrencia y, para comprobarla, la fuerza bruta sobre los C(n+m,n) caminos).
## Nada está calcado ni "basado visualmente" en sus diapositivas. Si algún día
## se rehace una figura, esa regla se mantiene.
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

.DIR_SESION07 <- dirname(.ubicar_tema())
source(file.path(dirname(.DIR_SESION07), "estilo.R"))

suppressPackageStartupMessages(library(patchwork))

# --- Alias de paleta con los nombres que usan los scripts -------------------
AZUL       <- TEAL
AZUL_CLARO <- TEAL_CLARO
NARANJA    <- AMBAR
# VERDE, GRIS, TEXTO y FONDO_CELDA vienen tal cual de estilo.R.

#' Mezcla un color con blanco. Sirve para el relleno de las celdas de una
#' matriz: claro para que el número se lea encima, pero del mismo tono que el
#' borde, para que se vea de qué familia es (azul = derecha, naranja = abajo).
#' No teclea un hex: lo calcula. La regla de "un solo lugar con hex" se cumple.
tinte <- function(col, p = 0.14) {
  rgb(t((1 - p) * c(255, 255, 255) + p * col2rgb(col)), maxColorValue = 255)
}

#' Parte un título en renglones de a lo más `ancho` caracteres.
envolver <- function(txt, ancho = 56) paste(strwrap(txt, ancho), collapse = "\n")

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

#' Tema de un panel de la figura del turista. A diferencia de tema_esquema(),
#' este SÍ deja título: son las etiquetas A/B/C/D de los cuatro paneles, que no
#' son el título de la figura (ese vive en el .qmd, como siempre).
tema_panel <- function(base_size = 10) {
  theme_void(base_size = base_size, base_family = familia_base()) +
    theme(
      plot.title       = element_text(size = 8.6, hjust = 0, lineheight = 1.2,
                                      colour = TEXTO,
                                      margin = margin(b = 4, l = 2)),
      plot.subtitle    = element_text(size = 7.6, hjust = 0, colour = GRIS,
                                      margin = margin(b = 6, l = 2)),
      plot.margin      = margin(6, 8, 6, 8),
      plot.background  = element_rect(fill = NA, colour = NA),
      panel.background = element_rect(fill = NA, colour = NA),
      legend.position  = "none"
    )
}

# --- Salida -----------------------------------------------------------------
.guardar_pulgadas <- guardar
CM_POR_PULGADA <- 2.54

#' w y h en CENTÍMETROS, como en las sesiones 5 y 6.
guardar <- function(p, nombre, w = 16, h = 9) {
  .guardar_pulgadas(p, nombre, subdir = "sesion07",
                    ancho = w / CM_POR_PULGADA, alto = h / CM_POR_PULGADA)
}

escribir_tsv <- function(df, nombre) {
  ruta <- file.path(.DIR_SESION07, paste0(nombre, ".tsv"))
  write.table(df, ruta, sep = "\t", row.names = FALSE, quote = FALSE,
              fileEncoding = "UTF-8")
  message(sprintf("  escrito figuras/sesion07/%s.tsv", nombre))
  invisible(ruta)
}
