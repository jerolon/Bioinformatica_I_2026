## Configuración compartida de las CINCO figuras de la Sesión 5,
## Formatos de secuencia: FASTA.
##
## Adaptador, igual que los _tema.R de las sesiones 2, 3 y 4: conserva los
## nombres que pide la especificación (AZUL, NARANJA, guardar en centímetros) y
## los cablea a figuras/estilo.R, el único lugar del repo donde vive un hex.
##
## Uso, desde cualquier working directory:
##     source(".../figuras/sesion05/_tema.R")   # los scripts lo hacen solos

.ubicar_tema <- function() {
  for (i in rev(seq_len(sys.nframe()))) {   # de adentro hacia afuera
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar _tema.R: correr con Rscript o con source()")
}

.DIR_SESION05 <- dirname(.ubicar_tema())
source(file.path(dirname(.DIR_SESION05), "estilo.R"))

suppressPackageStartupMessages(library(Biostrings))

# --- Alias de paleta con los nombres de la especificación -------------------
AZUL       <- TEAL
AZUL_CLARO <- TEAL_CLARO
NARANJA    <- AMBAR

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

guardar <- function(p, nombre, w = 16, h = 10) {
  .guardar_pulgadas(p, nombre, subdir = "sesion05",
                    ancho = w / CM_POR_PULGADA, alto = h / CM_POR_PULGADA)
}

escribir_tsv <- function(df, nombre) {
  ruta <- file.path(.DIR_SESION05, paste0(nombre, ".tsv"))
  write.table(df, ruta, sep = "\t", row.names = FALSE, quote = FALSE,
              fileEncoding = "UTF-8")
  message(sprintf("  escrito figuras/sesion05/%s.tsv", nombre))
  invisible(ruta)
}

# --- Helpers de dibujo ------------------------------------------------------
AVANCE_SANS <- 0.55
AVANCE_MONO <- 0.60

media_ancho <- function(txt, tam, avance = AVANCE_SANS) {
  largo <- vapply(strsplit(txt, "\n", fixed = TRUE),
                  function(p) max(nchar(p)), numeric(1))
  largo * tam * avance / 2
}

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

#' Curva suave de una anotación a lo que señala, para geom_path.
#' Es una Bézier cuadrática; el punto de control se desplaza perpendicular al
#' segmento para que la curva salga del lado que se pida.
llamada <- function(x0, y0, x1, y1, comba = 0.28, n = 40) {
  t  <- seq(0, 1, length.out = n)
  mx <- (x0 + x1) / 2; my <- (y0 + y1) / 2
  dx <- x1 - x0;       dy <- y1 - y0
  cx <- mx - comba * dy; cy <- my + comba * dx
  data.frame(x = (1 - t)^2 * x0 + 2 * (1 - t) * t * cx + t^2 * x1,
             y = (1 - t)^2 * y0 + 2 * (1 - t) * t * cy + t^2 * y1)
}

# --- Datos ------------------------------------------------------------------
DIR_DATOS <- file.path(.DIR_SESION05, "datos")

#' Ruta a un FASTA de la sesión. Truena con un mensaje útil si falta.
ruta_fasta <- function(acc) {
  r <- file.path(DIR_DATOS, paste0(acc, ".fa"))
  if (!file.exists(r)) {
    stop(sprintf(paste("falta %s.\nCorre primero:  bash figuras/sesion05/00_datos.sh",
                       "\n(desde la raíz del repo)"), r), call. = FALSE)
  }
  r
}

#' Lee un FASTA de un solo registro y devuelve el DNAString.
#'
#' Se usa Biostrings y no el leer_fasta() de sesion01, que es el que recomienda
#' el capítulo ("para cualquier cosa seria, una biblioteca"). La diferencia
#' importa acá: leer_fasta() aplica toupper() y colapsaría el soft-masking, que
#' es justo uno de los cinco archivos rotos del ejercicio 5.
leer_genoma <- function(acc) {
  s <- Biostrings::readDNAStringSet(ruta_fasta(acc))
  stopifnot(length(s) == 1L)
  s[[1]]
}

#' Las mismas cuentas que hace el capítulo con la terminal, pero leyendo el
#' archivo byte a byte: bytes, líneas, bases, ancho de plegado. Sirve para que
#' las figuras muestren números MEDIDOS y no transcritos del texto.
anatomia_archivo <- function(ruta) {
  lineas <- readLines(ruta, warn = FALSE)
  bytes  <- file.info(ruta)$size
  es_enc <- grepl("^>", lineas)
  sec    <- lineas[!es_enc & nzchar(lineas)]
  anchos <- nchar(sec)
  list(
    ruta        = ruta,
    encabezado  = lineas[es_enc][1],
    n_lineas    = length(lineas),
    n_registros = sum(es_enc),
    n_blancas   = sum(!es_enc & !nzchar(lineas)),
    bases       = sum(anchos),
    bytes       = bytes,
    # El ancho de plegado es el que domina: la última línea casi siempre es corta.
    ancho       = as.integer(names(sort(table(anchos), decreasing = TRUE))[1]),
    anchos      = anchos,
    lineas      = lineas
  )
}

#' GC en porcentaje, contando mayúsculas y minúsculas (la costumbre que el
#' capítulo pide agarrar en el ejercicio 3).
gc_pct <- function(x) {
  100 * as.numeric(Biostrings::letterFrequency(x, "GC", as.prob = TRUE))
}

#' Longitud en kb o Mb, para las etiquetas de eje.
fmt_largo <- function(n) {
  ifelse(n >= 1e6, sprintf("%.1f Mb", n / 1e6), sprintf("%.0f kb", n / 1e3))
}
