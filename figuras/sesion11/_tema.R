## Configuración compartida de las DIEZ figuras de la Sesión 11:
## Unidad 4 (bases de datos, figuras 1-5) y Unidad 5 (browsers, figuras 6-10).
## Las dos unidades son un solo bloque de cinco horas, así que comparten
## carpeta, tema y script de datos.
##
## Adaptador, igual que los _tema.R de las sesiones 2 a 6: conserva los nombres
## que pide la especificación (AZUL, NARANJA, VERDE, guardar en centímetros) y
## los cablea a figuras/estilo.R, el único lugar del repo donde vive un hex.
##
## Uso, desde cualquier working directory:
##     source(".../figuras/sesion11/_tema.R")   # los scripts lo hacen solos
##
## ---------------------------------------------------------------------------
## DE DÓNDE SALEN LOS NÚMEROS
##
## Las dos figuras de datos de esta sesión (@fig-flatfile y @fig-pe) NO llevan
## cifras transcritas de la prosa. La primera lee `datos/tp53.gb`, el registro
## real; la segunda lleva la distribución de niveles PE en un TSV que se
## verifica contra la API de UniProt. Las tres restantes son esquemas y no
## afirman ninguna cantidad.
##
## Cuando UniProt saque un release nuevo, el 04_ vuelve a correr contra la API
## y avisa si cambió. Ver FIGURAS.md.
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

.DIR_SESION11 <- dirname(.ubicar_tema())
source(file.path(dirname(.DIR_SESION11), "estilo.R"))

# --- Alias de paleta con los nombres de la especificación -------------------
AZUL       <- TEAL
AZUL_CLARO <- TEAL_CLARO
NARANJA    <- AMBAR
# VERDE, GRIS, TEXTO y FONDO_CELDA vienen tal cual de estilo.R.

# Grises de relleno. La unidad usa el contraste gris/color como argumento en
# dos figuras distintas ("lo que NO se intercambia" en la 2, "el archivo" en la
# 3), así que los grises tienen que ser inequívocamente grises.
GRIS_CAJA  <- "#e8e8e8"   # relleno de "esto queda fuera"
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
  .guardar_pulgadas(p, nombre, subdir = "sesion11",
                    ancho = w / CM_POR_PULGADA, alto = h / CM_POR_PULGADA)
}

escribir_tsv <- function(df, nombre) {
  ruta <- file.path(.DIR_SESION11, paste0(nombre, ".tsv"))
  write.table(df, ruta, sep = "\t", row.names = FALSE, quote = FALSE,
              fileEncoding = "UTF-8")
  message(sprintf("  escrito figuras/sesion11/%s.tsv", nombre))
  invisible(ruta)
}

# --- Datos ------------------------------------------------------------------
#' Ruta a un archivo de datos/ de esta sesión. datos/ está en .gitignore: lo
#' que se versiona es 00_descarga_datos.sh y el PROCEDENCIA.md de al lado.
ruta_datos <- function(archivo) {
  r <- file.path(.DIR_SESION11, "datos", archivo)
  if (!file.exists(r)) {
    stop(sprintf(paste("falta %s.\nCorre primero:  bash figuras/sesion11/",
                       "00_descarga_datos.sh"), r), call. = FALSE)
  }
  r
}

# --- Helpers de dibujo ------------------------------------------------------
# Avances tipográficos aproximados, para comprobar en los stopifnot que nada se
# sale del panel. Mismos valores que las sesiones 5 y 6.
AVANCE_SANS <- 0.55
AVANCE_MONO <- 0.60

media_ancho <- function(txt, tam, avance = AVANCE_SANS) {
  largo <- vapply(strsplit(txt, "\n", fixed = TRUE),
                  function(p) max(nchar(p)), numeric(1))
  largo * tam * avance / 2
}

#' Llave (brace) horizontal o vertical para abrazar un tramo.
#' Igual que la de las sesiones 2, 3 y 5; se repite acá porque cada _tema.R es
#' autocontenido a propósito (una sesión no debe romperse al editar otra).
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

#' La misma llave, girada 90°: abraza un tramo VERTICAL desde la izquierda.
#' Es la que usa @fig-flatfile para marcar las secciones del registro, que se
#' apilan hacia abajo y no a lo ancho.
llave_v <- function(y0, y1, x, prof, izquierda = TRUE, n = 20) {
  b <- llave(y0, y1, x, prof, arriba = !izquierda, n = n)
  data.frame(x = b$y, y = b$x)
}

#' Curva suave de una anotación a lo que señala, para geom_path.
#' Bézier cuadrática; el punto de control se desplaza perpendicular al segmento
#' para que la curva salga del lado que se pida. Igual que en las sesiones 5 y 6.
llamada <- function(x0, y0, x1, y1, comba = 0.28, n = 40) {
  t  <- seq(0, 1, length.out = n)
  mx <- (x0 + x1) / 2; my <- (y0 + y1) / 2
  dx <- x1 - x0;       dy <- y1 - y0
  cx <- mx - comba * dy; cy <- my + comba * dx
  data.frame(x = (1 - t)^2 * x0 + 2 * (1 - t) * t * cx + t^2 * x1,
             y = (1 - t)^2 * y0 + 2 * (1 - t) * t * cy + t^2 * y1)
}

#' Rectángulo redondeado como polígono, en unidades de los ejes.
#' geom_tile no redondea y grid::roundrectGrob no se compone con el resto de
#' capas, así que se dibuja a mano.
caja_redonda <- function(xmin, xmax, ymin, ymax, r = 1.5, n = 12) {
  r <- min(r, (xmax - xmin) / 2, (ymax - ymin) / 2)
  a <- seq(0, pi / 2, length.out = n)
  rbind(
    data.frame(x = xmax - r + r * sin(a),      y = ymax - r + r * cos(a)),
    data.frame(x = xmax - r + r * cos(a),      y = ymin + r - r * sin(a)),
    data.frame(x = xmin + r - r * sin(a),      y = ymin + r - r * cos(a)),
    data.frame(x = xmin + r - r * cos(a),      y = ymax - r + r * sin(a))
  )
}

#' Acorta un segmento por los dos extremos, para que las flechas no se metan
#' debajo de las cajas de los nodos.
recortar <- function(x0, y0, x1, y1, ini = 0, fin = 0) {
  L <- sqrt((x1 - x0)^2 + (y1 - y0)^2)
  ux <- (x1 - x0) / L; uy <- (y1 - y0) / L
  data.frame(x = x0 + ux * ini, y = y0 + uy * ini,
             xend = x1 - ux * fin, yend = y1 - uy * fin)
}
