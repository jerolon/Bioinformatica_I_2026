## Configuración compartida de las CINCO figuras de la práctica de la Sesión 01
## (anatomía de FASTA, pipeline, GC en ventanas, composición, GC entre genomas).
##
## ---------------------------------------------------------------------------
## POR QUÉ ESTE ARCHIVO ES UN ADAPTADOR Y NO UN MÓDULO DE ESTILO
##
## La especificación de estas figuras pedía un `_tema.R` autónomo, con su propia
## paleta declarada a mano:
##
##     AZUL <- "#1f4e79" ; NARANJA <- "#e07b39" ; GRIS <- "#6c6c6c" ; VERDE <- "#2e7d5b"
##
## Son los mismos valores tentativos que ya traía la especificación de las
## cuatro figuras anteriores de esta carpeta, y que en su momento se
## descartaron: no son los colores del libro. El sitio define su paleta en
## assets/css/quarto-lgc.scss, y `figuras/estilo.R` (gemelo de `estilo.py`) es
## el único lugar del repo donde vive un hex. Ver figuras/sesion01/FIGURAS.md,
## sección "Paleta": "Nadie teclea un hex suelto".
##
## Si estas cinco figuras usaran #1f4e79 quedarían al lado de las otras cuatro
## de la MISMA sesión, dibujadas en #1a7a8a, y no combinarían. Así que este
## archivo conserva los NOMBRES de la especificación (AZUL, NARANJA, tema_libro,
## guardar) y los cablea a la paleta real del libro. Los scripts se escriben tal
## como los pedía la especificación; lo que cambia es a qué apuntan los nombres.
##
## Mapeo:  AZUL -> TEAL (#1a7a8a) · NARANJA -> AMBAR (#d98c00)
##         GRIS -> GRIS (#666666) · VERDE -> VERDE (#2e7d32)
##
## Lo demás de la especificación se respeta al pie: svglite (nunca el device
## svg() de base R, que vectoriza el texto), sin título dentro del SVG, fondo
## transparente, etiquetas en español, y cada script escribe su .tsv.
## ---------------------------------------------------------------------------
##
## Uso, desde cualquier working directory:
##     source(".../figuras/sesion01/_tema.R")   # los scripts lo hacen solos

# --- Localizar estilo.R ----------------------------------------------------
# Mismo idiom que usan las otras figuras de la carpeta: se busca el `ofile` que
# source() deja en los frames, de ADENTRO hacia afuera, para que el path sea el
# de ESTE archivo y no el del script que lo sourcea.
.ubicar_tema <- function() {
  for (i in rev(seq_len(sys.nframe()))) {
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar _tema.R: correr con Rscript o con source()")
}

.DIR_SESION01 <- dirname(.ubicar_tema())
source(file.path(dirname(.DIR_SESION01), "estilo.R"))

# estilo.R ya cargó ggplot2, svglite y scales, y definió TEAL, AMBAR, VERDE,
# GRIS, TEXTO, tema_lgc(), guardar() y DIR_FIGURAS.

# --- Alias de paleta con los nombres de la especificación -------------------
AZUL    <- TEAL     # trazo primario
NARANJA <- AMBAR    # contraste / referencia / "el punto de la figura"
# GRIS y VERDE ya vienen de estilo.R con esos mismos nombres.

# --- Rutas ------------------------------------------------------------------
# Los scripts leen los genomas de datos/ en la raíz del repo. Se resuelve desde
# la ubicación del script, no desde getwd(), para que funcione igual si alguien
# lo corre desde RStudio con otro directorio activo.
DIR_RAIZ  <- dirname(dirname(.DIR_SESION01))
DIR_DATOS <- file.path(DIR_RAIZ, "datos")

#' Ruta a un FASTA descargado por 00_descarga_datos.sh.
#' Truena con un mensaje útil si falta el archivo, en vez de fallar adentro de
#' readLines() con un error críptico.
ruta_datos <- function(nombre) {
  r <- file.path(DIR_DATOS, nombre)
  if (!file.exists(r)) {
    stop(sprintf(paste("falta %s.\nCorre primero:  bash figuras/sesion01/00_descarga_datos.sh",
                       "\n(desde la raíz del repo)"), r), call. = FALSE)
  }
  r
}

# --- Tema -------------------------------------------------------------------
#' Tema de estas figuras. Es el del libro (tema_lgc) con la base a 10 pt, que es
#' lo que pedía la especificación; se mantiene como función aparte para que los
#' scripts se lean como los describe FIGURAS.md.
tema_libro <- function(base_size = 10) tema_lgc(base_size = base_size)

# --- Lectura de FASTA -------------------------------------------------------
#' Lector mínimo de FASTA de un solo registro.
#'
#' Devuelve la secuencia en MAYÚSCULAS, sin header y sin saltos de línea. El
#' `gsub` quita cualquier carácter no alfabético (espacios, dígitos, \r de los
#' finales de línea de Windows), que es justo la trampa que enseña el capítulo.
#'
#' Ojo: `toupper()` colapsa el soft-masking. Para estos seis genomas da igual
#' (ninguno viene enmascarado, comprobado), pero si algún día se agrega un
#' genoma eucarionte grande hay que contar antes de colapsar.
leer_fasta <- function(ruta) {
  lineas <- readLines(ruta, warn = FALSE)
  lineas <- lineas[!grepl("^>", lineas)]
  toupper(gsub("[^A-Za-z]", "", paste(lineas, collapse = "")))
}

# --- Salida -----------------------------------------------------------------
# estilo.R define guardar(p, nombre, subdir, ancho, alto) en PULGADAS. La
# especificación de estas figuras habla en centímetros. Se guarda la original y
# se expone una con la firma que pide la especificación.
#
# (16 x 10 cm son 6.3 x 3.9 pulgadas: exactamente el tamaño estándar del libro.
# Los dos criterios coinciden, no hay que elegir.)
.guardar_pulgadas <- guardar

CM_POR_PULGADA <- 2.54

#' Guarda el SVG en figuras/sesion01/<nombre>.svg. Ancho y alto en CENTÍMETROS.
guardar <- function(p, nombre, w = 16, h = 10) {
  .guardar_pulgadas(p, nombre, subdir = "sesion01",
                    ancho = w / CM_POR_PULGADA, alto = h / CM_POR_PULGADA)
}

#' Escribe el .tsv con los números que graficó la figura. Es el chequeo de que
#' la figura y el texto del capítulo dicen lo mismo.
escribir_tsv <- function(df, nombre) {
  ruta <- file.path(.DIR_SESION01, paste0(nombre, ".tsv"))
  write.table(df, ruta, sep = "\t", row.names = FALSE, quote = FALSE)
  message(sprintf("  escrito figuras/sesion01/%s.tsv", nombre))
  invisible(ruta)
}

# `familia_mono()` la define estilo.R, junto a familia_base() y al STACK_MONO
# que guardar() escribe en el SVG. Vivía acá duplicada y se movió allá: las dos
# figuras de esquema (FASTA y pipeline) necesitan que la familia que elige R al
# dibujar y el stack que queda en el archivo sean la misma decisión.
