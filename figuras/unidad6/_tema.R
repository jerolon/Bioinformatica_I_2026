## Configuración compartida de las CUATRO figuras pre-generadas de la Unidad 6
## (sesiones 12 a 15, introducción a R).
##
## Adaptador, igual que los _tema.R de las sesiones 2 a 11: conserva los nombres
## que pide la especificación (AZUL, NARANJA, VERDE, guardar en centímetros) y
## los cablea a figuras/estilo.R, el único lugar del repo donde vive un hex.
##
## Uso, desde cualquier working directory:
##     source(".../figuras/unidad6/_tema.R")   # los scripts lo hacen solos
##
## ---------------------------------------------------------------------------
## POR QUÉ ESTA UNIDAD TIENE SOLO CUATRO FIGURAS
##
## En las unidades anteriores las figuras eran ilustraciones que el alumno
## miraba. Acá la mayoría de las figuras LAS PRODUCEN LOS ALUMNOS como
## ejercicio, y su código está en el cuerpo del capítulo. Sólo se pre-generan
## las que ilustran conceptos (tres esquemas) y una de datos, la matriz de
## programación dinámica, que es el ejemplo de lo que el alumno va a producir.
##
## La de datos (03_matriz_nw.R) se genera CON EL CÓDIGO DEL CAPÍTULO, copiado
## textualmente, no con una versión mejorada. Si esa figura sale fea, se
## arregla el capítulo, no el script. Ver FIGURAS.md.
##
## NOTA SOBRE EL NOMBRE DEL ARCHIVO DE TEMA
## FIGURAS.md dice `source("figuras/_tema.R")`. En este repo el archivo central
## se llama figuras/estilo.R y cada sesión tiene su propio _tema.R adaptador.
## Se siguió la convención del repo, que es la que ya usan las sesiones 1 a 11.
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

.DIR_UNIDAD6 <- dirname(.ubicar_tema())
source(file.path(dirname(.DIR_UNIDAD6), "estilo.R"))

# --- Alias de paleta con los nombres de la especificación -------------------
AZUL       <- TEAL
AZUL_CLARO <- TEAL_CLARO
NARANJA    <- AMBAR
# VERDE, GRIS, TEXTO y FONDO_CELDA vienen tal cual de estilo.R.

GRIS_CAJA  <- "#e8e8e8"
GRIS_BORDE <- "#b0b0b0"
GRIS_TENUE <- alpha(GRIS, 0.22)

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
  .guardar_pulgadas(p, nombre, subdir = "unidad6",
                    ancho = w / CM_POR_PULGADA, alto = h / CM_POR_PULGADA)
}
